//
//  ProfileModels.swift
//  Solofoodies
//

import Foundation

// MARK: - Rating Models

struct ProfileRating: Codable, Identifiable {
    let id: String
    let score: Int
    let comment: String?
    let createdAt: Date
    let rater: RatingRater?
}

struct RatingRater: Codable {
    let id: String
    let name: String
    let igUsername: String?
    let foodieProfile: RaterFoodieProfile?
    let restaurantProfiles: [RaterRestaurantProfile]?
}

struct RaterFoodieProfile: Codable {
    let profilePicture: String?
}

struct RaterRestaurantProfile: Codable {
    let restaurantName: String
    let profilePicture: String?
}

struct RatingStats: Codable {
    let totalRatings: Int
    let averageScore: Double?
}

// MARK: - Full User Profile (from /users/me/profile)

struct FullUserProfile: Decodable, Identifiable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let language: String?
    let igUsername: String?
    let emailVerified: Bool?
    let isAllStar: Bool?
    let creditBalance: Double?

    // Foodie specific
    let foodieProfile: FullFoodieProfile?

    // Restaurant specific
    let activeRestaurantId: String?
    let restaurantProfiles: [FullRestaurantProfile]?
    let subscription: UserSubscription?
}

struct FullFoodieProfile: Decodable, Identifiable {
    let id: String
    let bio: String?
    let followers: Int
    let profilePicture: String?
    let address: Address?
    let trips: [ProfileTrip]?
    let socialNetworks: [ProfileSocialNetwork]?
    let rates: [ProfileRate]?
}

struct ProfileTrip: Decodable, Identifiable {
    let id: String
    let country: String
    let countryIso: String?
    let state: String
    let stateIso: String?
    let startDate: Date
    let endDate: Date

    var isActive: Bool {
        let now = Date()
        return now >= startDate && now <= endDate
    }

    var isUpcoming: Bool {
        Date() < startDate
    }
}

struct ProfileSocialNetwork: Decodable, Identifiable {
    let id: String
    let platform: SocialPlatform
    let username: String
    let followers: Int
    let engagementRate: Double?
    let profileUrl: String?
}

struct ProfileRate: Decodable, Identifiable {
    let id: String
    let description: String
    let price: Double
}

struct FullRestaurantProfile: Decodable, Identifiable {
    let id: String
    let restaurantName: String
    let contactName: String
    let status: RestaurantStatus
    let coverImage: String?
    let profilePicture: String?
    let bio: String?
    let followers: Int?
    let engagementRate: Double?
    let isVerified: Bool?
    let cif: String?
    let phone: String?
    let address: Address?
    let billingAddress: Address?
}

// MARK: - API Responses

struct UserRatingsResponse: Decodable {
    let ratings: [ProfileRating]
    let statistics: RatingStats
}

// MARK: - Profile Menu Item

struct ProfileMenuItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let destination: ProfileDestination
}

enum ProfileDestination {
    case editProfile
    case trips
    case reviews
    case collaborations
    case rates
    case history
    case invitations
    case settings
    case balance
}
