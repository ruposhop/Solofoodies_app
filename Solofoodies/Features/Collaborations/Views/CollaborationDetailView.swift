//
//  CollaborationDetailView.swift
//  Solofoodies
//

import SwiftUI

struct CollaborationDetailView: View {
    let collaboration: PublicCollaboration
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = CollaborationsViewModel()
    @State private var showApplySheet = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Header Image
                headerImage

                VStack(alignment: .leading, spacing: 20) {
                    // Restaurant Info
                    restaurantSection

                    Divider()

                    // Collaboration Details
                    detailsSection

                    // Requirements
                    if let requirements = collaboration.requirements, !requirements.isEmpty {
                        Divider()
                        requirementsSection(requirements)
                    }

                    // Available Days
                    if !collaboration.availableDays.isEmpty {
                        Divider()
                        daysSection
                    }

                    // Locations
                    if let locations = collaboration.collabLocations, !locations.isEmpty {
                        Divider()
                        locationsSection(locations)
                    }

                    // Type-specific sections
                    if collaboration.type == .delivery {
                        Divider()
                        deliverySection
                    }

                    if collaboration.type == .event {
                        Divider()
                        eventSection
                    }

                    Spacer()
                        .frame(height: 100)
                }
                .padding()
            }
        }
        .overlay(alignment: .bottom) {
            applyButton
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
        .sheet(isPresented: $showApplySheet) {
            ApplyCollaborationSheet(collaboration: collaboration, viewModel: viewModel) {
                dismiss()
            }
        }
        .alert(String(localized: "Error"), isPresented: .constant(viewModel.error != nil)) {
            Button(String(localized: "OK")) {
                viewModel.clearError()
            }
        } message: {
            Text(viewModel.error ?? "")
        }
    }

    // MARK: - Sections

    private var headerImage: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageUrl = collaboration.image ?? collaboration.restaurantProfile?.coverImage,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure, .empty:
                        placeholderImage
                    @unknown default:
                        placeholderImage
                    }
                }
            } else {
                placeholderImage
            }

            // Type badge
            HStack(spacing: 6) {
                Image(systemName: collaboration.type.icon)
                Text(collaboration.type.displayName)
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding()
        }
        .frame(height: 250)
        .clipped()
    }

    private var placeholderImage: some View {
        Rectangle()
            .fill(Color(.systemGray5))
            .overlay {
                Image(systemName: collaboration.type.icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.secondary)
            }
    }

    private var restaurantSection: some View {
        HStack(spacing: 12) {
            // Profile picture
            if let profilePic = collaboration.restaurantProfile?.profilePicture,
               let url = URL(string: profilePic) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Circle()
                        .fill(Color(.systemGray4))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            } else {
                Circle()
                    .fill(Color(.systemGray4))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "building.2")
                            .foregroundStyle(.secondary)
                    }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(collaboration.restaurantProfile?.restaurantName ?? "")
                    .font(.title3.bold())

                if let igUsername = collaboration.restaurantProfile?.user?.igUsername {
                    HStack(spacing: 4) {
                        Image(systemName: "at")
                        Text(igUsername)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                }
            }

            Spacer()
        }
    }

    private var detailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "Detalles"))
                .font(.headline)

            HStack(spacing: 24) {
                // Credit/Compensation
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "Compensacion"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(collaboration.creditDescription)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(hex: "E53935"))
                }

                // Min followers
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "Seguidores min."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatFollowers(collaboration.minFollowers))
                        .font(.subheadline.bold())
                }

                // Companions
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "Acompanantes"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("+\(collaboration.maxCompanions)")
                        .font(.subheadline.bold())
                }
            }

            if collaboration.allowFoodieRateProposal {
                HStack(spacing: 8) {
                    Image(systemName: "eurosign.circle.fill")
                        .foregroundStyle(Color(hex: "4CAF50"))
                    Text(String(localized: "Puedes proponer tu tarifa"))
                        .font(.subheadline)
                        .foregroundStyle(Color(hex: "4CAF50"))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(hex: "4CAF50").opacity(0.1))
                .cornerRadius(8)
            }
        }
    }

    private func requirementsSection(_ requirements: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Requisitos"))
                .font(.headline)

            Text(requirements)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Dias disponibles"))
                .font(.headline)

            FlowLayout(spacing: 8) {
                ForEach(collaboration.availableDays, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                }
            }
        }
    }

    private func locationsSection(_ locations: [CollaborationLocation]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Ubicaciones"))
                .font(.headline)

            ForEach(locations) { location in
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(Color(hex: "E53935"))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(location.name)
                            .font(.subheadline.bold())
                        Text("\(location.line), \(location.city)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
        }
    }

    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Informacion del producto"))
                .font(.headline)

            if let productName = collaboration.productName {
                detailRow(icon: "shippingbox", title: String(localized: "Producto"), value: productName)
            }

            if let quantity = collaboration.quantityPerCreator {
                detailRow(icon: "number", title: String(localized: "Cantidad"), value: "\(quantity) por creador")
            }

            if let value = collaboration.productValue {
                detailRow(icon: "tag", title: String(localized: "Valor"), value: String(format: "%.2f€", value))
            }

            if collaboration.shipsWorldwide == true {
                detailRow(icon: "globe", title: String(localized: "Envio"), value: String(localized: "Mundial"))
            }
        }
    }

    private var eventSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Detalles del evento"))
                .font(.headline)

            if let eventName = collaboration.eventName {
                detailRow(icon: "party.popper", title: String(localized: "Evento"), value: eventName)
            }

            if let venueName = collaboration.venueName {
                detailRow(icon: "building.2", title: String(localized: "Lugar"), value: venueName)
            }

            if let eventDate = collaboration.eventDate {
                detailRow(icon: "calendar", title: String(localized: "Fecha"), value: eventDate.formatted(date: .complete, time: .omitted))
            }

            if let startTime = collaboration.eventStartTime {
                detailRow(icon: "clock", title: String(localized: "Hora"), value: startTime)
            }

            if let dressCode = collaboration.dressCode {
                detailRow(icon: "tshirt", title: String(localized: "Dress code"), value: dressCode)
            }
        }
    }

    private func detailRow(icon: String, title: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(Color(hex: "E53935"))
                .frame(width: 24)

            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.subheadline.bold())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private var applyButton: some View {
        VStack(spacing: 0) {
            Divider()

            Button {
                showApplySheet = true
            } label: {
                Text(String(localized: "Solicitar colaboracion"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "E53935"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding()
            .background(.ultraThinMaterial)
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

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                self.size.width = max(self.size.width, x)
            }

            self.size.height = y + rowHeight
        }
    }
}

#Preview {
    NavigationStack {
        CollaborationDetailView(
            collaboration: PublicCollaboration(
                id: "1",
                restaurantProfileId: "1",
                type: .influencerVisit,
                image: nil,
                requirements: "Buscamos creadores de contenido que puedan compartir su experiencia gastronomica en nuestro restaurante.",
                minFollowers: 5000,
                maxCompanions: 1,
                creditMode: "exchange",
                creditType: "percentage",
                creditValue: 100,
                allowFoodieRateProposal: true,
                availableDays: ["Lunes", "Martes", "Miercoles"],
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
                    user: RestaurantUserData(id: "1", name: "Juan", igUsername: "restaurante_demo"),
                    address: nil,
                    locations: nil
                ),
                collabLocations: nil,
                provinces: nil,
                collaborations: nil
            )
        )
    }
}
