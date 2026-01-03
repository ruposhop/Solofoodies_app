//
//  MyCollaborationsView.swift
//  Solofoodies
//

import SwiftUI

struct MyCollaborationsView: View {
    @StateObject private var viewModel = CollaborationsViewModel()
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented picker
                Picker(String(localized: "Filtro"), selection: $selectedTab) {
                    Text(String(localized: "Activas")).tag(0)
                    Text(String(localized: "Historial")).tag(1)
                }
                .pickerStyle(.segmented)
                .padding()

                // Content
                Group {
                    if viewModel.isLoading && viewModel.myCollaborations.isEmpty {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if displayedCollaborations.isEmpty {
                        emptyState
                    } else {
                        collaborationsList
                    }
                }
            }
            .navigationTitle(String(localized: "Mis Colaboraciones"))
            .refreshable {
                await viewModel.loadMyCollaborations()
            }
            .task {
                if viewModel.myCollaborations.isEmpty {
                    await viewModel.loadMyCollaborations()
                }
            }
        }
    }

    private var displayedCollaborations: [Collaboration] {
        selectedTab == 0 ? viewModel.activeCollaborations : viewModel.historyCollaborations
    }

    private var collaborationsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                // Show invitations first if on active tab
                if selectedTab == 0 && !viewModel.invitations.isEmpty {
                    invitationsSection
                }

                ForEach(displayedCollaborations) { collaboration in
                    NavigationLink {
                        MyCollaborationDetailView(collaborationId: collaboration.id)
                    } label: {
                        MyCollaborationRow(collaboration: collaboration)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
        }
    }

    private var invitationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "envelope.badge.fill")
                    .foregroundStyle(Color(hex: "E53935"))
                Text(String(localized: "Invitaciones"))
                    .font(.headline)
            }
            .padding(.horizontal)

            ForEach(viewModel.invitations) { invitation in
                InvitationRow(collaboration: invitation, viewModel: viewModel)
            }
        }
        .padding(.bottom)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: selectedTab == 0 ? "fork.knife.circle" : "clock.arrow.circlepath")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(selectedTab == 0 ?
                 String(localized: "No tienes colaboraciones activas") :
                 String(localized: "No hay historial de colaboraciones"))
                .font(.headline)

            if selectedTab == 0 {
                Text(String(localized: "Explora colaboraciones disponibles y envia tu solicitud"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - My Collaboration Row

struct MyCollaborationRow: View {
    let collaboration: Collaboration

    var body: some View {
        HStack(spacing: 12) {
            // Image
            if let imageUrl = collaboration.publicCollaboration?.image ??
                              collaboration.publicCollaboration?.restaurantProfile?.coverImage,
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
                        Image(systemName: collaborationType.icon)
                            .foregroundStyle(.secondary)
                    }
            }

            // Info
            VStack(alignment: .leading, spacing: 4) {
                Text(restaurantName)
                    .font(.headline)
                    .lineLimit(1)

                Text(collaborationType.displayName)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                // Status badge
                Text(collaboration.status.displayName)
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color(hex: collaboration.status.color).opacity(0.15))
                    .foregroundStyle(Color(hex: collaboration.status.color))
                    .cornerRadius(4)
            }

            Spacer()

            // Date
            VStack(alignment: .trailing, spacing: 4) {
                if let scheduledDate = collaboration.scheduledDate {
                    Text(scheduledDate, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text(collaboration.createdAt, style: .date)
                        .font(.caption)
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

    private var restaurantName: String {
        collaboration.publicCollaboration?.restaurantProfile?.restaurantName ?? collaboration.restaurant?.name ?? ""
    }

    private var collaborationType: CollaborationType {
        collaboration.publicCollaboration?.type ?? .influencerVisit
    }
}

// MARK: - Invitation Row

struct InvitationRow: View {
    let collaboration: Collaboration
    @ObservedObject var viewModel: CollaborationsViewModel

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                // Restaurant image
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Image(systemName: "building.2")
                            .foregroundStyle(.secondary)
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(collaboration.restaurant?.name ?? "")
                        .font(.headline)
                    Text(String(localized: "Te ha invitado a colaborar"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            HStack(spacing: 12) {
                Button {
                    Task {
                        await viewModel.respondToInvitation(id: collaboration.id, accept: false)
                    }
                } label: {
                    Text(String(localized: "Rechazar"))
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(8)
                }

                Button {
                    Task {
                        await viewModel.respondToInvitation(id: collaboration.id, accept: true)
                    }
                } label: {
                    Text(String(localized: "Aceptar"))
                        .font(.subheadline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hex: "E53935"))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(hex: "E53935").opacity(0.05))
        .cornerRadius(12)
        .overlay {
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: "E53935").opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    MyCollaborationsView()
}
