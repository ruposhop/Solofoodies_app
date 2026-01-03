//
//  MyCollaborationDetailView.swift
//  Solofoodies
//

import SwiftUI

struct MyCollaborationDetailView: View {
    let collaborationId: String
    @StateObject private var viewModel = CollaborationsViewModel()
    @State private var showScheduleSheet = false
    @State private var showAddLinkSheet = false
    @State private var showCancelAlert = false

    private var collaboration: Collaboration? {
        viewModel.selectedCollaboration
    }

    var body: some View {
        Group {
            if viewModel.isLoading && collaboration == nil {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let collaboration = collaboration {
                collaborationContent(collaboration)
            } else {
                Text(String(localized: "No se pudo cargar la colaboracion"))
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(String(localized: "Detalle"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.getCollaboration(id: collaborationId)
        }
        .alert(String(localized: "Cancelar solicitud"), isPresented: $showCancelAlert) {
            Button(String(localized: "No"), role: .cancel) {}
            Button(String(localized: "Si, cancelar"), role: .destructive) {
                Task {
                    await viewModel.cancelCollaboration(id: collaborationId)
                }
            }
        } message: {
            Text(String(localized: "Esta seguro de que desea cancelar esta solicitud?"))
        }
    }

    private func collaborationContent(_ collaboration: Collaboration) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                headerSection(collaboration)

                Divider()

                // Status section
                statusSection(collaboration)

                // Restaurant info
                if let publicCollab = collaboration.publicCollaboration {
                    Divider()
                    restaurantSection(publicCollab)
                }

                // Scheduled date
                if collaboration.status == .accepted {
                    Divider()
                    schedulingSection(collaboration)
                }

                // Content links (for completed or accepted with scheduled date)
                if collaboration.status == .accepted || collaboration.status == .completed {
                    Divider()
                    contentLinksSection(collaboration)
                }

                // Actions
                if collaboration.status == .pending {
                    Divider()
                    actionsSection(collaboration)
                }

                Spacer()
                    .frame(height: 40)
            }
            .padding()
        }
        .sheet(isPresented: $showScheduleSheet) {
            ScheduleCollaborationSheet(
                collaboration: collaboration,
                viewModel: viewModel
            )
        }
        .sheet(isPresented: $showAddLinkSheet) {
            AddContentLinkSheet(
                collaborationId: collaboration.id,
                viewModel: viewModel
            )
        }
    }

    // MARK: - Sections

    private func headerSection(_ collaboration: Collaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Type badge
            HStack {
                let type = collaboration.publicCollaboration?.type ?? .influencerVisit
                Image(systemName: type.icon)
                Text(type.displayName)
                    .font(.subheadline.bold())
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(16)

            // Restaurant name
            Text(collaboration.publicCollaboration?.restaurantProfile?.restaurantName ?? collaboration.restaurant?.name ?? "")
                .font(.title2.bold())

            // Date
            HStack {
                Image(systemName: "calendar")
                    .foregroundStyle(.secondary)
                Text(String(localized: "Solicitado el \(collaboration.createdAt.formatted(date: .abbreviated, time: .omitted))"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func statusSection(_ collaboration: Collaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Estado"))
                .font(.headline)

            HStack(spacing: 12) {
                Circle()
                    .fill(Color(hex: collaboration.status.color))
                    .frame(width: 12, height: 12)

                Text(collaboration.status.displayName)
                    .font(.subheadline.bold())

                Spacer()

                if collaboration.isInvitation {
                    Text(String(localized: "Invitacion"))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "E53935").opacity(0.1))
                        .foregroundStyle(Color(hex: "E53935"))
                        .cornerRadius(8)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)

            // Status message
            if let message = statusMessage(for: collaboration.status) {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func statusMessage(for status: ApplicationStatus) -> String? {
        switch status {
        case .pending:
            return String(localized: "Tu solicitud esta siendo revisada por el restaurante")
        case .accepted:
            return String(localized: "El restaurante ha aceptado tu solicitud. Programa tu visita")
        case .rejected:
            return String(localized: "El restaurante no ha aceptado tu solicitud en esta ocasion")
        case .completed:
            return String(localized: "Colaboracion completada con exito")
        case .cancelled:
            return String(localized: "Esta colaboracion fue cancelada")
        }
    }

    private func restaurantSection(_ publicCollab: PublicCollaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Sobre la colaboracion"))
                .font(.headline)

            // Requirements
            if let requirements = publicCollab.requirements, !requirements.isEmpty {
                Text(requirements)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            // Details
            HStack(spacing: 16) {
                detailItem(
                    icon: "eurosign.circle",
                    title: String(localized: "Compensacion"),
                    value: publicCollab.creditDescription
                )

                detailItem(
                    icon: "person.2",
                    title: String(localized: "Acompanantes"),
                    value: "+\(publicCollab.maxCompanions)"
                )
            }
        }
    }

    private func detailItem(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(.secondary)

            Text(value)
                .font(.subheadline.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }

    private func schedulingSection(_ collaboration: Collaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(String(localized: "Programar visita"))
                .font(.headline)

            if let scheduledDate = collaboration.scheduledDate {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color(hex: "4CAF50"))

                    VStack(alignment: .leading, spacing: 2) {
                        Text(String(localized: "Visita programada"))
                            .font(.subheadline.bold())
                        Text(scheduledDate.formatted(date: .complete, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if let locationName = collaboration.selectedLocationName {
                        Text(locationName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                    }
                }
                .padding()
                .background(Color(hex: "4CAF50").opacity(0.1))
                .cornerRadius(12)
            } else {
                Button {
                    showScheduleSheet = true
                } label: {
                    HStack {
                        Image(systemName: "calendar.badge.plus")
                        Text(String(localized: "Programar fecha y hora"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(hex: "E53935"))
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
            }
        }
    }

    private func contentLinksSection(_ collaboration: Collaboration) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(String(localized: "Contenido publicado"))
                    .font(.headline)

                Spacer()

                Button {
                    showAddLinkSheet = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color(hex: "E53935"))
                }
            }

            if collaboration.contentLinks.isEmpty {
                Text(String(localized: "Anade los enlaces a tus publicaciones"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else {
                ForEach(collaboration.contentLinks, id: \.self) { link in
                    HStack {
                        Image(systemName: "link")
                            .foregroundStyle(Color(hex: "E53935"))

                        Text(link)
                            .font(.caption)
                            .lineLimit(1)
                            .foregroundStyle(.secondary)

                        Spacer()

                        if let url = URL(string: link) {
                            Link(destination: url) {
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
            }
        }
    }

    private func actionsSection(_ collaboration: Collaboration) -> some View {
        VStack(spacing: 12) {
            Button(role: .destructive) {
                showCancelAlert = true
            } label: {
                HStack {
                    Image(systemName: "xmark.circle")
                    Text(String(localized: "Cancelar solicitud"))
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(.red)
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Schedule Sheet

struct ScheduleCollaborationSheet: View {
    let collaboration: Collaboration
    @ObservedObject var viewModel: CollaborationsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var selectedDate = Date()
    @State private var selectedLocationId: String?
    @State private var selectedLocationName: String?

    private var locations: [CollaborationLocation] {
        collaboration.publicCollaboration?.collabLocations ?? []
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    DatePicker(
                        String(localized: "Fecha y hora"),
                        selection: $selectedDate,
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                } header: {
                    Text(String(localized: "Cuando quieres ir?"))
                }

                if !locations.isEmpty {
                    Section {
                        ForEach(locations) { location in
                            Button {
                                selectedLocationId = location.id
                                selectedLocationName = location.name
                            } label: {
                                HStack {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(location.name)
                                            .font(.subheadline.bold())
                                            .foregroundColor(.primary)
                                        Text("\(location.line), \(location.city)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()

                                    if selectedLocationId == location.id {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(Color(hex: "E53935"))
                                    }
                                }
                            }
                        }
                    } header: {
                        Text(String(localized: "Ubicacion"))
                    }
                }
            }
            .navigationTitle(String(localized: "Programar visita"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            let success = await viewModel.scheduleCollaboration(
                                id: collaboration.id,
                                date: selectedDate,
                                locationId: selectedLocationId,
                                locationName: selectedLocationName
                            )
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(String(localized: "Confirmar"))
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
        .onAppear {
            if locations.count == 1 {
                selectedLocationId = locations.first?.id
                selectedLocationName = locations.first?.name
            }
        }
    }
}

// MARK: - Add Content Link Sheet

struct AddContentLinkSheet: View {
    let collaborationId: String
    @ObservedObject var viewModel: CollaborationsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var link = ""

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(String(localized: "https://instagram.com/p/..."), text: $link)
                        .keyboardType(.URL)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                } header: {
                    Text(String(localized: "Enlace a tu publicacion"))
                } footer: {
                    Text(String(localized: "Pega el enlace de tu reel, post o historia"))
                }
            }
            .navigationTitle(String(localized: "Agregar contenido"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            let success = await viewModel.addContentLink(id: collaborationId, link: link)
                            if success {
                                dismiss()
                            }
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(String(localized: "Agregar"))
                        }
                    }
                    .disabled(link.isEmpty || viewModel.isLoading)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        MyCollaborationDetailView(collaborationId: "test")
    }
}
