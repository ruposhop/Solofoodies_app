//
//  ChatService.swift
//  Solofoodies
//

import Foundation

final class ChatService {
    static let shared = ChatService()
    private let api = APIClient.shared

    private init() {}

    // MARK: - Get Conversations

    func getConversations() async throws -> [Conversation] {
        let response: ConversationsResponse = try await api.get(.conversations)
        return response.data ?? []
    }

    // MARK: - Get or Create Conversation

    func getOrCreateConversation(otherUserId: String) async throws -> String {
        let body = CreateConversationRequest(otherUserId: otherUserId)
        let response: CreateConversationResponse = try await api.post(.createConversation, body: body)
        return response.id
    }

    // MARK: - Start Conversation from Collaboration

    func startConversationFromCollaboration(
        collaborationId: String,
        initialMessage: String? = nil
    ) async throws -> String {
        let body = CreateConversationFromCollaborationRequest(
            collaborationId: collaborationId,
            initialMessage: initialMessage
        )
        let response: CreateConversationResponse = try await api.post(
            .custom("chat/conversations/from-collaboration"),
            body: body
        )
        return response.id
    }

    // MARK: - Get Messages

    func getMessages(
        conversationId: String,
        limit: Int = 50,
        offset: Int = 0
    ) async throws -> [ChatMessage] {
        let queryItems = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        let response: MessagesResponse = try await api.get(
            .messages(conversationId: conversationId),
            queryItems: queryItems
        )
        return response.data ?? []
    }

    // MARK: - Send Message

    func sendMessage(conversationId: String, content: String) async throws -> ChatMessage {
        let body = SendMessageRequest(content: content)
        return try await api.post(.sendMessage(conversationId: conversationId), body: body)
    }

    // MARK: - Mark as Read

    @discardableResult
    func markAsRead(conversationId: String) async throws -> Int {
        let response: MarkAsReadResponse = try await api.put(.markAsRead(conversationId: conversationId))
        return response.markedAsRead
    }

    // MARK: - Get Unread Count

    func getUnreadCount() async throws -> Int {
        let response: UnreadCountResponse = try await api.get(.unreadCount)
        return response.unreadCount
    }

    // MARK: - Hide Conversation

    @discardableResult
    func hideConversation(conversationId: String) async throws -> Bool {
        let response: HideConversationResponse = try await api.delete(.hideConversation(conversationId: conversationId))
        return response.success
    }

    // MARK: - Send Bulk Message (Restaurant only)

    func sendBulkMessage(
        publicCollaborationId: String,
        message: String,
        statuses: [String],
        introductoryOnly: Bool
    ) async throws -> BulkMessageResponse {
        let body = BulkMessageRequest(
            publicCollaborationId: publicCollaborationId,
            message: message,
            statuses: statuses,
            introductoryOnly: introductoryOnly
        )
        return try await api.post(.custom("chat/bulk-message"), body: body)
    }
}
