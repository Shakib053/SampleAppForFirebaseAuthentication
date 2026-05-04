import SwiftUI

struct HomeView: View {
    let userProfile: UserProfile
    let onLogout: () -> Void

    private let transactions: [TransactionItem] = [
        TransactionItem(
            title: "Groceries",
            date: "Today",
            amount: "-৳ 850",
            amountTint: Color(red: 0.83, green: 0.28, blue: 0.29),
            amountBackground: Color(red: 0.98, green: 0.90, blue: 0.90),
            icon: "storefront",
            iconForeground: Color(red: 0.60, green: 0.45, blue: 0.25),
            iconBackground: Color(red: 0.98, green: 0.94, blue: 0.88)
        ),
        TransactionItem(
            title: "Salary",
            date: "May 1",
            amount: "+৳ 65,000",
            amountTint: Color(red: 0.16, green: 0.54, blue: 0.38),
            amountBackground: Color(red: 0.87, green: 0.96, blue: 0.92),
            icon: "creditcard",
            iconForeground: Color(red: 0.35, green: 0.53, blue: 0.76),
            iconBackground: Color(red: 0.90, green: 0.95, blue: 1.00)
        ),
        TransactionItem(
            title: "Transport",
            date: "Apr 30",
            amount: "-৳ 120",
            amountTint: Color(red: 0.83, green: 0.28, blue: 0.29),
            amountBackground: Color(red: 0.98, green: 0.90, blue: 0.90),
            icon: "mappin.and.ellipse",
            iconForeground: Color(red: 0.70, green: 0.38, blue: 0.36),
            iconBackground: Color(red: 0.99, green: 0.93, blue: 0.92)
        )
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.19, green: 0.18, blue: 0.16)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                topSummary
                transactionsSection
                bottomTabBar
            }
        }
    }

    private var topSummary: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 10) {
                    Button("Log Out", action: onLogout)
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.black.opacity(0.18))
                        .clipShape(Capsule())

                    Text("May 2026")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.82))

                    Text(userProfile.displayName)
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.88))

                    Text(userProfile.email)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.72))

                    Text("Total balance")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.82))

                    Text("৳ 48,250")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                ProfileBadge(userProfile: userProfile)
            }

            HStack(spacing: 14) {
                SummaryStatCard(
                    title: "Income",
                    amount: "৳ 65,000",
                    background: Color(red: 0.08, green: 0.47, blue: 0.34)
                )
                SummaryStatCard(
                    title: "Expense",
                    amount: "৳ 16,750",
                    background: Color(red: 0.07, green: 0.43, blue: 0.31)
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 28)
        .padding(.bottom, 18)
        .background(Color(red: 0.14, green: 0.65, blue: 0.48))
    }

    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Recent transactions")
                .font(.system(size: 15, weight: .bold, design: .monospaced))
                .foregroundStyle(Color.white.opacity(0.55))
                .padding(.horizontal, 20)
                .padding(.top, 14)
                .padding(.bottom, 8)

            ForEach(transactions) { transaction in
                TransactionRow(item: transaction)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(red: 0.21, green: 0.20, blue: 0.18))
    }

    private var bottomTabBar: some View {
        HStack {
            TabBarItem(icon: "circle.fill", title: "Home", isSelected: true)
            Spacer()
            TabBarItem(icon: "square.grid.2x2.fill", title: "Txns", isSelected: false)
            Spacer()
            TabBarItem(icon: "chart.bar.fill", title: "Stats", isSelected: false)
            Spacer()
            TabBarItem(icon: "square.fill", title: "More", isSelected: false)
        }
        .padding(.horizontal, 22)
        .padding(.top, 10)
        .padding(.bottom, 12)
        .background(Color(red: 0.16, green: 0.16, blue: 0.15))
    }
}

private struct SummaryStatCard: View {
    let title: String
    let amount: String
    let background: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 15, weight: .medium, design: .rounded))
                .foregroundStyle(Color.white.opacity(0.75))

            Text(amount)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(background)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

private struct TransactionItem: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: String
    let amountTint: Color
    let amountBackground: Color
    let icon: String
    let iconForeground: Color
    let iconBackground: Color
}

private struct TransactionRow: View {
    let item: TransactionItem

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(item.iconBackground)
                    .frame(width: 44, height: 44)

                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(item.iconForeground)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 19, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Text(item.date)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.78))
            }

            Spacer()

            Text(item.amount)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(item.amountTint)
                .padding(.horizontal, 12)
                .padding(.vertical, 7)
                .background(item.amountBackground)
                .clipShape(Capsule())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct TabBarItem: View {
    let icon: String
    let title: String
    let isSelected: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
            Text(title)
                .font(.system(size: 12, weight: .medium, design: .rounded))
        }
        .foregroundStyle(isSelected ? Color(red: 0.14, green: 0.77, blue: 0.56) : Color.white.opacity(0.45))
        .frame(maxWidth: .infinity)
    }
}

private struct ProfileBadge: View {
    let userProfile: UserProfile

    var body: some View {
        Group {
            if let url = URL(string: userProfile.photoURL), !userProfile.photoURL.isEmpty {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    initialsBadge
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                initialsBadge
            }
        }
    }

    private var initialsBadge: some View {
        Text(initials)
            .font(.system(size: 18, weight: .bold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: 50, height: 50)
            .background(Color(red: 0.09, green: 0.45, blue: 0.32))
            .clipShape(Circle())
    }

    private var initials: String {
        let pieces = userProfile.displayName.split(separator: " ")
        let letters = pieces.prefix(2).compactMap { $0.first }
        let result = String(letters)
        return result.isEmpty ? "MM" : result.uppercased()
    }
}

#Preview {
    HomeView(
        userProfile: UserProfile(
            uid: "preview-uid",
            email: "preview@example.com",
            displayName: "Preview User",
            photoURL: "",
            provider: "google",
            createdAt: Date(),
            lastLoginAt: Date()
        )
    ) { }
}
