//
//  ProfileSidebarView.swift
//  Solofoodies
//

import SwiftUI

struct ProfileSidebarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = ProfileViewModel()

    private var user: User? { authViewModel.currentUser }
    private var foodieProfile: FoodieProfileData? { user?.foodieProfile }

    private let menuItems: [(icon: String, title: String, destination: ProfileDestination)] = [
        ("person.fill", "Mi Perfil", .editProfile),
        ("airplane", "Viajes", .trips),
        ("heart.fill", "Resenas", .reviews),
        ("star.fill", "Colaboraciones", .collaborations),
        ("bookmark.fill", "Tarifas", .rates),
        ("clock.fill", "Historial", .history),
        ("envelope.fill", "Enviar Invitacion", .invitations),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // User Header
                userHeader

                Divider()

                // Menu Items
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(menuItems, id: \.title) { item in
                            menuRow(icon: item.icon, title: item.title)
                        }

                        // External Links
                        Divider()
                            .padding(.vertical, 8)

                        Link(destination: URL(string: "https://www.youtube.com/playlist?list=PLdurWu2a_HN9BCVqnq7-h7HCqDD4zpTJ-")!) {
                            menuRow(icon: "play.rectangle.fill", title: String(localized: "Tutoriales"), isLink: true)
                        }

                        Link(destination: URL(string: "https://feedback.solofoodies.com/?iguser=\(user?.igUsername?.replacingOccurrences(of: "@", with: "") ?? "")")!) {
                            menuRow(icon: "bubble.left.and.bubble.right.fill", title: String(localized: "Sugerencias"), isLink: true)
                        }
                    }
                }

                Spacer()

                // Footer
                footer
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .task {
            if let userId = user?.id {
                await viewModel.loadProfileData(for: userId)
            }
        }
    }

    // MARK: - User Header

    private var userHeader: some View {
        HStack(spacing: 12) {
            // Profile Picture
            if let pictureUrl = foodieProfile?.profilePicture,
               let url = URL(string: pictureUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        avatarPlaceholder
                    @unknown default:
                        avatarPlaceholder
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(user?.name ?? "Usuario")
                    .font(.headline)
                Text("@\(user?.igUsername ?? "usuario")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Balance Badge
            NavigationLink {
                Text("Balance") // TODO: Implement balance view
            } label: {
                Text("\(Int(viewModel.balance))€")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        Capsule()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding()
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Color(.systemGray4))
            .frame(width: 56, height: 56)
            .overlay {
                Text((user?.name ?? "U").prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
    }

    // MARK: - Menu Row

    private func menuRow(icon: String, title: String, isLink: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(width: 24)

            Text(title)
                .font(.body)

            Spacer()

            if isLink {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            // Legal Links
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "Politica de privacidad"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(localized: "Terminos de servicio"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(localized: "Politica de cookies"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Divider()

            // Logo placeholder
            Text("SOLOFOODIES")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)

            Divider()

            // Logout
            Button(role: .destructive) {
                authViewModel.logout()
                dismiss()
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.body)
                        .frame(width: 24)

                    Text(String(localized: "Cerrar sesion"))
                        .font(.body)

                    Spacer()
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 14)
            }
        }
    }
}

// MARK: - Restaurant Profile Sidebar

struct RestaurantProfileSidebarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    private var user: User? { authViewModel.currentUser }
    private var activeRestaurant: RestaurantProfile? {
        guard let activeId = user?.activeRestaurantId else {
            return user?.restaurants?.first
        }
        return user?.restaurants?.first(where: { $0.id == activeId }) ?? user?.restaurants?.first
    }

    private let menuItems: [(icon: String, title: String)] = [
        ("building.2.fill", "Mi Restaurante"),
        ("star.fill", "Colaboraciones"),
        ("clock.fill", "Historial"),
        ("creditcard.fill", "Suscripcion"),
        ("gearshape.fill", "Configuracion"),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Restaurant Header
                restaurantHeader

                Divider()

                // Menu Items
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(menuItems, id: \.title) { item in
                            menuRow(icon: item.icon, title: item.title)
                        }

                        // External Links
                        Divider()
                            .padding(.vertical, 8)

                        Link(destination: URL(string: "https://www.youtube.com/playlist?list=PLdurWu2a_HN9BCVqnq7-h7HCqDD4zpTJ-")!) {
                            menuRow(icon: "play.rectangle.fill", title: String(localized: "Tutoriales"), isLink: true)
                        }

                        Link(destination: URL(string: "https://feedback.solofoodies.com")!) {
                            menuRow(icon: "bubble.left.and.bubble.right.fill", title: String(localized: "Sugerencias"), isLink: true)
                        }
                    }
                }

                Spacer()

                // Footer
                footer
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large])
    }

    // MARK: - Restaurant Header

    private var restaurantHeader: some View {
        HStack(spacing: 12) {
            // Restaurant Image
            if let imageUrl = activeRestaurant?.profilePicture ?? activeRestaurant?.coverImage,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        restaurantPlaceholder
                    @unknown default:
                        restaurantPlaceholder
                    }
                }
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                restaurantPlaceholder
            }

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 4) {
                    Text(activeRestaurant?.restaurantName ?? "Mi Restaurante")
                        .font(.headline)

                    if activeRestaurant?.isVerified == true {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
                Text("@\(user?.igUsername ?? "restaurant")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Subscription status
            if let subscription = user?.subscription {
                Text(subscription.status == .active ? "PRO" : "FREE")
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(subscription.status == .active ? Color.green : Color.orange)
                    )
                    .foregroundStyle(.white)
            }
        }
        .padding()
    }

    private var restaurantPlaceholder: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [.orange, Color(hex: "E53935")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 56, height: 56)
            .overlay {
                Text((activeRestaurant?.restaurantName ?? "R").prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
    }

    // MARK: - Menu Row

    private func menuRow(icon: String, title: String, isLink: Bool = false) -> some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.primary)
                .frame(width: 24)

            Text(title)
                .font(.body)

            Spacer()

            if isLink {
                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 14)
        .contentShape(Rectangle())
    }

    // MARK: - Footer

    private var footer: some View {
        VStack(spacing: 0) {
            // Legal Links
            VStack(alignment: .leading, spacing: 8) {
                Text(String(localized: "Politica de privacidad"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(localized: "Terminos de servicio"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(String(localized: "Politica de cookies"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            Divider()

            // Logo placeholder
            Text("SOLOFOODIES")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.vertical, 12)

            Divider()

            // Logout
            Button(role: .destructive) {
                authViewModel.logout()
                dismiss()
            } label: {
                HStack(spacing: 16) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.body)
                        .frame(width: 24)

                    Text(String(localized: "Cerrar sesion"))
                        .font(.body)

                    Spacer()
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal)
                .padding(.vertical, 14)
            }
        }
    }
}

#Preview("Foodie Sidebar") {
    ProfileSidebarView()
        .environmentObject(AuthViewModel())
}

#Preview("Restaurant Sidebar") {
    RestaurantProfileSidebarView()
        .environmentObject(AuthViewModel())
}
