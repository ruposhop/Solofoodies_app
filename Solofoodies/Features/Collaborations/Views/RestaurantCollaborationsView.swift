//
//  RestaurantCollaborationsView.swift
//  Solofoodies
//

import SwiftUI

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
                // TODO: Create collaboration sheet
                Text(String(localized: "Crear colaboracion - Proximamente"))
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

// MARK: - Placeholder Views

struct RestaurantOfferDetailView: View {
    let offerId: String

    var body: some View {
        Text(String(localized: "Detalle de oferta - Proximamente"))
            .navigationTitle(String(localized: "Oferta"))
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

#Preview {
    RestaurantCollaborationsView()
}
