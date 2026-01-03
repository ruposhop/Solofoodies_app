//
//  CollaborationCardView.swift
//  Solofoodies
//

import SwiftUI

struct CollaborationCardView: View {
    let collaboration: PublicCollaboration

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Image
            ZStack(alignment: .topLeading) {
                if let imageUrl = collaboration.image ?? collaboration.restaurantProfile?.coverImage,
                   let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            placeholderImage
                        case .empty:
                            ProgressView()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        @unknown default:
                            placeholderImage
                        }
                    }
                } else {
                    placeholderImage
                }

                // Type badge
                HStack(spacing: 4) {
                    Image(systemName: collaboration.type.icon)
                        .font(.caption2)
                    Text(collaboration.type.displayName)
                        .font(.caption2.bold())
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial)
                .cornerRadius(12)
                .padding(8)
            }
            .frame(height: 140)
            .clipped()

            // Content
            VStack(alignment: .leading, spacing: 8) {
                // Restaurant name
                Text(collaboration.restaurantProfile?.restaurantName ?? "")
                    .font(.headline)
                    .lineLimit(1)

                // Location
                if !collaboration.displayLocation.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color(hex: "E53935"))
                        Text(collaboration.displayLocation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                // Details row
                HStack(spacing: 12) {
                    // Followers requirement
                    Label {
                        Text("\(formatFollowers(collaboration.minFollowers))+")
                            .font(.caption)
                    } icon: {
                        Image(systemName: "person.2.fill")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)

                    // Companions
                    if collaboration.maxCompanions > 0 {
                        Label {
                            Text("+\(collaboration.maxCompanions)")
                                .font(.caption)
                        } icon: {
                            Image(systemName: "person.fill")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }

                    Spacer()

                    // Credit info
                    Text(collaboration.creditDescription)
                        .font(.caption.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "E53935").opacity(0.1))
                        .foregroundStyle(Color(hex: "E53935"))
                        .cornerRadius(8)
                }
            }
            .padding(12)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 2)
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: collaboration.type.icon)
                    .font(.largeTitle)
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

#Preview {
    CollaborationCardView(
        collaboration: PublicCollaboration(
            id: "1",
            restaurantProfileId: "1",
            type: .influencerVisit,
            image: nil,
            requirements: "Test requirements",
            minFollowers: 5000,
            maxCompanions: 1,
            creditMode: "exchange",
            creditType: "percentage",
            creditValue: 100,
            allowFoodieRateProposal: false,
            availableDays: ["Lunes", "Martes"],
            locationIds: [],
            status: .open,
            isPrivate: false,
            createdAt: Date(),
            updatedAt: Date(),
            productName: nil,
            productRequirements: nil,
            quantityPerCreator: nil,
            productValue: nil,
            productValueCurrency: nil,
            productVariations: nil,
            shippingZoneName: nil,
            shipsWorldwide: nil,
            eventName: nil,
            venueName: nil,
            venueAddress: nil,
            eventCountry: nil,
            eventCountryIso: nil,
            eventCity: nil,
            eventProvince: nil,
            eventContactPerson: nil,
            eventContactPhone: nil,
            eventType: nil,
            eventDate: nil,
            eventStartTime: nil,
            eventEndTime: nil,
            creatorArrivalTime: nil,
            rsvpDeadline: nil,
            eventRequirements: nil,
            whatToExpect: nil,
            dressCode: nil,
            hashtags: nil,
            accountsToTag: nil,
            toneSuggestions: nil,
            title: nil,
            description: nil,
            city: "Madrid",
            restaurantProfile: RestaurantProfileData(
                id: "1",
                restaurantName: "Restaurante Demo",
                contactName: "Juan",
                coverImage: nil,
                bio: nil,
                followers: nil,
                profilePicture: nil,
                user: nil,
                address: nil,
                locations: nil
            ),
            collabLocations: nil,
            provinces: nil,
            collaborations: nil
        )
    )
    .padding()
}
