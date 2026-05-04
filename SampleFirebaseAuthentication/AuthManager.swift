import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import SwiftUI
import Combine
import UIKit

@MainActor
final class AuthManager: ObservableObject {
    enum State: Equatable {
        case signedOut
        case signingIn
        case loadingProfile
        case signedIn(UserProfile)
        case error(String)
    }

    @Published private(set) var state: State = .signedOut

    private let auth = Auth.auth()
    private let firestore = Firestore.firestore()

    init() {
        if auth.currentUser != nil {
            Task {
                await restoreSessionIfNeeded()
            }
        }
    }

    func signInWithGoogle() async {
        state = .signingIn

        do {
            guard let clientID = FirebaseApp.app()?.options.clientID else {
                throw AuthFlowError.missingClientID
            }

            guard let presenter = Self.topViewController() else {
                throw AuthFlowError.missingPresenter
            }

            GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenter)
            guard let idToken = signInResult.user.idToken?.tokenString else {
                throw AuthFlowError.missingGoogleToken
            }

            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: signInResult.user.accessToken.tokenString
            )

            state = .loadingProfile
            let firebaseUser = try await signInToFirebase(with: credential)
            let profile = try await loadOrCreateUserProfile(for: firebaseUser)
            state = .signedIn(profile)
        } catch {
            let nsError = error as NSError
            if nsError.domain == kGIDSignInErrorDomain,
               nsError.code == GIDSignInError.canceled.rawValue {
                state = .signedOut
            } else {
                state = .error(Self.message(for: error))
            }
        }
    }

    func restoreSessionIfNeeded() async {
        guard let user = auth.currentUser else {
            state = .signedOut
            return
        }

        state = .loadingProfile

        do {
            let profile = try await loadOrCreateUserProfile(for: user)
            state = .signedIn(profile)
        } catch {
            state = .error(Self.message(for: error))
        }
    }

    func signOut() {
        do {
            try auth.signOut()
            GIDSignIn.sharedInstance.signOut()
            state = .signedOut
        } catch {
            state = .error(Self.message(for: error))
        }
    }

    private func signInToFirebase(with credential: AuthCredential) async throws -> FirebaseAuth.User {
        try await withCheckedThrowingContinuation { continuation in
            auth.signIn(with: credential) { authResult, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let user = authResult?.user else {
                    continuation.resume(throwing: AuthFlowError.missingFirebaseUser)
                    return
                }

                continuation.resume(returning: user)
            }
        }
    }

    private func loadOrCreateUserProfile(for user: FirebaseAuth.User) async throws -> UserProfile {
        let userRef = firestore.collection("users").document(user.uid)
        let snapshot = try await getDocument(from: userRef)
        let now = Date()

        if snapshot.exists {
            try await updateDocument(
                at: userRef,
                data: ["lastLoginAt": Timestamp(date: now)]
            )

            let data = snapshot.data() ?? [:]
            return UserProfile(
                uid: user.uid,
                email: stringValue(data["email"]) ?? user.email ?? "",
                displayName: stringValue(data["displayName"]) ?? user.displayName ?? "Money Manager User",
                photoURL: stringValue(data["photoURL"]) ?? user.photoURL?.absoluteString ?? "",
                provider: stringValue(data["provider"]) ?? "google",
                createdAt: timestampValue(data["createdAt"])?.dateValue() ?? now,
                lastLoginAt: now
            )
        }

        let profile = UserProfile(
            uid: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? "Money Manager User",
            photoURL: user.photoURL?.absoluteString ?? "",
            provider: "google",
            createdAt: now,
            lastLoginAt: now
        )

        try await setDocument(
            at: userRef,
            data: [
                "uid": profile.uid,
                "email": profile.email,
                "displayName": profile.displayName,
                "photoURL": profile.photoURL,
                "provider": profile.provider,
                "createdAt": Timestamp(date: profile.createdAt),
                "lastLoginAt": Timestamp(date: profile.lastLoginAt)
            ]
        )

        return profile
    }

    private func getDocument(from reference: DocumentReference) async throws -> DocumentSnapshot {
        try await withCheckedThrowingContinuation { continuation in
            reference.getDocument { snapshot, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let snapshot else {
                    continuation.resume(throwing: AuthFlowError.missingDocumentSnapshot)
                    return
                }

                continuation.resume(returning: snapshot)
            }
        }
    }

    private func setDocument(at reference: DocumentReference, data: [String: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.setData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func updateDocument(at reference: DocumentReference, data: [AnyHashable: Any]) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.updateData(data) { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    private func stringValue(_ value: Any?) -> String? {
        value as? String
    }

    private func timestampValue(_ value: Any?) -> Timestamp? {
        value as? Timestamp
    }

    private static func topViewController(
        base: UIViewController? = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
    ) -> UIViewController? {
        if let navigation = base as? UINavigationController {
            return topViewController(base: navigation.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            return topViewController(base: tab.selectedViewController)
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }

        return base
    }

    private static func message(for error: Error) -> String {
        if let authError = error as? AuthFlowError {
            return authError.errorDescription ?? "Something went wrong."
        }

        return (error as NSError).localizedDescription
    }
}

struct UserProfile: Equatable {
    let uid: String
    let email: String
    let displayName: String
    let photoURL: String
    let provider: String
    let createdAt: Date
    let lastLoginAt: Date
}

private enum AuthFlowError: LocalizedError {
    case missingClientID
    case missingPresenter
    case missingGoogleToken
    case missingFirebaseUser
    case missingDocumentSnapshot

    var errorDescription: String? {
        switch self {
        case .missingClientID:
            return "Google Sign-In is not configured correctly yet."
        case .missingPresenter:
            return "The app could not present the Google sign-in screen."
        case .missingGoogleToken:
            return "Google sign-in succeeded, but the ID token was missing."
        case .missingFirebaseUser:
            return "Firebase sign-in completed without a valid user."
        case .missingDocumentSnapshot:
            return "Firestore returned an empty user snapshot."
        }
    }
}
