//
//  ChatViewModel.swift
//  Solofoodies
//

import Foundation
import Combine

@MainActor
final class ChatViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var conversations: [Conversation] = []
    @Published var messages: [ChatMessage] = []
    @Published var unreadCount: Int = 0

    @Published var isLoading = false
    @Published var isLoadingMessages = false
    @Published var isSending = false
    @Published var error: String?

    @Published var searchText: String = ""

    private let service = ChatService.shared
    private var currentUserId: String?
    private var pollingTask: Task<Void, Never>?

    // MARK: - Computed Properties

    var filteredConversations: [Conversation] {
        guard !searchText.isEmpty else { return conversations }
        return conversations.filter { conversation in
            conversation.otherParticipant.name.localizedCaseInsensitiveContains(searchText) ||
            (conversation.otherParticipant.username?.localizedCaseInsensitiveContains(searchText) ?? false)
        }
    }

    // MARK: - Initialization

    func setCurrentUserId(_ userId: String?) {
        currentUserId = userId
    }

    // MARK: - Load Conversations

    func loadConversations() async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            conversations = try await service.getConversations()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    func refresh() async {
        await loadConversations()
        await fetchUnreadCount()
    }

    // MARK: - Unread Count

    func fetchUnreadCount() async {
        do {
            unreadCount = try await service.getUnreadCount()
        } catch {
            print("Error fetching unread count: \(error)")
        }
    }

    // MARK: - Messages

    func loadMessages(for conversationId: String) async {
        guard !isLoadingMessages else { return }
        isLoadingMessages = true
        error = nil

        do {
            messages = try await service.getMessages(conversationId: conversationId)
            // Mark as read
            try await service.markAsRead(conversationId: conversationId)
            // Update local unread count for this conversation
            if let index = conversations.firstIndex(where: { $0.id == conversationId }) {
                let current = conversations[index]
                // Create new conversation with zero unread count
                conversations[index] = Conversation(
                    id: current.id,
                    otherParticipant: current.otherParticipant,
                    lastMessage: current.lastMessage,
                    lastMessageAt: current.lastMessageAt,
                    unreadCount: 0,
                    createdAt: current.createdAt
                )
            }
            await fetchUnreadCount()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error cargando mensajes")
        }

        isLoadingMessages = false
    }

    func sendMessage(to conversationId: String, content: String) async -> Bool {
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return false }
        guard !isSending else { return false }

        isSending = true

        do {
            let newMessage = try await service.sendMessage(conversationId: conversationId, content: content)
            messages.append(newMessage)
            isSending = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
            isSending = false
            return false
        } catch {
            self.error = String(localized: "Error enviando mensaje")
            isSending = false
            return false
        }
    }

    // MARK: - Polling for New Messages

    func startPolling(for conversationId: String) {
        stopPolling()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
                guard !Task.isCancelled else { break }

                do {
                    let newMessages = try await service.getMessages(conversationId: conversationId)
                    if newMessages.count != messages.count {
                        messages = newMessages
                        try await service.markAsRead(conversationId: conversationId)
                    }
                } catch {
                    // Silent fail for polling
                }
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    // MARK: - Conversation Management

    func getOrCreateConversation(with userId: String) async -> String? {
        do {
            let conversationId = try await service.getOrCreateConversation(otherUserId: userId)
            print("✅ Created/Got conversation: \(conversationId)")
            return conversationId
        } catch let apiError as APIError {
            print("❌ Chat API Error: \(apiError.localizedDescription)")
            self.error = apiError.localizedDescription
            return nil
        } catch {
            print("❌ Chat Error: \(error)")
            self.error = String(localized: "Error iniciando conversacion")
            return nil
        }
    }

    func startConversationFromCollaboration(collaborationId: String, initialMessage: String? = nil) async -> String? {
        do {
            return try await service.startConversationFromCollaboration(
                collaborationId: collaborationId,
                initialMessage: initialMessage
            )
        } catch {
            self.error = String(localized: "Error iniciando conversacion")
            return nil
        }
    }

    func hideConversation(_ conversationId: String) async -> Bool {
        do {
            _ = try await service.hideConversation(conversationId: conversationId)
            conversations.removeAll { $0.id == conversationId }
            return true
        } catch {
            self.error = String(localized: "Error al ocultar conversacion")
            return false
        }
    }

    // MARK: - Helpers

    func isOwnMessage(_ message: ChatMessage) -> Bool {
        message.senderId == currentUserId
    }

    func clearMessages() {
        messages = []
    }

    func clearError() {
        error = nil
    }

    // MARK: - Time Formatting

    func formatTimestamp(_ date: Date?) -> String {
        guard let date = date else { return "" }

        let now = Date()
        let diff = now.timeIntervalSince(date)

        let minutes = Int(diff / 60)
        let hours = Int(diff / 3600)
        let days = Int(diff / 86400)

        if minutes < 1 {
            return String(localized: "Ahora")
        } else if minutes < 60 {
            return "\(minutes)m"
        } else if hours < 24 {
            return "\(hours)h"
        } else if days < 7 {
            return "\(days)d"
        } else {
            return "\(days / 7)w"
        }
    }

    func formatMessageTime(_ date: Date) -> String {
        date.formatted(date: .omitted, time: .shortened)
    }
}
