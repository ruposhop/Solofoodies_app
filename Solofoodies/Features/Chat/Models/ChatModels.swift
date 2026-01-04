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

    // Handle different API response formats
    init(from decoder: Decoder) throws {
        // Try direct id at root
        if let container = try? decoder.container(keyedBy: CodingKeys.self) {
            // Try "id" key first
            if let id = try? container.decode(String.self, forKey: .id) {
                self.id = id
                return
            }
            // Try "conversationId" key
            if let conversationId = try? container.decode(String.self, forKey: .conversationId) {
                self.id = conversationId
                return
            }
            // Try nested "data" object
            if let data = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .data) {
                if let id = try? data.decode(String.self, forKey: .id) {
                    self.id = id
                    return
                }
            }
            // Try "conversation" object
            if let conversation = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .conversation) {
                if let id = try? conversation.decode(String.self, forKey: .id) {
                    self.id = id
                    return
                }
            }
        }
        throw DecodingError.dataCorrupted(
            DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Could not decode conversation ID")
        )
    }

    private enum CodingKeys: String, CodingKey {
        case id, conversationId, data, conversation
    }
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

    enum CodingKeys: String, CodingKey {
        case otherUserId // Keep camelCase for API
    }
}

struct CreateConversationFromCollaborationRequest: Encodable {
    let collaborationId: String
    let initialMessage: String?

    enum CodingKeys: String, CodingKey {
        case collaborationId, initialMessage // Keep camelCase for API
    }
}

struct SendMessageRequest: Encodable {
    let content: String
}

struct BulkMessageRequest: Encodable {
    let publicCollaborationId: String
    let message: String
    let statuses: [String]
    let introductoryOnly: Bool

    enum CodingKeys: String, CodingKey {
        case publicCollaborationId, message, statuses, introductoryOnly // Keep camelCase for API
    }
}

struct BulkMessageResponse: Decodable {
    let success: Bool
    let messagesSent: Int
    let messagesSkipped: Int
    let total: Int
}
