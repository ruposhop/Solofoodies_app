//
//  FoodieProfileView.swift
//  Solofoodies
//

import SwiftUI

struct FoodieProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingSidebar = false

    private var user: User? { authViewModel.currentUser }
    private var fullProfile: FullUserProfile? { viewModel.fullProfile }
    private var foodieProfile: FullFoodieProfile? { viewModel.foodieProfile }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header Card
                    profileHeaderCard

                    // Stats Row
                    statsRow

                    // Rates Section
                    ratesSection

                    // Reviews Section
                    reviewsSection
                }
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
            .navigationTitle(String(localized: "Perfil"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingSidebar = true
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingSidebar) {
                ProfileSidebarView()
            }
            .task {
                if let userId = user?.id {
                    await viewModel.loadProfileData(for: userId)
                }
            }
            .refreshable {
                if let userId = user?.id {
                    await viewModel.loadProfileData(for: userId)
                }
            }
        }
    }

    // MARK: - Profile Header Card

    private var profileHeaderCard: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 12) {
                // Profile Picture
                profileImage

                // Name and Stats
                VStack(alignment: .leading, spacing: 4) {
                    Text("@\(user?.igUsername ?? "usuario")")
                        .font(.headline)

                    // Rating Stars
                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= Int(viewModel.ratingStats.averageScore ?? 0) ? "star.fill" : "star")
                                .font(.caption)
                                .foregroundStyle(star <= Int(viewModel.ratingStats.averageScore ?? 0) ? .yellow : .gray)
                        }
                        Text("(\(viewModel.ratingStats.totalRatings))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(user?.name ?? "")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                // Province Badge and Edit
                VStack(alignment: .trailing, spacing: 8) {
                    if let state = foodieProfile?.address?.state, !state.isEmpty {
                        Text(state)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                            )
                    }

                    NavigationLink {
                        EditFoodieProfileView(viewModel: viewModel)
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "E53935"))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top)
    }

    private var profileImage: some View {
        Group {
            if let pictureUrl = foodieProfile?.profilePicture,
               let url = URL(string: pictureUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        profilePlaceholder
                    @unknown default:
                        profilePlaceholder
                    }
                }
                .frame(width: 64, height: 64)
                .clipShape(Circle())
            } else {
                profilePlaceholder
            }
        }
    }

    private var profilePlaceholder: some View {
        Circle()
            .fill(Color(.systemGray3))
            .frame(width: 64, height: 64)
            .overlay {
                Text((user?.igUsername ?? user?.name ?? "U").prefix(3).uppercased())
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            // Social Networks from full profile
            let networks = viewModel.socialNetworks.sorted { platformOrder($0.platform) < platformOrder($1.platform) }
            ForEach(networks) { network in
                statItem(
                    icon: network.platform.icon,
                    value: viewModel.formatFollowers(network.followers),
                    subtitle: network.platform != .facebook ?
                        String(format: "%.2f%%", network.engagementRate ?? 0) : nil
                )
            }

            // Collaborations count
            statItem(
                icon: "star.fill",
                value: "\(foodieProfile?.followers ?? 0)",
                subtitle: String(localized: "Colabs")
            )
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
        .padding(.horizontal)
        .padding(.top, 8)
    }

    private func statItem(icon: String, value: String, subtitle: String?) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.headline)

            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func platformOrder(_ platform: SocialPlatform) -> Int {
        switch platform {
        case .instagram: return 0
        case .tiktok: return 1
        case .youtube: return 2
        case .facebook: return 3
        case .twitter: return 4
        }
    }

    // MARK: - Rates Section

    private var ratesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Tarifas"))
                .font(.title3.bold())

            if viewModel.rates.isEmpty {
                VStack(spacing: 0) {
                    Text(String(localized: "No tienes tarifas configuradas"))
                        .foregroundStyle(.secondary)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(Color(.systemGray4))
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.rates) { rate in
                        HStack {
                            Text(rate.description)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Text(String(format: "%.0f€", rate.price))
                                .font(.subheadline.bold())
                        }
                        .padding()

                        if rate.id != viewModel.rates.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Resenas de restaurantes"))
                .font(.title3.bold())

            if viewModel.ratings.isEmpty {
                VStack(spacing: 8) {
                    Text(String(localized: "Sin resenas todavia"))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "Las resenas de restaurantes apareceran aqui"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(style: StrokeStyle(lineWidth: 1, dash: [5]))
                        .foregroundStyle(Color(.systemGray4))
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(viewModel.ratings) { rating in
                        RatingRow(rating: rating, viewModel: viewModel, isForRestaurant: false)
                        if rating.id != viewModel.ratings.last?.id {
                            Divider()
                        }
                    }
                }
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 1)
                )
            }
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }
}

// MARK: - Rating Row

struct RatingRow: View {
    let rating: ProfileRating
    let viewModel: ProfileViewModel
    let isForRestaurant: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Avatar
            raterAvatar

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(raterName)
                        .font(.subheadline.bold())

