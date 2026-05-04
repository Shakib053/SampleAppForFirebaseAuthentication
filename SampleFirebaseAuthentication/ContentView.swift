//
//  ContentView.swift
//  SampleFirebaseAuthentication
//
//  Created by Kazi Tanjim Shakib on 3/5/26.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var authManager = AuthManager()

    var body: some View {
        switch authManager.state {
        case .signedOut:
            SignInView(
                isSigningIn: false,
                errorMessage: nil,
                onGoogleSignIn: {
                    Task {
                        await authManager.signInWithGoogle()
                    }
                }
            )
        case .signingIn:
            AuthorizationView(
                title: "Authorizing with Google",
                message: "Opening your Google account and completing Firebase sign-in."
            )
        case .loadingProfile:
            AuthorizationView(
                title: "Loading your profile",
                message: "Checking Firestore and restoring your account data."
            )
        case .signedIn(let userProfile):
            HomeView(userProfile: userProfile) {
                authManager.signOut()
            }
        case .error(let message):
            SignInView(
                isSigningIn: false,
                errorMessage: message,
                onGoogleSignIn: {
                    Task {
                        await authManager.signInWithGoogle()
                    }
                }
            )
        }
    }
}

enum AuthProvider: String {
    case apple
    case google

    var title: String {
        switch self {
        case .apple:
            return "Apple"
        case .google:
            return "Google"
        }
    }

    var icon: String {
        switch self {
        case .apple:
            return "apple.logo"
        case .google:
            return "g.circle.fill"
        }
    }

    var iconColor: Color {
        switch self {
        case .apple:
            return .white
        case .google:
            return Color(red: 0.26, green: 0.53, blue: 0.96)
        }
    }
}

private struct AuthorizationView: View {
    let title: String
    let message: String

    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.18, blue: 0.17)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 92, height: 92)

                    Image(systemName: "lock.shield")
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(.white)
                }

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.15)

                Text(title)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(message)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
        }
    }
}

#Preview {
    ContentView()
}
