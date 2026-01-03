//
//  ConversationsListView.swift
//  Solofoodies
//

import SwiftUI

struct ConversationsListView: View {
    @StateObject private var viewModel = ChatViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedConversation: Conversation?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                searchBar

                // Content
                if viewModel.isLoading && viewModel.conversations.isEmpty {
                    loadingView
                } else if viewModel.filteredConversations.isEmpty {
                    emptyView
                } else {
                    conversationsList
                }
            }
            .navigationTitle(String(localized: "Chat"))
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.refresh()
            }
            .task {
                viewModel.setCurrentUserId(authViewModel.currentUser?.id)
                await viewModel.refresh()
            }
            .alert(String(localized: "Error"), isPresented: .constant(viewModel.error != nil)) {
                Button(String(localized: "OK")) {
                    viewModel.clearError()
                }
            } message: {
                Text(viewModel.error ?? "")
            }
            .navigationDestination(item: $selectedConversation) { conversation in
                ChatDetailView(
                    conversation: conversation,
                    viewModel: viewModel
                )
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(String(localized: "Buscar"), text: $viewModel.searchText)
                .textFieldStyle(.plain)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    // MARK: - Loading View

    private var loadingView: some View {
        VStack {
            Spacer()
            ProgressView()
                .scaleEffect(1.5)
            Spacer()
        }
    }

    // MARK: - Empty View

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "message.fill")
                .font(.system(size: 60))
                .foregroundStyle(.tertiary)

            Text(viewModel.searchText.isEmpty ?
                 String(localized: "No hay conversaciones") :
                 String(localized: "Sin resultados"))
                .font(.headline)
                .foregroundStyle(.secondary)

            Text(String(localized: "Las conversaciones con restaurantes y foodies apareceran aqui"))
                .font(.subheadline)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }

    // MARK: - Conversations List

    private var conversationsList: some View {
        List {
            ForEach(viewModel.filteredConversations) { conversation in
                ConversationRow(
                    conversation: conversation,
                    formatTimestamp: viewModel.formatTimestamp
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedConversation = conversation
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.hideConversation(conversation.id)
                        }
                    } label: {
                        Label(String(localized: "Eliminar"), systemImage: "trash")
                    }
                }
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(.plain)
    }
}

// MARK: - Conversation Row

struct ConversationRow: View {
    let conversation: Conversation
    let formatTimestamp: (Date?) -> String

    var body: some View {
        HStack(spacing: 12) {
            // Avatar
            ZStack(alignment: .topTrailing) {
                if let avatar = conversation.otherParticipant.avatar,
                   let url = URL(string: avatar) {
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
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                } else {
                    avatarPlaceholder
                }

                // Unread indicator
                if conversation.unreadCount > 0 {
                    Circle()
                        .fill(Color(hex: "E53935"))
                        .frame(width: 12, height: 12)
                        .offset(x: 2, y: -2)
                }
            }

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(displayName)
                        .font(.subheadline.weight(conversation.unreadCount > 0 ? .bold : .semibold))
                        .foregroundStyle(conversation.unreadCount > 0 ? .primary : .secondary)
                        .lineLimit(1)

                    Spacer()

                    Text(formatTimestamp(conversation.lastMessageAt))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(conversation.lastMessage?.content ?? String(localized: "Sin mensajes"))
                    .font(.subheadline)
                    .foregroundStyle(conversation.unreadCount > 0 ? .primary : .secondary)
                    .fontWeight(conversation.unreadCount > 0 ? .medium : .regular)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    private var displayName: String {
        if let username = conversation.otherParticipant.username {
            return "@\(username)"
        }
        return conversation.otherParticipant.name
    }

    private var avatarPlaceholder: some View {
        Circle()
            .fill(Color(.systemGray4))
            .frame(width: 52, height: 52)
            .overlay {
                Text(conversation.otherParticipant.name.prefix(1).uppercased())
                    .font(.title2.bold())
                    .foregroundStyle(.primary)
            }
    }
}

#Preview {
    ConversationsListView()
        .environmentObject(AuthViewModel())
}
