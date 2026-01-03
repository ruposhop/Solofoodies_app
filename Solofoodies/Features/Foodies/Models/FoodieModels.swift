//
//  FoodieModels.swift
//  Solofoodies
//

import Foundation

// MARK: - Foodie Profile for Listing

struct FoodieListItem: Codable, Identifiable {
    let id: String
    let user: FoodieUserInfo
    let profilePicture: String?
    let bio: String?
    let followers: Int
    let address: FoodieAddress?
    let socialNetworks: [FoodieSocialNetwork]?
    let rates: [FoodieRate]?
    let trips: [FoodieTrip]?
    let avgRating: Double?
    let reviewCount: Int?
    let completedCollaborations: Int?

    var displayName: String {
        user.name
    }

    var igUsername: String {
        user.igUsername ?? socialNetworks?.first(where: { $0.platform == .instagram })?.username ?? ""
    }

    var city: String {
        address?.city ?? ""
    }

    var totalFollowers: Int {
        socialNetworks?.reduce(0) { $0 + $1.followers } ?? followers
    }

    var instagramFollowers: Int {
        socialNetworks?.first(where: { $0.platform == .instagram })?.followers ?? followers
    }

    var engagementRate: Double {
        socialNetworks?.first(where: { $0.platform == .instagram })?.engagementRate ?? 0
    }
}

struct FoodieUserInfo: Codable, Identifiable {
    let id: String
    let name: String
    let igUsername: String?
    let email: String?
    let phone: String?
}

struct FoodieAddress: Codable {
    let id: String?
    let line: String?
    let city: String
    let state: String?
    let zipCode: String?
    let country: String?
    let countryIso: String?
}

struct FoodieSocialNetwork: Codable, Identifiable {
    let id: String
    let platform: SocialPlatform
    let username: String
    let followers: Int
    let engagementRate: Double
    let profileUrl: String?
}

// Note: SocialPlatform is defined in AuthModels.swift

struct FoodieRate: Codable, Identifiable {
    let id: String
    let description: String
    let price: Double
}

struct FoodieTrip: Codable, Identifiable {
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

// MARK: - API Responses

struct FoodiesListResponse: Decodable {
    let data: [FoodieListItem]
    let pagination: PaginationInfo?
}

struct ProvincesResponse: Decodable {
    let provinces: [String]?
    let provincesWithCountry: [ProvinceWithCountry]?
}

struct ProvinceWithCountry: Codable, Identifiable {
    let name: String
    let countryIso: String?

    var id: String { name }
}

// MARK: - Full Foodie Profile (for detail view)

struct FoodieProfile: Codable, Identifiable {
    let id: String
    let userId: String
    let bio: String?
    let followers: Int
    let instagramUrl: String?
    let profilePicture: String?
    let socialNetworks: [FoodieSocialNetwork]?
    let address: FoodieAddress?
    let trips: [FoodieTrip]?
    let rates: [FoodieRate]?
    let user: FoodieUserInfo?
    let avgRating: Double?
    let reviewCount: Int?
    let completedCollaborations: Int?
}
