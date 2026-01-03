//
//  AuthModels.swift
//  Solofoodies
//

import Foundation

// MARK: - User Role

enum UserRole: String, Codable {
    case foodie = "FOODIE"
    case restaurant = "RESTAURANT"
    case admin = "ADMIN"
    case investor = "INVESTOR"
}

// MARK: - User

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let role: UserRole
    var igUsername: String?
    var emailVerified: Bool?
    var verificationCode: String?
    var language: String?
    var creditBalance: Double?
    var isAllStar: Bool?
    var createdAt: Date?
    var updatedAt: Date?

    // For foodie users
    var foodieProfile: FoodieProfileData?

    // For restaurant users - multi-restaurant support
    var activeRestaurantId: String?
    var restaurants: [RestaurantProfile]?
    var subscription: UserSubscription?
}

// MARK: - Foodie Profile

struct FoodieProfileData: Codable, Identifiable {
    let id: String
    var bio: String?
    var followers: Int
    var profilePicture: String?
    var address: Address?
    var socialNetworks: [SocialNetwork]?
}

struct SocialNetwork: Codable, Identifiable {
    let id: String
    let platform: SocialPlatform
    let username: String
    let followers: Int
    var engagementRate: Double?
    var profileUrl: String?
}

enum SocialPlatform: String, Codable {
    case instagram = "INSTAGRAM"
    case tiktok = "TIKTOK"
    case youtube = "YOUTUBE"
    case twitter = "TWITTER"
    case facebook = "FACEBOOK"
}

// MARK: - Restaurant Profile

struct RestaurantProfile: Codable, Identifiable {
    let id: String
    var restaurantName: String
    var contactName: String
    var status: RestaurantStatus
    var coverImage: String?
    var profilePicture: String?
    var bio: String?
    var followers: Int?
    var engagementRate: Double?
    var isVerified: Bool?
    var cif: String?
    var phone: String?
    var address: Address?
}

enum RestaurantStatus: String, Codable {
    case active = "ACTIVE"
    case paused = "PAUSED"
}

// MARK: - Address

struct Address: Codable {
    var line: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?
    var countryIso: String?
}

// MARK: - Subscription

struct UserSubscription: Codable, Identifiable {
    let id: String
    var status: SubscriptionStatus
    var billingPeriod: BillingPeriod
    var currentPeriodEnd: String?
    var plan: SubscriptionPlan?
    var isOnTrial: Bool?
    var trialEndsAt: String?
}

enum SubscriptionStatus: String, Codable {
    case active = "ACTIVE"
    case trialing = "TRIALING"
    case cancelled = "CANCELLED"
    case pastDue = "PAST_DUE"
}

enum BillingPeriod: String, Codable {
    case monthly = "MONTHLY"
    case quarterly = "QUARTERLY"
    case yearly = "YEARLY"
}

struct SubscriptionPlan: Codable, Identifiable {
    let id: String
    var name: String
    var maxRestaurants: Int?
    var monthlyPrice: Double
    var quarterlyPrice: Double
    var yearlyPrice: Double
}

// MARK: - Auth Requests

struct LoginRequest: Encodable {
    let email: String
    let password: String
}

struct RegisterFoodieRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let passwordConfirmation: String
    let inviteCode: String
    let igUsername: String
    // Optional address fields
    var phone: String?
    var line: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?
    var countryIso: String?
}

struct RegisterRestaurantRequest: Encodable {
    let name: String
    let email: String
    let password: String
    let passwordConfirmation: String
    let igUsername: String
    let contactName: String
    let phone: String
    // Restaurant address
    let line: String
    let city: String
    let state: String
    let zipCode: String
    let country: String
    let countryIso: String
    // Billing data
    let cif: String
    let businessName: String
    let addressLine: String
    let billingCity: String
    let billingState: String
    let billingZipCode: String
    let billingCountry: String
    let billingCountryIso: String
    // Agreements
    let termsAccepted: Bool
    let communicationsAccepted: Bool
    // Optional
    var inviteCode: String?
}

struct VerifyEmailRequest: Encodable {
    let code: String
}

struct ForgotPasswordRequest: Encodable {
    let email: String
}

struct ResetPasswordRequest: Encodable {
    let email: String
    let token: String
    let newPassword: String
}

// MARK: - Auth Responses

struct AuthResponse: Decodable {
    let token: String
    let refreshToken: String?
    let user: User
}

struct RegisterRestaurantResponse: Decodable {
    let token: String
    let refreshToken: String?
    let user: User
    let requiresSubscription: Bool?
}

struct MessageResponse: Decodable {
    let message: String
}
