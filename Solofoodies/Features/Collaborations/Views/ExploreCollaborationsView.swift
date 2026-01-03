//
//  ExploreCollaborationsView.swift
//  Solofoodies
//

import SwiftUI

struct ExploreCollaborationsView: View {
    @StateObject private var viewModel = CollaborationsViewModel()
    @State private var selectedCollaboration: PublicCollaboration?

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.publicCollaborations.isEmpty {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.publicCollaborations.isEmpty {
                    emptyState
                } else {
                    collaborationsList
                }
            }
            .navigationTitle(String(localized: "Explorar"))
            .refreshable {
                await viewModel.refreshPublicCollaborations()
            }
            .task {
                if viewModel.publicCollaborations.isEmpty {
                    await viewModel.loadPublicCollaborations()
                }
            }
            .sheet(item: $selectedCollaboration) { collaboration in
                NavigationStack {
                    CollaborationDetailView(collaboration: collaboration)
                }
            }
        }
    }

    private var collaborationsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.publicCollaborations) { collaboration in
                    CollaborationCardView(collaboration: collaboration)
                        .onTapGesture {
                            selectedCollaboration = collaboration
                        }
                        .task {
                            await viewModel.loadMoreIfNeeded(currentItem: collaboration)
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
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text(String(localized: "No hay colaboraciones disponibles"))
                .font(.headline)

            Text(String(localized: "Vuelve mas tarde para ver nuevas oportunidades"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                Task {
                    await viewModel.refreshPublicCollaborations()
                }
            } label: {
                Text(String(localized: "Actualizar"))
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}

#Preview {
    ExploreCollaborationsView()
}
