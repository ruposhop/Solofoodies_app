//
//  ChatDetailView.swift
//  Solofoodies
//

import SwiftUI

struct ChatDetailView: View {
    let conversation: Conversation
    @ObservedObject var viewModel: ChatViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var messageText: String = ""
    @FocusState private var isInputFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Messages
            messagesScrollView

            // Input
            messageInputBar
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    viewModel.stopPolling()
                    viewModel.clearMessages()
                    dismiss()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text(String(localized: "Chat"))
                    }
                }
            }

            ToolbarItem(placement: .principal) {
                recipientHeader
            }
        }
        .task {
            await viewModel.loadMessages(for: conversation.id)
            viewModel.startPolling(for: conversation.id)
        }
        .onDisappear {
            viewModel.stopPolling()
        }
    }

    // MARK: - Recipient Header

    private var recipientHeader: some View {
        HStack(spacing: 8) {
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
                .frame(width: 32, height: 32)
                .clipShape(Circle())
            } else {
                avatarPlaceholder
            }

            Text(displayName)
                .font(.headline)
        }
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
            .frame(width: 32, height: 32)
            .overlay {
                Text(conversation.otherParticipant.name.prefix(1).uppercased())
                    .font(.caption.bold())
                    .foregroundStyle(.primary)
            }
    }

    // MARK: - Messages Scroll View

    private var messagesScrollView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    if viewModel.isLoadingMessages {
                        ProgressView()
                            .padding()
                    } else if viewModel.messages.isEmpty {
                        emptyMessagesView
                    } else {
                        // Conversation start indicator
                        Text(String(localized: "Inicio de la conversacion"))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .padding(.top, 20)
                            .padding(.bottom, 10)

                        ForEach(viewModel.messages) { message in
                            MessageBubble(
                                message: message,
                                isOwn: viewModel.isOwnMessage(message),
                                formatTime: viewModel.formatMessageTime
                            )
                            .id(message.id)
                        }
                    }
                }
                .padding()
            }
            .onChange(of: viewModel.messages.count) { _, _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    private var emptyMessagesView: some View {
        VStack(spacing: 12) {
            Spacer()
            Text(String(localized: "Sin mensajes"))
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(String(localized: "Envia el primer mensaje"))
                .font(.subheadline)
                .foregroundStyle(.tertiary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }

    // MARK: - Message Input Bar

    private var messageInputBar: some View {
        HStack(spacing: 12) {
            TextField(String(localized: "Escribe un mensaje..."), text: $messageText, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemGray6))
                .cornerRadius(20)
                .focused($isInputFocused)
                .lineLimit(1...5)
                .onSubmit {
                    sendMessage()
                }

            Button {
                sendMessage()
            } label: {
                Image(systemName: "paperplane.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(canSend ? Color.green : Color.gray)
                    )
            }
            .disabled(!canSend)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .overlay(alignment: .top) {
            Divider()
        }
    }

    private var canSend: Bool {
        !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isSending
    }

    private func sendMessage() {
        guard canSend else { return }
        let content = messageText
        messageText = ""

        Task {
            let success = await viewModel.sendMessage(to: conversation.id, content: content)
            if !success {
                messageText = content
            }
        }
    }
}

// MARK: - Message Bubble

struct MessageBubble: View {
    let message: ChatMessage
    let isOwn: Bool
    let formatTime: (Date) -> String

    var body: some View {
        HStack {
            if isOwn { Spacer(minLength: 60) }

            VStack(alignment: isOwn ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.body)
                    .foregroundStyle(isOwn ? .white : .primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 18)
                            .fill(isOwn ? Color(hex: "E53935") : Color(.systemGray5))
                    )

                Text(formatTime(message.createdAt))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 4)
            }

            if !isOwn { Spacer(minLength: 60) }
        }
    }
}

#Preview {
    NavigationStack {
        ChatDetailView(
            conversation: Conversation(
                id: "1",
                otherParticipant: ChatParticipant(
                    id: "2",
                    profileId: nil,
                    name: "Test Restaurant",
                    username: "testrestaurant",
                    avatar: nil,
                    role: .restaurant
                ),
                lastMessage: LastMessage(
                    content: "Hola!",
                    createdAt: Date(),
                    senderId: "2",
                    isRead: true
                ),
                lastMessageAt: Date(),
                unreadCount: 0,
                createdAt: Date()
            ),
            viewModel: ChatViewModel()
        )
    }
}
