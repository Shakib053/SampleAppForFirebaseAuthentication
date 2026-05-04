import SwiftUI

struct SignInView: View {
    let isSigningIn: Bool
    let errorMessage: String?
    let onGoogleSignIn: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.18, blue: 0.17)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 22) {
                    appIcon

                    VStack(spacing: 6) {
                        Text("iOS Authentication")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Sample App for Firebase Authentication")
                            .font(.system(size: 19, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                    }

                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color(red: 0.98, green: 0.74, blue: 0.74))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 18)
                    }

                    VStack(spacing: 14) {
                        AuthButton(
                            title: "Sign in with Apple",
                            icon: AuthProvider.apple.icon,
                            iconColor: AuthProvider.apple.iconColor,
                            isDisabled: true,
                            caption: "Coming soon",
                            action: {}
                        )

                        AuthButton(
                            title: isSigningIn ? "Signing in..." : "Sign in with Google",
                            icon: AuthProvider.google.icon,
                            iconColor: AuthProvider.google.iconColor,
                            isDisabled: isSigningIn,
                            caption: nil,
                            action: onGoogleSignIn
                        )
                    }
                    .padding(.top, 14)

                    Text("By signing in you agree to our\nTerms of Service and Privacy Policy")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.45))
                        .multilineTextAlignment(.center)
                        .padding(.top, 10)
                }
                .padding(.horizontal, 30)

                Spacer()
            }
        }
    }

    private var appIcon: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(red: 0.86, green: 0.97, blue: 0.94))
                .frame(width: 84, height: 84)

            Image(systemName: "clock")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(Color(red: 0.12, green: 0.67, blue: 0.49))
        }
    }
}

private struct AuthButton: View {
    let title: String
    let icon: String
    let iconColor: Color
    let isDisabled: Bool
    let caption: String?
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(isDisabled ? Color.white.opacity(0.55) : iconColor)
                        .frame(width: 24)

                    Text(title)
                        .font(.system(size: 25, weight: .bold, design: .rounded))
                        .foregroundStyle(isDisabled ? Color.white.opacity(0.62) : .white)
                        .frame(maxWidth: .infinity)
                }

                if let caption {
                    Text(caption)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.45))
                }
            }
            .padding(.horizontal, 20)
            .frame(minHeight: 66)
            .background(Color.clear)
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(isDisabled ? 0.12 : 0.20), lineWidth: 1)
            }
        }
        .disabled(isDisabled)
        .buttonStyle(.plain)
        .opacity(isDisabled ? 0.72 : 1.0)
    }
}

#Preview {
    SignInView(isSigningIn: false, errorMessage: nil) { }
}
