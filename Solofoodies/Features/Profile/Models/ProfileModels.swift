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
