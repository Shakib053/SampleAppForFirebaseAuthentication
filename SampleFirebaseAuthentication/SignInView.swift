import SwiftUI

struct SignInView: View {
    let onSignIn: (AuthProvider) -> Void

    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.18, blue: 0.17)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                VStack(spacing: 22) {
                    appIcon

                    VStack(spacing: 6) {
                        Text("Money Manager")
                            .font(.system(size: 34, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Track every taka, on every\ndevice")
                            .font(.system(size: 19, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.white.opacity(0.78))
                            .multilineTextAlignment(.center)
                    }

                    VStack(spacing: 14) {
                        AuthButton(
                            title: "Sign in with Apple",
                            icon: AuthProvider.apple.icon,
                            iconColor: AuthProvider.apple.iconColor
                        ) {
                            onSignIn(.apple)
                        }

                        AuthButton(
                            title: "Sign in with Google",
                            icon: AuthProvider.google.icon,
                            iconColor: AuthProvider.google.iconColor
                        ) {
                            onSignIn(.google)
                        }
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
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(iconColor)
                    .frame(width: 24)

                Text(title)
                    .font(.system(size: 25, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, 20)
            .frame(height: 66)
            .background(Color.clear)
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.20), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SignInView { _ in }
}
