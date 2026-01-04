//
//  RestaurantCollaborationsView.swift
//  Solofoodies
//

import SwiftUI
import PhotosUI

struct RestaurantCollaborationsView: View {
    @StateObject private var viewModel = CollaborationsViewModel()
    @State private var selectedTab = 0
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented picker
                Picker(String(localized: "Vista"), selection: $selectedTab) {
                    Text(String(localized: "Ofertas")).tag(0)
                    Text(String(localized: "Solicitudes")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                Group {
                    if viewModel.isLoading && viewModel.myPublicCollaborations.isEmpty && viewModel.myCollaborations.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedTab == 0 {
                        offersContent
                    } else {
                        applicationsContent
                    }
                }
            }
            .navigationTitle(String(localized: "Colaboraciones"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .refreshable {
                if selectedTab == 0 {
                    await viewModel.loadMyPublicCollaborations()
                } else {
                    await viewModel.loadMyCollaborations()
                }
            }
            .task {
                await viewModel.loadMyPublicCollaborations()
                await viewModel.loadMyCollaborations()
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateCollaborationSheet(viewModel: viewModel) {
                    showCreateSheet = false
                    Task {
                        await viewModel.loadMyPublicCollaborations()
                    }
                }
            }
        }
    }

    // MARK: - Offers Content

    private var offersContent: some View {
        Group {
            if viewModel.myPublicCollaborations.isEmpty {
                emptyOffersState
            } else {
                offersList
            }
        }
    }

    private var offersList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(viewModel.myPublicCollaborations) { offer in
                    NavigationLink {
                        RestaurantOfferDetailView(offerId: offer.id)
                    } label: {
                        RestaurantOfferRow(offer: offer, viewModel: viewModel)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private var emptyOffersState: some View {
        VStack(spacing: 16) {
            Image(systemName: "megaphone.fill")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(String(localized: "No tienes ofertas activas"))
                .font(.headline)

            Text(String(localized: "Crea una colaboracion para atraer creadores de contenido"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                showCreateSheet = true
            } label: {
                HStack {
                    Image(systemName: "plus")
                    Text(String(localized: "Crear colaboracion"))
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color(hex: "E53935"))
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Applications Content

    private var applicationsContent: some View {
        Group {
            if viewModel.myCollaborations.isEmpty {
                emptyApplicationsState
            } else {
                applicationsList
            }
        }
    }

    private var applicationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Pending first
                let pending = viewModel.myCollaborations.filter { $0.status == .pending }
                if !pending.isEmpty {
                    sectionHeader(String(localized: "Pendientes"), count: pending.count)

                    ForEach(pending) { application in
                        NavigationLink {
                            RestaurantApplicationDetailView(applicationId: application.id)
                        } label: {
                            ApplicationRow(application: application)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // Active
                let active = viewModel.myCollaborations.filter { $0.status == .accepted }
                if !active.isEmpty {
                    sectionHeader(String(localized: "Activas"), count: active.count)

                    ForEach(active) { application in
                        NavigationLink {
                            RestaurantApplicationDetailView(applicationId: application.id)
                        } label: {
                            ApplicationRow(application: application)
                        }
                        .buttonStyle(.plain)
                    }
                }

                // History
                let history = viewModel.myCollaborations.filter { $0.status == .completed || $0.status == .rejected || $0.status == .cancelled }
                if !history.isEmpty {
                    sectionHeader(String(localized: "Historial"), count: history.count)

                    ForEach(history) { application in
                        NavigationLink {
                            RestaurantApplicationDetailView(applicationId: application.id)
                        } label: {
                            ApplicationRow(application: application)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding()
        }
    }

    private func sectionHeader(_ title: String, count: Int) -> some View {
        HStack {
            Text(title)
                .font(.headline)
            Text("\(count)")
                .font(.caption.bold())
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color(.systemGray5))
                .cornerRadius(8)
            Spacer()
        }
        .padding(.top, 8)
    }

    private var emptyApplicationsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.crop.rectangle.stack")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(String(localized: "No hay solicitudes"))
                .font(.headline)

            Text(String(localized: "Las solicitudes de los creadores aparaceran aqui"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Restaurant Offer Row

struct RestaurantOfferRow: View {
    let offer: PublicCollaboration
    @ObservedObject var viewModel: CollaborationsViewModel

    var body: some View {
        HStack(spacing: 12) {
            // Image
            if let imageUrl = offer.image,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            } else {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .overlay {
                        Image(systemName: offer.type.icon)
                            .foregroundStyle(.secondary)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(offer.displayTitle)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    Text(offer.type.displayName)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Text("•")
                        .foregroundStyle(.secondary)

                    Text("\(offer.collaborations?.count ?? 0) \(String(localized: "solicitudes"))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                // Status
                HStack(spacing: 4) {
                    Circle()
                        .fill(statusColor(for: offer.status))
                        .frame(width: 8, height: 8)
                    Text(statusText(for: offer.status))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            // Menu
            Menu {
                if offer.status == .open {
                    Button {
                        Task {
                            await viewModel.updatePublicCollaborationStatus(id: offer.id, status: .paused)
                        }
                    } label: {
                        Label(String(localized: "Pausar"), systemImage: "pause.circle")
                    }
                } else if offer.status == .paused {
                    Button {
                        Task {
                            await viewModel.updatePublicCollaborationStatus(id: offer.id, status: .open)
                        }
                    } label: {
                        Label(String(localized: "Reactivar"), systemImage: "play.circle")
                    }
                }

                Button(role: .destructive) {
                    Task {
                        await viewModel.deletePublicCollaboration(id: offer.id)
                    }
                } label: {
                    Label(String(localized: "Eliminar"), systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }

    private func statusColor(for status: CollaborationStatus) -> Color {
        switch status {
        case .open: return Color(hex: "4CAF50")
        case .paused: return Color(hex: "FFA500")
        case .closed, .archived, .cancelled: return Color(hex: "9E9E9E")
        case .completed: return Color(hex: "2196F3")
        }
    }

    private func statusText(for status: CollaborationStatus) -> String {
        switch status {
        case .open: return String(localized: "Activa")
        case .paused: return String(localized: "Pausada")
        case .closed: return String(localized: "Cerrada")
        case .archived: return String(localized: "Archivada")
        case .completed: return String(localized: "Completada")
        case .cancelled: return String(localized: "Cancelada")
        }
    }
}

// MARK: - Application Row

struct ApplicationRow: View {
    let application: Collaboration

    var body: some View {
        HStack(spacing: 12) {
            // Foodie avatar
            Circle()
                .fill(Color(.systemGray5))
                .frame(width: 50, height: 50)
                .overlay {
                    Text(application.foodie?.name.prefix(1).uppercased() ?? "?")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(application.foodie?.name ?? "")
                    .font(.headline)
                    .lineLimit(1)

                if let igUsername = application.foodie?.igUsername {
                    HStack(spacing: 2) {
                        Image(systemName: "at")
                            .font(.caption2)
                        Text(igUsername)
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }

                // Status
                Text(application.status.displayName)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: application.status.color).opacity(0.15))
                    .foregroundStyle(Color(hex: application.status.color))
                    .cornerRadius(4)
            }

            Spacer()

            // Date & arrow
            VStack(alignment: .trailing, spacing: 4) {
                Text(application.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)

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
}

// MARK: - Restaurant Offer Detail View

struct RestaurantOfferDetailView: View {
    let offerId: String
    @StateObject private var viewModel = CollaborationsViewModel()

    private var offer: PublicCollaboration? {
        viewModel.selectedPublicCollaboration
    }

    var body: some View {
        Group {
            if viewModel.isLoading && offer == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let offer = offer {
                offerContent(offer)
            } else {
                Text(String(localized: "No se pudo cargar"))
            }
        }
        .navigationTitle(String(localized: "Oferta"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if let offer = offer {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        if offer.status == .open {
                            Button {
                                Task {
                                    _ = await viewModel.updatePublicCollaborationStatus(id: offer.id, status: .paused)
                                    await viewModel.getPublicCollaboration(id: offerId)
                                }
                            } label: {
                                Label(String(localized: "Pausar"), systemImage: "pause.circle")
                            }
                        } else if offer.status == .paused {
                            Button {
                                Task {
                                    _ = await viewModel.updatePublicCollaborationStatus(id: offer.id, status: .open)
                                    await viewModel.getPublicCollaboration(id: offerId)
                                }
                            } label: {
                                Label(String(localized: "Reactivar"), systemImage: "play.circle")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .task {
            await viewModel.getPublicCollaboration(id: offerId)
        }
        .refreshable {
            await viewModel.getPublicCollaboration(id: offerId)
        }
    }

    private func offerContent(_ offer: PublicCollaboration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header with image
                offerHeader(offer)

                // Status badge
                statusSection(offer)

                // Details section
                detailsSection(offer)

                // Requirements
                if let requirements = offer.requirements, !requirements.isEmpty {
                    requirementsSection(requirements)
                }

                // Locations
                if let locations = offer.collabLocations, !locations.isEmpty {
                    locationsSection(locations)
                }

                // Applications
                applicationsSection(offer)
            }
            .padding()
        }
    }

    private func offerHeader(_ offer: PublicCollaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let imageUrl = offer.image,
               let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .fill(Color(.systemGray5))
                }
                .frame(height: 180)
                .cornerRadius(12)
                .clipped()
            }

            Text(offer.displayTitle)
                .font(.title2.bold())

            HStack(spacing: 16) {
                Label(offer.type.displayName, systemImage: offer.type.icon)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Label(offer.creditDescription, systemImage: "creditcard")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func statusSection(_ offer: PublicCollaboration) -> some View {
        HStack {
            Circle()
                .fill(offerStatusColor(for: offer.status))
                .frame(width: 10, height: 10)
            Text(offerStatusText(for: offer.status))
                .font(.subheadline.bold())
            Spacer()
            Text(String(localized: "Creada \(offer.createdAt.formatted(date: .abbreviated, time: .omitted))"))
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func detailsSection(_ offer: PublicCollaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Detalles"))
                .font(.headline)

            VStack(spacing: 0) {
                detailRow(label: String(localized: "Min. seguidores"), value: "\(offer.minFollowers)")
                Divider()
                detailRow(label: String(localized: "Max. acompanantes"), value: "\(offer.maxCompanions)")
                Divider()
                detailRow(label: String(localized: "Dias disponibles"), value: offer.availableDays.joined(separator: ", "))

                if offer.allowFoodieRateProposal {
                    Divider()
                    detailRow(label: String(localized: "Tarifa propuesta"), value: String(localized: "Permitida"))
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private func detailRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
        }
        .padding(.vertical, 4)
    }

    private func requirementsSection(_ requirements: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Requisitos"))
                .font(.headline)

            Text(requirements)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemGray6))
                .cornerRadius(12)
        }
    }

    private func locationsSection(_ locations: [CollaborationLocation]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Ubicaciones"))
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(locations) { location in
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(Color(hex: "E53935"))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(location.name)
                                .font(.subheadline.bold())
                            Text("\(location.city), \(location.country)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }

    private func applicationsSection(_ offer: PublicCollaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "Solicitudes"))
                    .font(.headline)
                Spacer()
                Text("\(offer.collaborations?.count ?? 0)")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
            }

            if let collabs = offer.collaborations, collabs.isEmpty {
                Text(String(localized: "No hay solicitudes todavia"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            } else {
                Text(String(localized: "Ver las solicitudes en la pestana de Solicitudes"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
            }
        }
    }

    private func offerStatusColor(for status: CollaborationStatus) -> Color {
        switch status {
        case .open: return Color(hex: "4CAF50")
        case .paused: return Color(hex: "FFA500")
        case .closed, .archived, .cancelled: return Color(hex: "9E9E9E")
        case .completed: return Color(hex: "2196F3")
        }
    }

    private func offerStatusText(for status: CollaborationStatus) -> String {
        switch status {
        case .open: return String(localized: "Activa")
        case .paused: return String(localized: "Pausada")
        case .closed: return String(localized: "Cerrada")
        case .archived: return String(localized: "Archivada")
        case .completed: return String(localized: "Completada")
        case .cancelled: return String(localized: "Cancelada")
        }
    }
}

struct RestaurantApplicationDetailView: View {
    let applicationId: String
    @StateObject private var viewModel = CollaborationsViewModel()

    private var application: Collaboration? {
        viewModel.selectedCollaboration
    }

    var body: some View {
        Group {
            if viewModel.isLoading && application == nil {
                ProgressView()
            } else if let app = application {
                applicationContent(app)
            } else {
                Text(String(localized: "No se pudo cargar"))
            }
        }
        .navigationTitle(String(localized: "Solicitud"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getCollaboration(id: applicationId)
        }
    }

    private func applicationContent(_ app: Collaboration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Foodie info
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 60, height: 60)
                        .overlay {
                            Text(app.foodie?.name.prefix(1).uppercased() ?? "?")
                                .font(.title2.bold())
                                .foregroundStyle(.secondary)
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text(app.foodie?.name ?? "")
                            .font(.title3.bold())

                        if let ig = app.foodie?.igUsername {
                            HStack(spacing: 4) {
                                Image(systemName: "camera.fill")
                                Text("@\(ig)")
                            }
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Status
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Estado"))
                        .font(.headline)

                    Text(app.status.displayName)
                        .font(.subheadline.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: app.status.color).opacity(0.15))
                        .foregroundStyle(Color(hex: app.status.color))
                        .cornerRadius(8)
                }

                // Scheduled Date (if foodie has selected one)
                if let scheduledDate = app.scheduledDate {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Fecha de visita"))
                            .font(.headline)

                        HStack(spacing: 12) {
                            Image(systemName: "calendar")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "E53935"))

                            VStack(alignment: .leading, spacing: 2) {
                                Text(scheduledDate.formatted(date: .long, time: .omitted))
                                    .font(.subheadline.bold())
                                Text(scheduledDate.formatted(date: .omitted, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }

                // Selected Location (if any)
                if let locationName = app.selectedLocationName {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Ubicación"))
                            .font(.headline)

                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.title2)
                                .foregroundStyle(Color(hex: "E53935"))

                            Text(locationName)
                                .font(.subheadline)

                            Spacer()
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                }

                // Message
                if let message = app.message, !message.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Mensaje"))
                            .font(.headline)

                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                    }
                }

                // Details
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Detalles"))
                        .font(.headline)

                    HStack {
                        Text(String(localized: "Personas"))
                        Spacer()
                        Text("\(app.numberOfPeople ?? 1)")
                            .fontWeight(.semibold)
                    }

                    if let rate = app.proposedRate, rate > 0 {
                        Divider()
                        HStack {
                            Text(String(localized: "Tarifa propuesta"))
                            Spacer()
                            Text(String(format: "%.2f€", rate))
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(hex: "E53935"))
                        }
                    }

                    if let requirements = app.specialRequirements, !requirements.isEmpty {
                        Divider()
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "Requisitos especiales"))
                            Text(requirements)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                // Actions
                if app.status == .pending {
                    VStack(spacing: 12) {
                        Button {
                            Task {
                                await viewModel.updateCollaborationStatus(id: app.id, status: .accepted)
                            }
                        } label: {
                            Text(String(localized: "Aceptar solicitud"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "E53935"))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }

                        Button {
                            Task {
                                await viewModel.updateCollaborationStatus(id: app.id, status: .rejected)
                            }
                        } label: {
                            Text(String(localized: "Rechazar"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray5))
                                .foregroundColor(.primary)
                                .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Create Collaboration Sheet

struct CreateCollaborationSheet: View {
    @ObservedObject var viewModel: CollaborationsViewModel
    let onSuccess: () -> Void
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel

    // Current step
    @State private var currentStep = 0

    // Image & Locations
    @State private var selectedImageURL: String? = nil
    @State private var selectedLocationIds: Set<String> = []
    @State private var isLoadingLastCollab = true
    @State private var restaurantLocations: [CollaborationLocation] = []
    @State private var isLoadingLocations = false

    // Image picker
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isUploadingImage = false

    // Common fields
    @State private var selectedType: CollaborationType = .influencerVisit
    @State private var minFollowers: String = "10000"
    @State private var maxCompanions: String = "1"
    @State private var creditMode: String = "exchange"
    @State private var creditValue: String = "50"
    @State private var requirements: String = ""
    @State private var availableDays: Set<String> = []
    @State private var allowFoodieRateProposal = false
    @State private var isCreating = false

    // Optional date range
    @State private var hasDates = false
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date().addingTimeInterval(30 * 24 * 60 * 60)

    // DELIVERY specific
    @State private var productName: String = ""
    @State private var productRequirements: String = ""
    @State private var quantityPerCreator: String = "1"
    @State private var productValue: String = ""
    @State private var productVariations: String = ""
    @State private var shipsWorldwide = false

    // EVENT specific
    @State private var eventName: String = ""
    @State private var eventType: String = "PRIVATE"
    @State private var venueName: String = ""
    @State private var venueAddress: String = ""
    @State private var eventCity: String = ""
    @State private var eventProvince: String = ""
    @State private var eventCountry: String = "España"
    @State private var eventContactPerson: String = ""
    @State private var eventContactPhone: String = ""
    @State private var eventDate: Date = Date()
    @State private var eventStartTime: Date = Date()
    @State private var eventEndTime: Date = Date()
    @State private var creatorArrivalTime: Date = Date()
    @State private var rsvpDeadline: Date = Date()
    @State private var hasStartTime = false
    @State private var hasEndTime = false
    @State private var hasArrivalTime = false
    @State private var hasRsvpDeadline = false
    @State private var eventRequirements: String = ""
    @State private var whatToExpect: Set<String> = []
    @State private var dressCode: String = ""
    @State private var hashtags: String = ""
    @State private var accountsToTag: String = ""
    @State private var toneSuggestions: String = ""

    // Default requirements
    private let defaultRequirements = """
Queremos invitarte a vivir una experiencia gastronómica en nuestro restaurante y compartirla con tu comunidad. Disfruta de nuestros platos y el ambiente del lugar, y cuéntale a tus seguidores por qué somos un plan perfecto para disfrutar buena comida y buenos momentos.
A cambio, nos gustaría que publiques un reel y algunas stories mostrando tu experiencia, mencionando nuestro perfil y ubicación, dentro de los 7 días posteriores a tu visita.
"""

    private let weekDays = ["Lun", "Mar", "Mié", "Jue", "Vie", "Sáb", "Dom"]
    private let weekDaysFull = ["Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado", "Domingo"]

    private let creditModes: [(id: String, label: String, icon: String)] = [
        ("exchange", "Intercambio", "arrow.triangle.2.circlepath"),
        ("credit", "Crédito", "creditcard"),
        ("discount", "Descuento", "percent"),
        ("payment", "Pago", "eurosign.circle")
    ]

    private let eventTypes: [(id: String, label: String)] = [
        ("PRIVATE", "Evento privado"),
        ("PUBLIC", "Evento público"),
        ("POPUP", "Pop-up"),
        ("LAUNCH", "Launch party"),
        ("WORKSHOP", "Workshop/Clase"),
        ("BRAND_EXPERIENCE", "Brand experience"),
        ("OTHER", "Otro")
    ]

    private let whatToExpectOptions: [(id: String, label: String, icon: String)] = [
        ("FOOD_DRINKS", "Comida y bebidas", "fork.knife"),
        ("GIFT_BAG", "Gift bag / producto", "gift"),
        ("LIVE_MUSIC", "Música en vivo / DJ", "music.note"),
        ("BRAND_PRESENTATION", "Presentación de marca", "person.wave.2"),
        ("NETWORKING", "Networking / meet-up", "person.3"),
        ("GIVEAWAYS", "Sorteos o concursos", "star"),
        ("PHOTOGRAPHY", "Fotografía profesional", "camera")
    ]

    private var totalSteps: Int {
        switch selectedType {
        case .influencerVisit: return 4  // Type -> Photo/Location -> Details -> Compensation
        case .delivery: return 4         // Type -> Photo/Product -> Shipping -> Compensation
        case .event: return 5            // Type -> Photo/Event -> Location/Time -> Details -> Compensation
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                progressBar

                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        switch currentStep {
                        case 0:
                            typeSelectionStep
                        case 1:
                            photoAndBasicStep
                        case 2:
                            typeSpecificStep2
                        case 3:
                            typeSpecificStep3
                        case 4:
                            typeSpecificStep4
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))

                // Navigation buttons
                navigationButtons
            }
            .navigationTitle(stepTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .presentationDetents([.large])
        .onAppear {
            availableDays = Set(weekDaysFull)
            requirements = defaultRequirements
            loadLastCollaboration()
        }
        .task {
            await loadRestaurantLocations()
        }
    }

    private func loadLastCollaboration() {
        // Preload from last collaboration if available
        if let lastCollab = viewModel.myPublicCollaborations.first(where: { $0.type == .influencerVisit }) {
            selectedImageURL = lastCollab.image
            minFollowers = "\(lastCollab.minFollowers)"
            maxCompanions = "\(lastCollab.maxCompanions)"
            creditMode = lastCollab.creditMode
            creditValue = "\(lastCollab.creditValue)"
            allowFoodieRateProposal = lastCollab.allowFoodieRateProposal
            availableDays = Set(lastCollab.availableDays)
            if let reqs = lastCollab.requirements, !reqs.isEmpty {
                requirements = reqs
            }
            // Preload locations from last collab
            if let locationIds = lastCollab.collabLocations?.map({ $0.id }) {
                selectedLocationIds = Set(locationIds)
            }
        }
        isLoadingLastCollab = false
    }

    private func loadRestaurantLocations() async {
        isLoadingLocations = true

        // First, fetch restaurants from API since /auth/me doesn't include them
        var availableRestaurants: [RestaurantProfile] = []

        do {
            let response: MyRestaurantsResponse = try await APIClient.shared.get(.myRestaurants)
            availableRestaurants = response.restaurants ?? []
            print("✅ Fetched \(availableRestaurants.count) restaurants from API")
        } catch {
            print("❌ Error fetching restaurants: \(error)")
            // Fallback to authViewModel if API fails
            availableRestaurants = authViewModel.restaurants.isEmpty
                ? (authViewModel.currentUser?.restaurants ?? [])
                : authViewModel.restaurants
        }

        print("🔍 Available restaurants count: \(availableRestaurants.count)")

        let restaurant: RestaurantProfile?
        if let activeId = authViewModel.activeRestaurantId ?? authViewModel.currentUser?.activeRestaurantId {
            restaurant = availableRestaurants.first { $0.id == activeId }
            print("🏪 Looking for active restaurant with ID: \(activeId)")
        } else {
            restaurant = availableRestaurants.first
        }

        guard let restaurant = restaurant else {
            print("❌ No restaurant found for user. User: \(authViewModel.currentUser?.name ?? "nil"), Role: \(authViewModel.currentUser?.role.rawValue ?? "nil")")
            isLoadingLocations = false
            return
        }

        print("🏪 Loading locations for restaurant: \(restaurant.restaurantName) (ID: \(restaurant.id))")

        do {
            // Try to get locations from API - returns array directly, not wrapped in object
            let locations: [CollaborationLocation] = try await APIClient.shared.get(
                .restaurantLocations(restaurantId: restaurant.id)
            )

            if !locations.isEmpty {
                print("✅ Loaded \(locations.count) locations from API")
                restaurantLocations = locations
            } else {
                print("⚠️ No locations in response, using restaurant address as fallback")
                // Use restaurant address as fallback location
                if let address = restaurant.address {
                    let fallbackLocation = CollaborationLocation(
                        id: restaurant.id,
                        name: restaurant.restaurantName,
                        line: address.line ?? "",
                        city: address.city ?? "",
                        state: address.state,
                        zipCode: address.zipCode,
                        country: address.country ?? "España",
                        countryIso: address.countryIso,
                        contactName: nil,
                        contactPhone: nil,
                        coverManagerSlug: nil,
                        restaurantProfileId: restaurant.id,
                        isActive: true,
                        createdAt: nil,
                        updatedAt: nil
                    )
                    restaurantLocations = [fallbackLocation]
                }
            }

            // If we have locations and none selected, select all by default
            if !restaurantLocations.isEmpty && selectedLocationIds.isEmpty {
                selectedLocationIds = Set(restaurantLocations.map { $0.id })
            }
        } catch {
            print("❌ Error loading locations: \(error)")

            // Fallback: use restaurant address
            if let address = restaurant.address {
                print("⚠️ Using restaurant address as fallback due to error")
                let fallbackLocation = CollaborationLocation(
                    id: restaurant.id,
                    name: restaurant.restaurantName,
                    line: address.line ?? "",
                    city: address.city ?? "",
                    state: address.state,
                    zipCode: address.zipCode,
                    country: address.country ?? "España",
                    countryIso: address.countryIso,
                    contactName: nil,
                    contactPhone: nil,
                    coverManagerSlug: nil,
                    restaurantProfileId: restaurant.id,
                    isActive: true,
                    createdAt: nil,
                    updatedAt: nil
                )
                restaurantLocations = [fallbackLocation]
                selectedLocationIds = Set([restaurant.id])
            }
        }

        isLoadingLocations = false
    }

    private var stepTitle: String {
        switch currentStep {
        case 0: return String(localized: "Tipo de colaboración")
        case 1:
            switch selectedType {
            case .influencerVisit: return String(localized: "Foto y ubicación")
            case .delivery: return String(localized: "Foto y producto")
            case .event: return String(localized: "Foto e información")
            }
        case 2:
            switch selectedType {
            case .influencerVisit: return String(localized: "Requisitos")
            case .delivery: return String(localized: "Envío")
            case .event: return String(localized: "Ubicación y horario")
            }
        case 3:
            switch selectedType {
            case .influencerVisit: return String(localized: "Compensación")
            case .delivery: return String(localized: "Compensación")
            case .event: return String(localized: "Detalles del evento")
            }
        case 4:
            return String(localized: "Compensación")
        default: return ""
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .fill(step <= currentStep ? Color(hex: "E53935") : Color(.systemGray4))
                    .frame(height: 4)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Step 0: Type Selection

    private var typeSelectionStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(String(localized: "¿Qué tipo de colaboración quieres crear?"))
                .font(.title3.weight(.semibold))

            VStack(spacing: 12) {
                ForEach(CollaborationType.allCases, id: \.self) { type in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedType = type
                        }
                    } label: {
                        HStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(selectedType == type ? Color(hex: "E53935").opacity(0.1) : Color(.systemGray6))
                                    .frame(width: 56, height: 56)

                                Image(systemName: type.icon)
                                    .font(.title2)
                                    .foregroundStyle(selectedType == type ? Color(hex: "E53935") : .secondary)
                            }

                            VStack(alignment: .leading, spacing: 4) {
                                Text(type.displayName)
                                    .font(.headline)
                                    .foregroundStyle(.primary)

                                Text(typeDescription(type))
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Circle()
                                .stroke(selectedType == type ? Color(hex: "E53935") : Color(.systemGray4), lineWidth: 2)
                                .frame(width: 24, height: 24)
                                .overlay {
                                    if selectedType == type {
                                        Circle()
                                            .fill(Color(hex: "E53935"))
                                            .frame(width: 14, height: 14)
                                    }
                                }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(.systemBackground))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedType == type ? Color(hex: "E53935") : Color.clear, lineWidth: 2)
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func typeDescription(_ type: CollaborationType) -> String {
        switch type {
        case .influencerVisit:
            return String(localized: "El creador visita tu restaurante y crea contenido in situ")
        case .delivery:
            return String(localized: "Envías tu producto al creador para que haga un unboxing")
        case .event:
            return String(localized: "Invita a creadores a un evento especial")
        }
    }

    // MARK: - Step 1: Photo and Basic Info

    private var photoAndBasicStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Image Section
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Foto de la colaboración"))
                Text(String(localized: "Esta imagen se mostrará a los creadores cuando vean tu oferta"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                PhotosPicker(
                    selection: $selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    ZStack {
                        if let imageURL = selectedImageURL, let url = URL(string: imageURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                case .failure(_):
                                    imagePlaceholder
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 200)
                                @unknown default:
                                    imagePlaceholder
                                }
                            }
                        } else {
                            imagePlaceholder
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
                    .overlay {
                        if isUploadingImage {
                            ZStack {
                                Color.black.opacity(0.5)
                                    .clipShape(RoundedRectangle(cornerRadius: 16))
                                ProgressView()
                                    .tint(.white)
                                    .scaleEffect(1.5)
                            }
                        }
                    }
                }
                .onChange(of: selectedPhotoItem) { _, newValue in
                    Task {
                        await uploadSelectedPhoto(newValue)
                    }
                }
            }

            // Type-specific basic info
            switch selectedType {
            case .influencerVisit:
                influencerVisitPhotoStep
            case .delivery:
                deliveryPhotoStep
            case .event:
                eventPhotoStep
            }
        }
    }

    private var imagePlaceholder: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text(String(localized: "Toca para seleccionar una foto"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(Color(.systemGray6))
    }

    // MARK: - Photo Step: INFLUENCER VISIT

    private var influencerVisitPhotoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Location Selection
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Ubicaciones disponibles"))
                Text(String(localized: "Selecciona en qué locales podrá realizarse la colaboración"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                if isLoadingLocations {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding()
                } else if restaurantLocations.isEmpty {
                    HStack(spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(String(localized: "No tienes ubicaciones configuradas en tu perfil"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                } else {
                    VStack(spacing: 8) {
                        ForEach(restaurantLocations) { location in
                            Button {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    if selectedLocationIds.contains(location.id) {
                                        selectedLocationIds.remove(location.id)
                                    } else {
                                        selectedLocationIds.insert(location.id)
                                    }
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: selectedLocationIds.contains(location.id) ? "checkmark.circle.fill" : "circle")
                                        .font(.title2)
                                        .foregroundStyle(selectedLocationIds.contains(location.id) ? Color(hex: "E53935") : .secondary)

                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(location.name)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                        Text("\(location.city), \(location.country)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(selectedLocationIds.contains(location.id) ? Color(hex: "E53935") : Color.clear, lineWidth: 2)
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            // Min Followers
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Mínimo de seguidores"))
                Text(String(localized: "Solo verán tu oferta creadores con al menos este número de seguidores"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                followersPicker
            }

            // Max Companions
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Acompañantes permitidos"))

                HStack(spacing: 12) {
                    ForEach(0...5, id: \.self) { count in
                        Button {
                            maxCompanions = "\(count)"
                        } label: {
                            Text("\(count)")
                                .font(.headline)
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(maxCompanions == "\(count)" ? Color(hex: "E53935") : Color(.systemBackground))
                                )
                                .foregroundStyle(maxCompanions == "\(count)" ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Photo Step: DELIVERY

    private var deliveryPhotoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Product Name
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Nombre del producto"))

                customTextField(
                    icon: "shippingbox",
                    placeholder: String(localized: "Ej: Pack degustación premium"),
                    text: $productName
                )
            }

            // Product Description
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Descripción del producto"))

                customTextEditor(
                    placeholder: String(localized: "Describe tu producto en detalle..."),
                    text: $productRequirements
                )
            }

            // Quantity per creator
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Unidades por creador"))

                HStack(spacing: 12) {
                    ForEach(1...5, id: \.self) { count in
                        Button {
                            quantityPerCreator = "\(count)"
                        } label: {
                            Text("\(count)")
                                .font(.headline)
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(quantityPerCreator == "\(count)" ? Color(hex: "E53935") : Color(.systemBackground))
                                )
                                .foregroundStyle(quantityPerCreator == "\(count)" ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    // MARK: - Photo Step: EVENT

    private var eventPhotoStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Event Name
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Nombre del evento"))

                customTextField(
                    icon: "party.popper",
                    placeholder: String(localized: "Ej: Gran inauguración de terraza"),
                    text: $eventName
                )
            }

            // Event Type
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Tipo de evento"))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(eventTypes, id: \.id) { type in
                        Button {
                            eventType = type.id
                        } label: {
                            Text(type.label)
                                .font(.subheadline.weight(.medium))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(eventType == type.id ? Color(hex: "E53935") : Color(.systemBackground))
                                )
                                .foregroundStyle(eventType == type.id ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Max Companions for event
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Acompañantes por creador"))

                HStack(spacing: 12) {
                    ForEach(0...5, id: \.self) { count in
                        Button {
                            maxCompanions = "\(count)"
                        } label: {
                            Text("\(count)")
                                .font(.headline)
                                .frame(width: 48, height: 48)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(maxCompanions == "\(count)" ? Color(hex: "E53935") : Color(.systemBackground))
                                )
                                .foregroundStyle(maxCompanions == "\(count)" ? .white : .primary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Min Followers for event
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Mínimo de seguidores"))
                Text(String(localized: "Solo verán tu evento creadores con al menos este número de seguidores"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                followersPicker
            }
        }
    }

    // MARK: - Image Upload

    private func uploadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item = item else {
            print("❌ No photo item selected")
            return
        }
        isUploadingImage = true
        print("📸 Starting image upload...")

        do {
            guard let imageData = try await item.loadTransferable(type: Data.self) else {
                print("❌ Could not load image data from picker")
                isUploadingImage = false
                return
            }

            print("📦 Image data loaded: \(imageData.count) bytes")

            // Upload to server
            let uploadedURL = try await uploadImage(imageData: imageData)
            print("✅ Image uploaded successfully: \(uploadedURL)")
            selectedImageURL = uploadedURL
        } catch {
            print("❌ Error uploading image: \(error)")
        }

        isUploadingImage = false
    }

    private func uploadImage(imageData: Data) async throws -> String {
        let url = URL(string: "https://solofoodiesnewreact-production-7dd9.up.railway.app/api/upload/image")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        if let token = KeychainManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            print("🔑 Auth token added to request")
        } else {
            print("⚠️ No auth token available!")
        }

        var body = Data()

        // Add file data - field name must be "image" as expected by multer
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        print("🌐 Uploading image to: \(url)")
        print("📤 Body size: \(body.count) bytes")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw APIError.invalidResponse
        }

        print("📥 Upload response status: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Upload response body: \(responseString.prefix(500))")
        }

        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            print("❌ Upload failed with status: \(httpResponse.statusCode)")
            throw APIError.invalidResponse
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let uploadResponse = try decoder.decode(ImageUploadResponse.self, from: data)
        return uploadResponse.url
    }

    // MARK: - Type Specific Steps
    // Step 0: Type Selection
    // Step 1: Photo and Basic Info (photoAndBasicStep)
    // Step 2: Requirements/Details (typeSpecificStep2)
    // Step 3: Compensation (INFLUENCER_VISIT, DELIVERY) or Event Details (EVENT)
    // Step 4: Compensation (EVENT only)

    @ViewBuilder
    private var typeSpecificStep2: some View {
        switch selectedType {
        case .influencerVisit:
            influencerVisitRequirementsStep
        case .delivery:
            deliveryShippingStep
        case .event:
            eventLocationStep
        }
    }

    @ViewBuilder
    private var typeSpecificStep3: some View {
        switch selectedType {
        case .influencerVisit:
            compensationStep
        case .delivery:
            compensationStep
        case .event:
            eventDetailsStep
        }
    }

    @ViewBuilder
    private var typeSpecificStep4: some View {
        switch selectedType {
        case .event:
            compensationStep
        default:
            EmptyView()
        }
    }

    // MARK: - INFLUENCER VISIT Steps

    private var influencerVisitRequirementsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Available Days
            daysSection

            // Optional date range
            VStack(alignment: .leading, spacing: 12) {
                customCheckbox(
                    label: String(localized: "Limitar a un rango de fechas"),
                    isChecked: $hasDates
                )

                if hasDates {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "Desde"))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                                DatePicker("", selection: $startDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color(hex: "E53935"))
                            }

                            Spacer()

                            VStack(alignment: .leading, spacing: 4) {
                                Text(String(localized: "Hasta"))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(.secondary)
                                DatePicker("", selection: $endDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(Color(hex: "E53935"))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color(.systemBackground))
                        )
                    }
                }
            }

            // Requirements
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Requisitos de contenido"))
                Text(String(localized: "Describe qué tipo de contenido esperas del creador"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                customTextEditor(
                    placeholder: String(localized: "Ej: 1 Reel + 3 Stories mencionando @turestaurante..."),
                    text: $requirements
                )
            }
        }
    }

    // MARK: - DELIVERY Steps

    private var deliveryShippingStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Product Value
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Valor del producto (opcional)"))

                customTextField(
                    icon: "eurosign",
                    placeholder: String(localized: "0"),
                    text: $productValue,
                    keyboardType: .numberPad
                )
            }

            // Variations
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Variaciones disponibles (opcional)"))

                customTextField(
                    icon: "list.bullet",
                    placeholder: String(localized: "Ej: Sabores, tamaños..."),
                    text: $productVariations
                )
            }

            // Ships Worldwide
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Zona de envío"))

                customCheckbox(
                    label: String(localized: "Envío a todo el mundo"),
                    isChecked: $shipsWorldwide
                )
            }

            // Min Followers
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Mínimo de seguidores"))
                Text(String(localized: "Solo verán tu oferta creadores con al menos este número de seguidores"))
                    .font(.caption)
                    .foregroundStyle(.secondary)

                followersPicker
            }

            // Requirements
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Requisitos de contenido"))

                customTextEditor(
                    placeholder: String(localized: "Describe qué contenido esperas: unboxing, review, etc."),
                    text: $requirements
                )
            }
        }
    }

    // MARK: - EVENT Steps

    private var eventLocationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Venue Name
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Nombre del lugar"))

                customTextField(
                    icon: "building.2",
                    placeholder: String(localized: "Ej: Terraza Sunset"),
                    text: $venueName
                )
            }

            // Address
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Dirección"))

                customTextField(
                    icon: "mappin.circle",
                    placeholder: String(localized: "Calle y número"),
                    text: $venueAddress
                )
            }

            // City & Province
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Ciudad"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    customTextField(
                        icon: "building",
                        placeholder: String(localized: "Ciudad"),
                        text: $eventCity
                    )
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Provincia"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    customTextField(
                        icon: "map",
                        placeholder: String(localized: "Provincia"),
                        text: $eventProvince
                    )
                }
            }

            // Event Date
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Fecha del evento"))

                customDatePicker(date: $eventDate, displayedComponents: .date)
            }

            // Time options
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Horario"))

                customTimeToggle(
                    label: String(localized: "Hora de inicio"),
                    isEnabled: $hasStartTime,
                    time: $eventStartTime
                )

                customTimeToggle(
                    label: String(localized: "Hora de fin"),
                    isEnabled: $hasEndTime,
                    time: $eventEndTime
                )

                customTimeToggle(
                    label: String(localized: "Llegada de creadores"),
                    isEnabled: $hasArrivalTime,
                    time: $creatorArrivalTime
                )
            }

            // Contact
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Contacto (opcional)"))

                customTextField(
                    icon: "person",
                    placeholder: String(localized: "Persona de contacto"),
                    text: $eventContactPerson
                )

                customTextField(
                    icon: "phone",
                    placeholder: String(localized: "+34 600 000 000"),
                    text: $eventContactPhone,
                    keyboardType: .phonePad
                )
            }
        }
    }

    private var eventDetailsStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // What to expect
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "¿Qué pueden esperar los creadores?"))

                VStack(spacing: 8) {
                    ForEach(whatToExpectOptions, id: \.id) { option in
                        Button {
                            if whatToExpect.contains(option.id) {
                                whatToExpect.remove(option.id)
                            } else {
                                whatToExpect.insert(option.id)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: option.icon)
                                    .font(.body)
                                    .frame(width: 24)
                                    .foregroundStyle(whatToExpect.contains(option.id) ? Color(hex: "E53935") : .secondary)

                                Text(option.label)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)

                                Spacer()

                                Image(systemName: whatToExpect.contains(option.id) ? "checkmark.square.fill" : "square")
                                    .font(.title3)
                                    .foregroundStyle(whatToExpect.contains(option.id) ? Color(hex: "E53935") : .secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Dress code
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Código de vestimenta (opcional)"))

                customTextField(
                    icon: "tshirt",
                    placeholder: String(localized: "Ej: Smart casual"),
                    text: $dressCode
                )
            }

            // Event requirements
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Agenda / Requisitos"))

                customTextEditor(
                    placeholder: String(localized: "Describe la agenda del evento y lo que esperas de los creadores..."),
                    text: $eventRequirements
                )
            }

            // Content expectations
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Expectativas de contenido"))

                customTextField(
                    icon: "number",
                    placeholder: String(localized: "Hashtags a usar"),
                    text: $hashtags
                )

                customTextField(
                    icon: "at",
                    placeholder: String(localized: "Cuentas a mencionar"),
                    text: $accountsToTag
                )

                customTextEditor(
                    placeholder: String(localized: "Sugerencias de tono y estilo..."),
                    text: $toneSuggestions
                )
            }

            // RSVP Deadline
            VStack(alignment: .leading, spacing: 12) {
                customCheckbox(
                    label: String(localized: "Establecer fecha límite de confirmación"),
                    isChecked: $hasRsvpDeadline
                )

                if hasRsvpDeadline {
                    customDatePicker(date: $rsvpDeadline, displayedComponents: .date)
                }
            }
        }
    }

    // MARK: - Compensation Step (shared)

    private var compensationStep: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Credit Mode
            VStack(alignment: .leading, spacing: 12) {
                sectionHeader(String(localized: "Tipo de compensación"))

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(creditModes, id: \.id) { mode in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                creditMode = mode.id
                            }
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: mode.icon)
                                    .font(.title2)
                                    .foregroundStyle(creditMode == mode.id ? Color(hex: "E53935") : .secondary)

                                Text(mode.label)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(creditMode == mode.id ? .primary : .secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(.systemBackground))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(creditMode == mode.id ? Color(hex: "E53935") : Color.clear, lineWidth: 2)
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Credit Value
            if creditMode != "exchange" {
                VStack(alignment: .leading, spacing: 12) {
                    sectionHeader(creditValueLabel)

                    customTextField(
                        icon: "eurosign",
                        placeholder: "0",
                        text: $creditValue,
                        keyboardType: .numberPad
                    )
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            // Allow Rate Proposal
            if creditMode == "exchange" {
                customCheckbox(
                    label: String(localized: "Permitir que el creador proponga su tarifa"),
                    isChecked: $allowFoodieRateProposal
                )
            }

            // Days (for influencer visit and delivery)
            if selectedType == .influencerVisit || selectedType == .delivery {
                daysSection
            }
        }
    }

    private var creditValueLabel: String {
        switch creditMode {
        case "credit": return String(localized: "Valor del crédito (€)")
        case "discount": return String(localized: "Porcentaje de descuento (%)")
        case "payment": return String(localized: "Importe a pagar (€)")
        default: return String(localized: "Valor")
        }
    }

    // MARK: - Days Section

    private var daysSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                sectionHeader(String(localized: "Días disponibles"))
                Spacer()
                Button {
                    withAnimation {
                        if availableDays.count == weekDaysFull.count {
                            availableDays.removeAll()
                        } else {
                            availableDays = Set(weekDaysFull)
                        }
                    }
                } label: {
                    Text(availableDays.count == weekDaysFull.count ? String(localized: "Ninguno") : String(localized: "Todos"))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color(hex: "E53935"))
                }
            }

            HStack(spacing: 6) {
                ForEach(Array(zip(weekDays, weekDaysFull)), id: \.0) { short, full in
                    Button {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            if availableDays.contains(full) {
                                availableDays.remove(full)
                            } else {
                                availableDays.insert(full)
                            }
                        }
                    } label: {
                        Text(short)
                            .font(.caption.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(availableDays.contains(full) ? Color(hex: "E53935") : Color(.systemBackground))
                            )
                            .foregroundStyle(availableDays.contains(full) ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Followers Picker

    private var followersPicker: some View {
        let options = ["1000", "5000", "10000", "20000", "50000"]
        let labels = ["1K", "5K", "10K", "20K", "50K"]

        return HStack(spacing: 8) {
            ForEach(Array(zip(options, labels)), id: \.0) { value, label in
                Button {
                    minFollowers = value
                } label: {
                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(minFollowers == value ? Color(hex: "E53935") : Color(.systemBackground))
                        )
                        .foregroundStyle(minFollowers == value ? .white : .primary)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentStep > 0 {
                Button {
                    withAnimation {
                        currentStep -= 1
                    }
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text(String(localized: "Atrás"))
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.systemGray5))
                    )
                    .foregroundStyle(.primary)
                }
            }

            Button {
                if currentStep < totalSteps - 1 {
                    withAnimation {
                        currentStep += 1
                    }
                } else {
                    createCollaboration()
                }
            } label: {
                HStack {
                    if isCreating {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(currentStep < totalSteps - 1 ? String(localized: "Siguiente") : String(localized: "Crear"))
                        if currentStep < totalSteps - 1 {
                            Image(systemName: "chevron.right")
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                        }
                    }
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(canProceed ? Color(hex: "E53935") : Color(.systemGray4))
                )
                .foregroundStyle(.white)
            }
            .disabled(!canProceed)
        }
        .padding()
        .background(Color(.systemBackground))
    }

    private var canProceed: Bool {
        if isCreating { return false }
        if isUploadingImage { return false }

        switch currentStep {
        case 0:
            return true
        case 1:
            // Photo and Basic step
            switch selectedType {
            case .influencerVisit:
                // Need at least one location selected (or no locations available)
                return restaurantLocations.isEmpty || !selectedLocationIds.isEmpty
            case .delivery:
                return !productName.isEmpty
            case .event:
                return !eventName.isEmpty
            }
        case 2:
            // Requirements/Shipping/Location step
            switch selectedType {
            case .influencerVisit:
                return !availableDays.isEmpty
            case .delivery:
                return true
            case .event:
                return !eventCity.isEmpty
            }
        case 3:
            // Compensation (INFLUENCER_VISIT, DELIVERY) or Event Details (EVENT)
            return true
        case 4:
            // Compensation (EVENT only)
            return true
        default:
            return true
        }
    }

    // MARK: - Helper Views

    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.headline)
            .foregroundStyle(.primary)
    }

    private func customTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.secondary)
                .frame(width: 24)

            TextField(placeholder, text: text)
                .keyboardType(keyboardType)
                .font(.body)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    private func customTextEditor(placeholder: String, text: Binding<String>) -> some View {
        ZStack(alignment: .topLeading) {
            if text.wrappedValue.isEmpty {
                Text(placeholder)
                    .font(.body)
                    .foregroundStyle(.secondary.opacity(0.6))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }

            TextEditor(text: text)
                .font(.body)
                .frame(minHeight: 100)
                .scrollContentBackground(.hidden)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    private func customCheckbox(label: String, isChecked: Binding<Bool>) -> some View {
        Button {
            withAnimation {
                isChecked.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isChecked.wrappedValue ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundStyle(isChecked.wrappedValue ? Color(hex: "E53935") : .secondary)

                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(.primary)

                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
        }
        .buttonStyle(.plain)
    }

    private func customDatePicker(date: Binding<Date>, displayedComponents: DatePickerComponents) -> some View {
        DatePicker("", selection: date, displayedComponents: displayedComponents)
            .datePickerStyle(.graphical)
            .tint(Color(hex: "E53935"))
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
            )
    }

    private func customTimeToggle(label: String, isEnabled: Binding<Bool>, time: Binding<Date>) -> some View {
        VStack(spacing: 8) {
            Button {
                withAnimation {
                    isEnabled.wrappedValue.toggle()
                }
            } label: {
                HStack {
                    Image(systemName: isEnabled.wrappedValue ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isEnabled.wrappedValue ? Color(hex: "E53935") : .secondary)
                    Text(label)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                    Spacer()
                }
            }
            .buttonStyle(.plain)

            if isEnabled.wrappedValue {
                DatePicker("", selection: time, displayedComponents: .hourAndMinute)
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .frame(height: 100)
                    .clipped()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
    }

    // MARK: - Create Action

    private func createCollaboration() {
        isCreating = true

        let dateFormatter = ISO8601DateFormatter()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        let request = CreatePublicCollaborationRequest(
            type: selectedType.rawValue,
            image: selectedImageURL,
            requirements: requirements.isEmpty ? nil : requirements,
            minFollowers: Int(minFollowers) ?? 10000,
            maxCompanions: Int(maxCompanions) ?? 1,
            creditMode: creditMode,
            creditType: creditMode == "discount" ? "percentage" : "fixed",
            creditValue: Int(creditValue) ?? 0,
            allowFoodieRateProposal: allowFoodieRateProposal,
            availableDays: Array(availableDays),
            locationIds: Array(selectedLocationIds),
            isPrivate: false,
            // Optional date range
            startDate: hasDates ? dateFormatter.string(from: startDate) : nil,
            endDate: hasDates ? dateFormatter.string(from: endDate) : nil,
            // Delivery
            productName: selectedType == .delivery ? (productName.isEmpty ? nil : productName) : nil,
            productRequirements: selectedType == .delivery ? (productRequirements.isEmpty ? nil : productRequirements) : nil,
            quantityPerCreator: selectedType == .delivery ? Int(quantityPerCreator) : nil,
            productValue: selectedType == .delivery ? Double(productValue) : nil,
            productValueCurrency: selectedType == .delivery ? "EUR" : nil,
            productVariations: selectedType == .delivery ? (productVariations.isEmpty ? nil : productVariations) : nil,
            shipsWorldwide: selectedType == .delivery ? shipsWorldwide : nil,
            // Event
            eventName: selectedType == .event ? (eventName.isEmpty ? nil : eventName) : nil,
            venueName: selectedType == .event ? (venueName.isEmpty ? nil : venueName) : nil,
            venueAddress: selectedType == .event ? (venueAddress.isEmpty ? nil : venueAddress) : nil,
            eventCity: selectedType == .event ? (eventCity.isEmpty ? nil : eventCity) : nil,
            eventProvince: selectedType == .event ? (eventProvince.isEmpty ? nil : eventProvince) : nil,
            eventCountry: selectedType == .event ? eventCountry : nil,
            eventCountryIso: selectedType == .event ? "ES" : nil,
            eventContactPerson: selectedType == .event ? (eventContactPerson.isEmpty ? nil : eventContactPerson) : nil,
            eventContactPhone: selectedType == .event ? (eventContactPhone.isEmpty ? nil : eventContactPhone) : nil,
            eventType: selectedType == .event ? eventType : nil,
            eventDate: selectedType == .event ? dateFormatter.string(from: eventDate) : nil,
            eventStartTime: selectedType == .event && hasStartTime ? timeFormatter.string(from: eventStartTime) : nil,
            eventEndTime: selectedType == .event && hasEndTime ? timeFormatter.string(from: eventEndTime) : nil,
            creatorArrivalTime: selectedType == .event && hasArrivalTime ? timeFormatter.string(from: creatorArrivalTime) : nil,
            rsvpDeadline: selectedType == .event && hasRsvpDeadline ? dateFormatter.string(from: rsvpDeadline) : nil,
            eventRequirements: selectedType == .event ? (eventRequirements.isEmpty ? nil : eventRequirements) : nil,
            whatToExpect: selectedType == .event ? Array(whatToExpect) : nil,
            dressCode: selectedType == .event ? (dressCode.isEmpty ? nil : dressCode) : nil,
            hashtags: selectedType == .event ? (hashtags.isEmpty ? nil : hashtags) : nil,
            accountsToTag: selectedType == .event ? (accountsToTag.isEmpty ? nil : accountsToTag) : nil,
            toneSuggestions: selectedType == .event ? (toneSuggestions.isEmpty ? nil : toneSuggestions) : nil
        )

        Task {
            do {
                _ = try await CollaborationService.shared.createPublicCollaboration(request: request)
                onSuccess()
            } catch {
                viewModel.error = String(localized: "Error al crear la colaboración")
            }
            isCreating = false
        }
    }
}

#Preview {
    RestaurantCollaborationsView()
}
