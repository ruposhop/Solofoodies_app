//
//  RestaurantProfileView.swift
//  Solofoodies
//

import SwiftUI

struct RestaurantProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showingSidebar = false

    private var user: User? { authViewModel.currentUser }
    private var activeRestaurant: RestaurantProfile? {
        guard let activeId = user?.activeRestaurantId else {
            return user?.restaurants?.first
        }
        return user?.restaurants?.first(where: { $0.id == activeId }) ?? user?.restaurants?.first
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Profile Header Card
                    profileHeaderCard

                    // Stats Row
                    statsRow

                    // Contact Info Section
                    contactInfoSection

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
                RestaurantProfileSidebarView()
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
                // Restaurant Image
                restaurantImage

                // Name and Info
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(activeRestaurant?.restaurantName ?? "Mi Restaurante")
                            .font(.headline)

                        if activeRestaurant?.isVerified == true {
                            Image(systemName: "checkmark.seal.fill")
                                .foregroundStyle(.blue)
                                .font(.subheadline)
                        }
                    }

                    Text("@\(user?.igUsername ?? "restaurant")")
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "E53935"))

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
                }

                Spacer()

                // Edit Button
                NavigationLink {
                    Text("Editar Perfil") // TODO: Implement edit profile
                } label: {
                    Image(systemName: "pencil")
                        .font(.body)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "E53935"))
                        .clipShape(Circle())
                }
            }

            // Location
            if let address = activeRestaurant?.address,
               let city = address.city,
               let state = address.state {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.secondary)
                    Text("\(city), \(state)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Spacer()
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

    private var restaurantImage: some View {
        Group {
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
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                restaurantPlaceholder
            }
        }
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
            .frame(width: 64, height: 64)
            .overlay {
                Text((activeRestaurant?.restaurantName ?? "R").prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundStyle(.white)
            }
    }

    // MARK: - Stats Row

    private var statsRow: some View {
        HStack(spacing: 0) {
            // Collaborations
            statItem(
                value: "0", // TODO: Get real collab count
                label: String(localized: "Colaboraciones")
            )

            Divider()
                .frame(height: 40)

            // Reviews
            statItem(
                value: "\(viewModel.ratingStats.totalRatings)",
                label: String(localized: "Resenas")
            )

            Divider()
                .frame(height: 40)

            // Rating
            statItem(
                value: viewModel.ratingStats.averageScore != nil ?
                    String(format: "%.1f", viewModel.ratingStats.averageScore!) : "-",
                label: String(localized: "Puntuacion")
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

    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title2.bold())

            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Contact Info Section

    private var contactInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Informacion de contacto"))
                .font(.title3.bold())

            VStack(spacing: 0) {
                contactRow(icon: "person.fill", label: String(localized: "Contacto"),
                           value: activeRestaurant?.contactName ?? user?.name ?? "-")

                Divider().padding(.leading, 44)

                contactRow(icon: "envelope.fill", label: String(localized: "Email"),
                           value: user?.email ?? "-")

                if let phone = activeRestaurant?.phone, !phone.isEmpty {
                    Divider().padding(.leading, 44)
                    contactRow(icon: "phone.fill", label: String(localized: "Telefono"),
                               value: phone)
                }

                if let cif = activeRestaurant?.cif, !cif.isEmpty {
                    Divider().padding(.leading, 44)
                    contactRow(icon: "doc.text.fill", label: "CIF",
                               value: cif)
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }

    private func contactRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.subheadline)
            }

            Spacer()
        }
        .padding()
    }

    // MARK: - Reviews Section

    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Resenas de foodies"))
                .font(.title3.bold())

            if viewModel.ratings.isEmpty {
                VStack(spacing: 8) {
                    Text(String(localized: "Sin resenas todavia"))
                        .foregroundStyle(.secondary)
                    Text(String(localized: "Las resenas de foodies apareceran aqui"))
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
                        RatingRow(rating: rating, viewModel: viewModel, isForRestaurant: true)
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

#Preview {
    RestaurantProfileView()
        .environmentObject(AuthViewModel())
}
