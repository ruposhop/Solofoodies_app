//
//  ExploreFoodiesView.swift
//  Solofoodies
//

import SwiftUI

struct ExploreFoodiesView: View {
    @StateObject private var viewModel = ExploreFoodiesViewModel()
    @State private var showFilters = false
    @State private var selectedFoodie: FoodieListItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search bar
                searchBar

                // Content
                Group {
                    if viewModel.isLoading && viewModel.foodies.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.foodies.isEmpty {
                        emptyState
                    } else {
                        foodiesList
                    }
                }
            }
            .navigationTitle(String(localized: "Explorar Foodies"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: viewModel.selectedProvince != "todos" ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                if viewModel.foodies.isEmpty {
                    await viewModel.loadProvinces()
                    await viewModel.loadFoodies()
                }
            }
            .sheet(isPresented: $showFilters) {
                ProvinceFilterSheet(
                    provinces: viewModel.provinces,
                    selectedProvince: viewModel.selectedProvince
                ) { province in
                    Task {
                        await viewModel.applyProvinceFilter(province)
                    }
                }
            }
            .sheet(item: $selectedFoodie) { foodie in
                NavigationStack {
                    FoodieDetailView(foodie: foodie)
                }
            }
        }
    }

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(String(localized: "Buscar por nombre o @usuario"), text: $viewModel.searchText)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .onSubmit {
                    Task {
                        await viewModel.search()
                    }
                }

            if !viewModel.searchText.isEmpty {
                Button {
                    Task {
                        await viewModel.clearSearch()
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding()
    }

    private var foodiesList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.foodies) { foodie in
                    FoodieCardView(foodie: foodie)
                        .onTapGesture {
                            selectedFoodie = foodie
                        }
                        .task {
                            await viewModel.loadMoreIfNeeded(currentItem: foodie)
                        }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding()
                }
            }
            .padding()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.circle.badge.questionmark")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(String(localized: "No se encontraron foodies"))
                .font(.headline)

            if !viewModel.searchText.isEmpty || viewModel.selectedProvince != "todos" {
                Text(String(localized: "Prueba con otros filtros"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Button {
                    Task {
                        viewModel.selectedProvince = "todos"
                        await viewModel.clearSearch()
                    }
                } label: {
                    Text(String(localized: "Limpiar filtros"))
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Foodie Card

struct FoodieCardView: View {
    let foodie: FoodieListItem

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            if let avatar = foodie.profilePicture, let url = URL(string: avatar) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    avatarPlaceholder
                }
                .frame(width: 60, height: 60)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(foodie.displayName)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 4) {
                    Image(systemName: "at")
                        .font(.caption2)
                    Text(foodie.igUsername)
                        .font(.subheadline)
                }
                .foregroundStyle(.secondary)

                // Stats row
                HStack(spacing: 12) {
                    // Followers
                    HStack(spacing: 4) {
                        Image(systemName: "person.2.fill")
                            .font(.caption2)
                        Text(formatFollowers(foodie.instagramFollowers))
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)

                    // Engagement
                    if foodie.engagementRate > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.caption2)
                            Text(String(format: "%.1f%%", foodie.engagementRate))
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    // Rating
                    if let rating = foodie.avgRating, rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                            Text(String(format: "%.1f", rating))
                                .font(.caption)
                        }
                    }
                }
            }

            Spacer()

            // Location & arrow
            VStack(alignment: .trailing, spacing: 4) {
                if !foodie.city.isEmpty {
                    HStack(spacing: 2) {
                        Image(systemName: "mappin")
                            .font(.caption2)
                        Text(foodie.city)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Color(.systemGray5))
            .frame(width: 60, height: 60)
            .overlay {
                Text(foodie.displayName.prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundStyle(.secondary)
            }
    }

    private func formatFollowers(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.0fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}

// MARK: - Province Filter Sheet

struct ProvinceFilterSheet: View {
    let provinces: [ProvinceWithCountry]
    let selectedProvince: String
    let onSelect: (String) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Button {
                    onSelect("todos")
                    dismiss()
                } label: {
                    HStack {
                        Text(String(localized: "Todas las provincias"))
                        Spacer()
                        if selectedProvince == "todos" {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Color(hex: "E53935"))
                        }
                    }
                }
                .foregroundColor(.primary)

                ForEach(provinces) { province in
                    Button {
                        onSelect(province.name)
                        dismiss()
                    } label: {
                        HStack {
                            Text(province.name)
                            Spacer()
                            if selectedProvince == province.name {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: "E53935"))
                            }
                        }
                    }
                    .foregroundColor(.primary)
                }
            }
            .navigationTitle(String(localized: "Filtrar por provincia"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Foodie Detail View

struct FoodieDetailView: View {
    let foodie: FoodieListItem
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    // Avatar
                    if let avatar = foodie.profilePicture, let url = URL(string: avatar) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Circle()
                                .fill(Color(.systemGray4))
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(Color(.systemGray4))
                            .frame(width: 100, height: 100)
                            .overlay {
                                Text(foodie.displayName.prefix(1).uppercased())
                                    .font(.largeTitle.bold())
                                    .foregroundStyle(.secondary)
                            }
                    }

                    // Name
                    Text(foodie.displayName)
                        .font(.title2.bold())

                    // Username
                    HStack(spacing: 4) {
                        Image(systemName: "at")
                        Text(foodie.igUsername)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    // Location
                    if !foodie.city.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundStyle(Color(hex: "E53935"))
                            Text(foodie.city)
                        }
                        .font(.subheadline)
                    }
                }
                .padding()

                Divider()

                // Stats
                HStack(spacing: 0) {
                    statItem(
                        value: formatFollowers(foodie.instagramFollowers),
                        label: String(localized: "Seguidores")
                    )

                    Divider()
                        .frame(height: 40)

                    statItem(
                        value: String(format: "%.1f%%", foodie.engagementRate),
                        label: String(localized: "Engagement")
                    )

                    Divider()
                        .frame(height: 40)

                    statItem(
                        value: "\(foodie.completedCollaborations ?? 0)",
                        label: String(localized: "Colabs")
                    )

                    if let rating = foodie.avgRating, rating > 0 {
                        Divider()
                            .frame(height: 40)

                        statItem(
                            value: String(format: "%.1f", rating),
                            label: String(localized: "Rating"),
                            icon: "star.fill"
                        )
                    }
                }
                .padding(.horizontal)

                // Bio
                if let bio = foodie.bio, !bio.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Bio"))
                            .font(.headline)

                        Text(bio)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }

                // Social Networks
                if let networks = foodie.socialNetworks, !networks.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "Redes sociales"))
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(networks) { network in
                            HStack {
                                Image(systemName: network.platform.icon)
                                    .foregroundStyle(Color(hex: "E53935"))
                                    .frame(width: 24)

                                Text(network.platform.displayName)
                                    .font(.subheadline)

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(formatFollowers(network.followers))
                                        .font(.subheadline.bold())
                                    if network.engagementRate > 0 {
                                        Text(String(format: "%.1f%% eng.", network.engagementRate))
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }

                // Rates
                if let rates = foodie.rates, !rates.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "Tarifas"))
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(rates) { rate in
                            HStack {
                                Text(rate.description)
                                    .font(.subheadline)
                                    .lineLimit(2)

                                Spacer()

                                Text(String(format: "%.0f€", rate.price))
                                    .font(.subheadline.bold())
                                    .foregroundStyle(Color(hex: "E53935"))
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }

                // Trips
                if let trips = foodie.trips, !trips.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "Proximos viajes"))
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(trips.filter { $0.isUpcoming || $0.isActive }) { trip in
                            HStack {
                                Image(systemName: "airplane")
                                    .foregroundStyle(Color(hex: "E53935"))

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(trip.state)
                                        .font(.subheadline.bold())
                                    Text(trip.country)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                VStack(alignment: .trailing, spacing: 2) {
                                    Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                    Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .padding(.horizontal)
                        }
                    }
                }

                Spacer()
                    .frame(height: 100)
            }
        }
        .overlay(alignment: .bottom) {
            // Action buttons
            VStack(spacing: 0) {
                Divider()

                HStack(spacing: 12) {
                    Button {
                        // TODO: Open chat
                    } label: {
                        HStack {
                            Image(systemName: "message.fill")
                            Text(String(localized: "Mensaje"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                    }

                    Button {
                        // TODO: Invite to collaboration
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                            Text(String(localized: "Invitar"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "E53935"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func statItem(value: String, label: String, icon: String? = nil) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
                Text(value)
                    .font(.headline)
            }
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private func formatFollowers(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        } else if count >= 1_000 {
            return String(format: "%.0fK", Double(count) / 1_000)
        }
        return "\(count)"
    }
}

#Preview {
    ExploreFoodiesView()
}
