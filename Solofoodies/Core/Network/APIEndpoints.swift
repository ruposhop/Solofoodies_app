//
//  APIEndpoints.swift
//  Solofoodies
//

import Foundation

enum APIEndpoint {
    // MARK: - Auth
    case login
    case registerFoodie
    case registerRestaurant
    case verifyEmail
    case resendCode
    case forgotPassword
    case resetPassword
    case me

    // MARK: - Users
    case userProfile
    case updateUser
    case changePassword
    case deleteAccount

    // MARK: - Foodies
    case listFoodies
    case foodieProfile(id: String)
    case foodieByUsername(username: String)
    case updateFoodieProfile
    case updateFoodieAddress

    // MARK: - Restaurants
    case listRestaurants
    case restaurantProfile(id: String)
    case myRestaurants
    case createRestaurant
    case updateRestaurantProfile
    case restaurantLocations(restaurantId: String)
    case addLocation(restaurantId: String)
    case updateLocation(restaurantId: String, locationId: String)
    case deleteLocation(restaurantId: String, locationId: String)

    // MARK: - Public Collaborations
    case listPublicCollaborations
    case publicCollaboration(id: String)
    case myPublicCollaborations
    case createPublicCollaboration
    case updatePublicCollaboration(id: String)
    case updatePublicCollaborationStatus(id: String)
    case deletePublicCollaboration(id: String)
    case inviteFoodie(collaborationId: String)

    // MARK: - Collaborations (Applications)
    case applyCollaboration
    case myCollaborations
    case collaboration(id: String)
    case updateCollaborationStatus(id: String)
    case cancelCollaboration(id: String)
    case scheduleCollaboration(id: String)
    case addContentLink(id: String)
    case respondToInvitation(id: String)

    // MARK: - Chat
    case conversations
    case createConversation
    case messages(conversationId: String)
    case sendMessage(conversationId: String)
    case markAsRead(conversationId: String)
    case unreadCount
    case hideConversation(conversationId: String)

    // MARK: - Ratings
    case createRating
    case collaborationRatings(collaborationId: String)
    case userRatings(userId: String)
    case myGivenRatings
    case updateRating(id: String)
    case deleteRating(id: String)

    var path: String {
        switch self {
        // Auth
        case .login: return "auth/login"
        case .registerFoodie: return "auth/register/foodie"
        case .registerRestaurant: return "auth/register/restaurant"
        case .verifyEmail: return "auth/verify"
        case .resendCode: return "auth/resend-code"
        case .forgotPassword: return "auth/forgot-password"
        case .resetPassword: return "auth/reset-password"
        case .me: return "auth/me"

        // Users
        case .userProfile: return "users/me/profile"
        case .updateUser: return "users/me"
        case .changePassword: return "users/me/password"
        case .deleteAccount: return "users/me"

        // Foodies
        case .listFoodies: return "foodies"
        case .foodieProfile(let id): return "foodies/\(id)"
        case .foodieByUsername(let username): return "foodies/username/\(username)"
        case .updateFoodieProfile: return "foodies/me/profile"
        case .updateFoodieAddress: return "foodies/me/address"

        // Restaurants
        case .listRestaurants: return "restaurants"
        case .restaurantProfile(let id): return "restaurants/\(id)"
        case .myRestaurants: return "restaurants/my"
        case .createRestaurant: return "restaurants"
        case .updateRestaurantProfile: return "restaurants/me/profile"
        case .restaurantLocations(let id): return "restaurants/\(id)/locations"
        case .addLocation(let id): return "restaurants/\(id)/locations"
        case .updateLocation(let rid, let lid): return "restaurants/\(rid)/locations/\(lid)"
        case .deleteLocation(let rid, let lid): return "restaurants/\(rid)/locations/\(lid)"

        // Public Collaborations
        case .listPublicCollaborations: return "collaborations/public"
        case .publicCollaboration(let id): return "collaborations/public/\(id)"
        case .myPublicCollaborations: return "collaborations/public/my"
        case .createPublicCollaboration: return "collaborations/public"
        case .updatePublicCollaboration(let id): return "collaborations/public/\(id)"
        case .updatePublicCollaborationStatus(let id): return "collaborations/public/\(id)/status"
        case .deletePublicCollaboration(let id): return "collaborations/public/\(id)"
        case .inviteFoodie(let id): return "collaborations/public/\(id)/invite"

        // Collaborations
        case .applyCollaboration: return "collaborations"
        case .myCollaborations: return "collaborations/me"
        case .collaboration(let id): return "collaborations/\(id)"
        case .updateCollaborationStatus(let id): return "collaborations/\(id)/status"
        case .cancelCollaboration(let id): return "collaborations/\(id)"
        case .scheduleCollaboration(let id): return "collaborations/\(id)/schedule"
        case .addContentLink(let id): return "collaborations/\(id)/content-link"
        case .respondToInvitation(let id): return "collaborations/\(id)/respond"

        // Chat
        case .conversations: return "chat/conversations"
        case .createConversation: return "chat/conversations"
        case .messages(let id): return "chat/conversations/\(id)/messages"
        case .sendMessage(let id): return "chat/conversations/\(id)/messages"
        case .markAsRead(let id): return "chat/conversations/\(id)/read"
        case .unreadCount: return "chat/unread"
        case .hideConversation(let id): return "chat/conversations/\(id)"

        // Ratings
        case .createRating: return "ratings"
        case .collaborationRatings(let id): return "ratings/collaboration/\(id)"
        case .userRatings(let id): return "ratings/user/\(id)"
        case .myGivenRatings: return "ratings/my-given"
        case .updateRating(let id): return "ratings/\(id)"
        case .deleteRating(let id): return "ratings/\(id)"
        }
    }
}
