//
//  CollaborationService.swift
//  Solofoodies
//

import Foundation

final class CollaborationService {
    static let shared = CollaborationService()
    private let api = APIClient.shared

    private init() {}

    // MARK: - Public Collaborations

    func listPublicCollaborations(
        limit: Int = 20,
        offset: Int = 0,
        city: String? = nil,
        status: String? = nil
    ) async throws -> [PublicCollaboration] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]
        if let city = city {
            queryItems.append(URLQueryItem(name: "city", value: city))
        }
        if let status = status {
            queryItems.append(URLQueryItem(name: "status", value: status))
        }

        let response: PublicCollaborationsResponse = try await api.get(
            .listPublicCollaborations,
            queryItems: queryItems
        )
        return response.data
    }

    func getPublicCollaboration(id: String) async throws -> PublicCollaboration {
        return try await api.get(.publicCollaboration(id: id))
    }

    func getMyPublicCollaborations() async throws -> [PublicCollaboration] {
        let response: PublicCollaborationsResponse = try await api.get(.myPublicCollaborations)
        return response.data
    }

    func createPublicCollaboration(request: CreatePublicCollaborationRequest) async throws -> PublicCollaboration {
        return try await api.post(.createPublicCollaboration, body: request)
    }

    func updatePublicCollaboration(id: String, request: CreatePublicCollaborationRequest) async throws -> PublicCollaboration {
        return try await api.put(.updatePublicCollaboration(id: id), body: request)
    }

    func updatePublicCollaborationStatus(id: String, status: String) async throws {
        try await api.patch(.updatePublicCollaborationStatus(id: id), body: StatusUpdateRequest(status: status))
    }

    func deletePublicCollaboration(id: String) async throws {
        try await api.delete(.deletePublicCollaboration(id: id))
    }

    func inviteFoodieToCollaboration(collaborationId: String, foodieId: String) async throws {
        struct InviteRequest: Encodable {
            let foodieId: String
        }
        try await api.post(.inviteFoodie(collaborationId: collaborationId), body: InviteRequest(foodieId: foodieId))
    }

    // MARK: - Collaboration Applications

    func applyForCollaboration(request: ApplyForCollaborationRequest) async throws -> Collaboration {
        return try await api.post(.applyCollaboration, body: request)
    }

    func getMyCollaborations() async throws -> [Collaboration] {
        return try await api.get(.myCollaborations)
    }

    func getCollaboration(id: String) async throws -> Collaboration {
        return try await api.get(.collaboration(id: id))
    }

    func updateCollaborationStatus(id: String, status: String) async throws -> Collaboration {
        return try await api.patch(.updateCollaborationStatus(id: id), body: StatusUpdateRequest(status: status))
    }

    func cancelCollaboration(id: String) async throws {
        try await api.delete(.cancelCollaboration(id: id))
    }

    func scheduleCollaboration(id: String, request: ScheduleCollaborationRequest) async throws -> Collaboration {
        return try await api.post(.scheduleCollaboration(id: id), body: request)
    }

    func addContentLink(id: String, link: String) async throws -> Collaboration {
        return try await api.post(.addContentLink(id: id), body: ContentLinkRequest(link: link))
    }

    func removeContentLink(id: String, link: String) async throws {
        struct DeleteRequest: Encodable {
            let link: String
        }
        // For DELETE with body, we'd need special handling - typically this would be a POST endpoint
        // Based on web code it's DELETE with body - may need API adjustment
        try await api.delete(.removeContentLink(id: id))
    }

    func respondToInvitation(id: String, accept: Bool) async throws -> Collaboration {
        let response = accept ? "accept" : "reject"
        return try await api.post(.respondToInvitation(id: id), body: InvitationResponseRequest(response: response))
    }

    // MARK: - Delivery

    func getDeliveryDefaults() async throws -> DeliveryDefaultsResponse {
        return try await api.get(.deliveryDefaults)
    }

    func confirmDeliveryInfo(id: String, request: DeliveryInfoRequest) async throws -> Collaboration {
        return try await api.post(.confirmDeliveryInfo(id: id), body: request)
    }
}
