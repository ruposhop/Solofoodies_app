//
//  ProfileService.swift
//  Solofoodies
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private let api = APIClient.shared

    private init() {}

    // MARK: - Get User Ratings

    func getUserRatings(userId: String) async throws -> UserRatingsResponse {
        return try await api.get(.userRatings(userId: userId))
    }

    // MARK: - Get My Given Ratings

    func getMyGivenRatings() async throws -> [ProfileRating] {
        let response: RatingsListResponse = try await api.get(.myGivenRatings)
        return response.ratings
    }

    // MARK: - Get Pending Ratings Count

    func getPendingRatingsCount() async throws -> Int {
        let response: PendingRatingsResponse = try await api.get(.custom("ratings/pending-count"))
        return response.pendingRatings
    }

    // MARK: - Get Balance

    func getBalance() async throws -> BalanceInfo {
        return try await api.get(.custom("balance"))
    }

    // MARK: - Update Foodie Profile

    func updateFoodieProfile(bio: String?, profilePicture: String?) async throws {
        let body = UpdateFoodieProfileRequest(bio: bio, profilePicture: profilePicture)
        try await api.patch(.updateFoodieProfile, body: body)
    }

    // MARK: - Update Foodie Address

    func updateFoodieAddress(_ address: Address) async throws {
        try await api.patch(.updateFoodieAddress, body: address)
    }
}

// MARK: - Helper Types

private struct RatingsListResponse: Decodable {
    let ratings: [ProfileRating]
}

private struct PendingRatingsResponse: Decodable {
    let pendingRatings: Int
}

struct BalanceInfo: Decodable {
    let balance: Double
    let pendingBalance: Double
}

private struct UpdateFoodieProfileRequest: Encodable {
    let bio: String?
    let profilePicture: String?
}
