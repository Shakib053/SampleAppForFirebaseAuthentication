//
//  ContentView.swift
//  SampleFirebaseAuthentication
//
//  Created by Kazi Tanjim Shakib on 3/5/26.
//

import SwiftUI

struct ContentView: View {
    @State private var route: AppRoute = .signIn

    var body: some View {
        switch route {
        case .signIn:
            SignInView { provider in
                route = .authorizing(provider)
            }
        case .authorizing(let provider):
            AuthorizationView(provider: provider)
                .task(id: provider) {
                    try? await Task.sleep(for: .seconds(3.0))
                    route = .home
                }
        case .home:
            HomeView {
                route = .signIn
            }
        }
    }
}

private enum AppRoute: Equatable {
    case signIn
    case authorizing(AuthProvider)
    case home
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
    let provider: AuthProvider

    var body: some View {
        ZStack {
            Color(red: 0.18, green: 0.18, blue: 0.17)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(Color.white.opacity(0.10))
                        .frame(width: 92, height: 92)

                    Image(systemName: provider.icon)
                        .font(.system(size: 38, weight: .medium))
                        .foregroundStyle(provider.iconColor)
                }

                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.15)

                Text("Authorizing with \(provider.title)")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text("This is a dummy authorization step before the app opens the home tab.")
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
