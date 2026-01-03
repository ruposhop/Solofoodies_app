//
//  ChatModels.swift
//  Solofoodies
//

import Foundation

// MARK: - Chat Participant

struct ChatParticipant: Codable, Identifiable {
    let id: String
    let profileId: String?
    let name: String
    let username: String?
    let avatar: String?
    let role: UserRole
}

// MARK: - Chat Message

struct ChatMessage: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    let isRead: Bool
    let readAt: Date?
    let createdAt: Date
    let sender: MessageSender
}

struct MessageSender: Codable {
    let id: String
    let name: String
    let igUsername: String?
    let role: String
}

// MARK: - Conversation

struct Conversation: Codable, Identifiable, Hashable {
    let id: String
    let otherParticipant: ChatParticipant
    let lastMessage: LastMessage?
    let lastMessageAt: Date?
    let unreadCount: Int
    let createdAt: Date

    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct LastMessage: Codable {
    let content: String
    let createdAt: Date
    let senderId: String
    let isRead: Bool
}

// MARK: - API Responses

struct ConversationsResponse: Decodable {
    let data: [Conversation]?

    // Handle both array response and object with data property
    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let conversations = try? container.decode([Conversation].self) {
            self.data = conversations
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.data = try container.decodeIfPresent([Conversation].self, forKey: .data)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case data
    }
}

struct MessagesResponse: Decodable {
    let data: [ChatMessage]?

    init(from decoder: Decoder) throws {
        if let container = try? decoder.singleValueContainer(),
           let messages = try? container.decode([ChatMessage].self) {
            self.data = messages
        } else {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.data = try container.decodeIfPresent([ChatMessage].self, forKey: .data)
        }
    }

    private enum CodingKeys: String, CodingKey {
        case data
    }
}

struct CreateConversationResponse: Decodable {
    let id: String
}

struct UnreadCountResponse: Decodable {
    let unreadCount: Int
}

struct MarkAsReadResponse: Decodable {
    let markedAsRead: Int
}

struct HideConversationResponse: Decodable {
    let success: Bool
}

// MARK: - API Request Bodies

struct CreateConversationRequest: Encodable {
    let otherUserId: String
}

struct CreateConversationFromCollaborationRequest: Encodable {
    let collaborationId: String
    let initialMessage: String?
}

struct SendMessageRequest: Encodable {
    let content: String
}

struct BulkMessageRequest: Encodable {
    let publicCollaborationId: String
    let message: String
    let statuses: [String]
    let introductoryOnly: Bool
}

struct BulkMessageResponse: Decodable {
    let success: Bool
    let messagesSent: Int
    let messagesSkipped: Int
    let total: Int
}
