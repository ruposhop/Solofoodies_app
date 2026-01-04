//
//  ChatService.swift
//  Solofoodies
//

import Foundation

final class ChatService {
    static let shared = ChatService()
    private let api = APIClient.shared

    // Encoder without snake_case conversion for chat endpoints
    private let camelCaseEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        // NO keyEncodingStrategy - keeps camelCase
        return encoder
    }()

    private init() {}

    // MARK: - Get Conversations

    func getConversations() async throws -> [Conversation] {
        let response: ConversationsResponse = try await api.get(.conversations)
        return response.data ?? []
    }

    // MARK: - Get or Create Conversation

    func getOrCreateConversation(otherUserId: String) async throws -> String {
        // Use custom request to ensure camelCase keys
        let url = URL(string: "https://solofoodiesnewreact-production-7dd9.up.railway.app/api/chat/conversations")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if let token = KeychainManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Manually create JSON with correct camelCase key
        let bodyDict = ["otherUserId": otherUserId]
        request.httpBody = try JSONSerialization.data(withJSONObject: bodyDict)

        print("🌐 Chat Request: POST \(url)")
        print("📤 Body: \(String(data: request.httpBody!, encoding: .utf8) ?? "")")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        print("📥 Response: \(httpResponse.statusCode)")
        print("📥 Data: \(String(data: data, encoding: .utf8) ?? "")")

        guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.unknown(httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .iso8601

        let conversationResponse = try decoder.decode(CreateConversationResponse.self, from: data)
        return conversationResponse.id
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