                    Spacer()

                    Text(viewModel.formatTimeAgo(rating.createdAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Stars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: star <= rating.score ? "star.fill" : "star")
                            .font(.caption2)
                            .foregroundStyle(star <= rating.score ? .yellow : .gray)
                    }
                }

                if let comment = rating.comment, !comment.isEmpty {
                    Text(comment)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(3)
                }
            }
        }
        .padding()
    }

    private var raterAvatar: some View {
        Group {
            if let imageUrl = raterImageUrl, let url = URL(string: imageUrl) {
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
                .frame(width: 48, height: 48)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }
        }
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(isForRestaurant ? Color(hex: "E53935") : Color(.systemGray3))
            .frame(width: 48, height: 48)
            .overlay {
                Text(raterName.prefix(1).uppercased())
                    .font(.headline)
                    .foregroundStyle(.white)
            }
    }

    private var raterName: String {
        if isForRestaurant {
            // For restaurant profile, show foodie info
            if let igUsername = rating.rater?.igUsername {
                return "@\(igUsername)"
            }
            return rating.rater?.name ?? "Usuario"
        } else {
            // For foodie profile, show restaurant info
            return rating.rater?.restaurantProfiles?.first?.restaurantName ?? rating.rater?.name ?? "Restaurante"
        }
    }

    private var raterImageUrl: String? {
        if isForRestaurant {
            return rating.rater?.foodieProfile?.profilePicture
        } else {
            return rating.rater?.restaurantProfiles?.first?.profilePicture
        }
    }
}

// MARK: - Edit Foodie Profile View

struct EditFoodieProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var bio: String = ""
    @State private var city: String = ""
    @State private var state: String = ""
    @State private var country: String = ""
    @State private var isSaving = false
    @State private var showSuccess = false

    var body: some View {
        Form {
            // Bio Section
            Section(header: Text(String(localized: "Sobre ti"))) {
                TextField(String(localized: "Bio..."), text: $bio, axis: .vertical)
                    .lineLimit(3...6)
            }

            // Location Section
            Section(header: Text(String(localized: "Ubicacion"))) {
                TextField(String(localized: "Ciudad"), text: $city)
                TextField(String(localized: "Provincia"), text: $state)
                TextField(String(localized: "Pais"), text: $country)
            }

            // Social Networks (read-only info)
            if !viewModel.socialNetworks.isEmpty {
                Section(header: Text(String(localized: "Redes Sociales"))) {
                    ForEach(viewModel.socialNetworks) { network in
                        HStack {
                            Image(systemName: network.platform.icon)
                                .foregroundStyle(Color(hex: "E53935"))
                            Text("@\(network.username)")
                            Spacer()
                            Text(viewModel.formatFollowers(network.followers))
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            // Rates Section
            Section(header: Text(String(localized: "Tarifas"))) {
                if viewModel.rates.isEmpty {
                    Text(String(localized: "No tienes tarifas configuradas"))
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.rates) { rate in
                        HStack {
                            Text(rate.description)
                            Spacer()
                            Text(String(format: "%.0f€", rate.price))
                                .fontWeight(.semibold)
                        }
                    }
                }

                Text(String(localized: "Para modificar tarifas, usa la web de Solofoodies"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(String(localized: "Editar Perfil"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    saveProfile()
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text(String(localized: "Guardar"))
                    }
                }
                .disabled(isSaving)
            }
        }
        .onAppear {
            loadCurrentData()
        }
        .alert(String(localized: "Perfil actualizado"), isPresented: $showSuccess) {
            Button(String(localized: "Aceptar")) {
                dismiss()
            }
        }
    }

    private func loadCurrentData() {
        bio = viewModel.foodieProfile?.bio ?? ""
        city = viewModel.foodieProfile?.address?.city ?? ""
        state = viewModel.foodieProfile?.address?.state ?? ""
        country = viewModel.foodieProfile?.address?.country ?? ""
    }

    private func saveProfile() {
        isSaving = true

        Task {
            do {
                // Update bio
                try await ProfileService.shared.updateFoodieProfile(
                    bio: bio.isEmpty ? nil : bio,
                    profilePicture: nil
                )

                // Update address if changed
                if !city.isEmpty || !state.isEmpty || !country.isEmpty {
                    let address = Address(
                        line: viewModel.foodieProfile?.address?.line,
                        city: city,
                        state: state,
                        zipCode: viewModel.foodieProfile?.address?.zipCode,
                        country: country,
                        countryIso: viewModel.foodieProfile?.address?.countryIso
                    )
                    try await ProfileService.shared.updateFoodieAddress(address)
                }

                // Reload profile
                if let userId = authViewModel.currentUser?.id {
                    await viewModel.loadProfileData(for: userId)
                }

                showSuccess = true
            } catch {
                viewModel.error = String(localized: "Error al guardar el perfil")
            }
            isSaving = false
        }
    }
}

#Preview {
    FoodieProfileView()
        .environmentObject(AuthViewModel())
}
