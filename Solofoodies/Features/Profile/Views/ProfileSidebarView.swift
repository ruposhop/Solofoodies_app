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
                            NavigationLink {
                                destinationView(for: item.destination)
                            } label: {
                                menuRow(icon: item.icon, title: item.title)
                            }
                            .buttonStyle(.plain)
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
                BalanceView(balance: viewModel.balance)
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

    // MARK: - Destination Views

    @ViewBuilder
    private func destinationView(for destination: ProfileDestination) -> some View {
        switch destination {
        case .editProfile:
            EditProfileView()
        case .trips:
            TripsView()
        case .reviews:
            ReviewsView()
        case .collaborations:
            MyCollaborationsView()
        case .rates:
            RatesView()
        case .history:
            HistoryView()
        case .invitations:
            InvitationsView()
        case .settings:
            SettingsView()
        case .balance:
            BalanceView(balance: viewModel.balance)
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
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
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

// MARK: - Restaurant Menu Destination

enum RestaurantMenuDestination {
    case editRestaurant
    case collaborations
    case history
    case subscription
    case settings
}

// MARK: - Restaurant Profile Sidebar

struct RestaurantProfileSidebarView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showRestaurantPicker = false

    private var user: User? { authViewModel.currentUser }
    private var activeRestaurant: RestaurantProfile? {
        authViewModel.getActiveRestaurant()
    }
    private var restaurants: [RestaurantProfile] {
        authViewModel.restaurants
    }

    private let menuItems: [(icon: String, title: String, destination: RestaurantMenuDestination)] = [
        ("building.2.fill", "Mi Restaurante", .editRestaurant),
        ("star.fill", "Colaboraciones", .collaborations),
        ("clock.fill", "Historial", .history),
        ("creditcard.fill", "Suscripcion", .subscription),
        ("gearshape.fill", "Configuracion", .settings),
    ]

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Restaurant Header
                restaurantHeader

                // Restaurant Switcher (only show if multiple restaurants)
                if authViewModel.hasMultipleRestaurants {
                    restaurantSwitcher
                }

                Divider()

                // Menu Items
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(menuItems, id: \.title) { item in
                            NavigationLink {
                                restaurantDestinationView(for: item.destination)
                            } label: {
                                menuRow(icon: item.icon, title: item.title)
                            }
                            .buttonStyle(.plain)
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
        .confirmationDialog(
            String(localized: "Cambiar de restaurante"),
            isPresented: $showRestaurantPicker,
            titleVisibility: .visible
        ) {
            ForEach(restaurants) { restaurant in
                Button {
                    Task {
                        await authViewModel.switchRestaurant(to: restaurant.id)
                    }
                } label: {
                    HStack {
                        Text(restaurant.restaurantName)
                        if restaurant.id == activeRestaurant?.id {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
            Button(String(localized: "Cancelar"), role: .cancel) {}
        }
    }

    // MARK: - Restaurant Switcher

    private var restaurantSwitcher: some View {
        Button {
            showRestaurantPicker = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.left.arrow.right")
                    .font(.caption)
                Text(String(localized: "Cambiar restaurante"))
                    .font(.subheadline)
                Spacer()
                Text("\(restaurants.count) \(String(localized: "marcas"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(Color(.systemGray6))
        }
        .buttonStyle(.plain)
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

    // MARK: - Destination Views

    @ViewBuilder
    private func restaurantDestinationView(for destination: RestaurantMenuDestination) -> some View {
        switch destination {
        case .editRestaurant:
            RestaurantProfileEditView()
        case .collaborations:
            RestaurantCollaborationsView()
        case .history:
            RestaurantHistoryView()
        case .subscription:
            SubscriptionView()
        case .settings:
            SettingsView()
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
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
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

// MARK: - Balance View

struct BalanceView: View {
    let balance: Double

    var body: some View {
        VStack(spacing: 24) {
            // Balance Card
            VStack(spacing: 8) {
                Text(String(localized: "Tu Balance"))
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Text(String(format: "%.2f€", balance))
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(Color(hex: "E53935"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)

            // Info Section
            VStack(alignment: .leading, spacing: 16) {
                Text(String(localized: "Como funciona"))
                    .font(.headline)

                infoRow(
                    icon: "star.fill",
                    title: String(localized: "Gana creditos"),
                    description: String(localized: "Completa colaboraciones para acumular creditos")
                )

                infoRow(
                    icon: "creditcard.fill",
                    title: String(localized: "Usa tu balance"),
                    description: String(localized: "Canjea tu balance por transferencias bancarias")
                )

                infoRow(
                    icon: "clock.fill",
                    title: String(localized: "Balance pendiente"),
                    description: String(localized: "Los creditos se confirman al completar la colaboracion")
                )
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
            .padding(.horizontal)

            Spacer()

            // Withdraw Button
            Button {
                // TODO: Implement withdrawal flow
            } label: {
                Text(String(localized: "Solicitar retiro"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(balance > 0 ? Color(hex: "E53935") : Color(.systemGray4))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(balance <= 0)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle(String(localized: "Balance"))
        .navigationBarTitleDisplayMode(.inline)
    }

    private func infoRow(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(Color(hex: "E53935"))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
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

#Preview("Balance View") {
    NavigationStack {
        BalanceView(balance: 125.50)
    }
}
