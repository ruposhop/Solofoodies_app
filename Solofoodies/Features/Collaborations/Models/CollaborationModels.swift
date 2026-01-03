//
//  CollaborationModels.swift
//  Solofoodies
//

import Foundation

// MARK: - Enums

enum CollaborationType: String, Codable, CaseIterable {
    case influencerVisit = "INFLUENCER_VISIT"
    case delivery = "DELIVERY"
    case event = "EVENT"

    var displayName: String {
        switch self {
        case .influencerVisit: return String(localized: "Visita de Influencer")
        case .delivery: return String(localized: "Delivery/Unboxing")
        case .event: return String(localized: "Evento")
        }
    }

    var icon: String {
        switch self {
        case .influencerVisit: return "fork.knife"
        case .delivery: return "shippingbox"
        case .event: return "party.popper"
        }
    }
}

enum CollaborationStatus: String, Codable {
    case open = "OPEN"
    case paused = "PAUSED"
    case archived = "ARCHIVED"
    case closed = "CLOSED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

enum ApplicationStatus: String, Codable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"

    var displayName: String {
        switch self {
        case .pending: return String(localized: "Pendiente")
        case .accepted: return String(localized: "Aceptada")
        case .rejected: return String(localized: "Rechazada")
        case .completed: return String(localized: "Completada")
        case .cancelled: return String(localized: "Cancelada")
        }
    }

    var color: String {
        switch self {
        case .pending: return "FFA500"  // Orange
        case .accepted: return "4CAF50"  // Green
        case .rejected: return "F44336"  // Red
        case .completed: return "2196F3"  // Blue
        case .cancelled: return "9E9E9E"  // Gray
        }
    }
}

// MARK: - Location

struct CollaborationLocation: Codable, Identifiable {
    let id: String
    let name: String
    let line: String
    let city: String
    let state: String?
    let country: String
    let countryIso: String?
    let contactName: String?
    let contactPhone: String?
    let coverManagerSlug: String?
}

// MARK: - Public Collaboration (Restaurant Offer)

struct PublicCollaboration: Codable, Identifiable {
    let id: String
    let restaurantProfileId: String
    let type: CollaborationType
    let image: String?
    let requirements: String?
    let minFollowers: Int
    let maxCompanions: Int
    let creditMode: String
    let creditType: String
    let creditValue: Int
    let allowFoodieRateProposal: Bool
    let availableDays: [String]
    let locationIds: [String]
    let status: CollaborationStatus
    let isPrivate: Bool
    let createdAt: Date
    let updatedAt: Date

    // Delivery-specific
    let productName: String?
    let productRequirements: String?
    let quantityPerCreator: Int?
    let productValue: Double?
    let productValueCurrency: String?
    let productVariations: String?
    let shippingZoneName: String?
    let shipsWorldwide: Bool?

    // Event-specific
    let eventName: String?
    let venueName: String?
    let venueAddress: String?
    let eventCountry: String?
    let eventCountryIso: String?
    let eventCity: String?
    let eventProvince: String?
    let eventContactPerson: String?
    let eventContactPhone: String?
    let eventType: String?
    let eventDate: Date?
    let eventStartTime: String?
    let eventEndTime: String?
    let creatorArrivalTime: String?
    let rsvpDeadline: Date?
    let eventRequirements: String?
    let whatToExpect: [String]?
    let dressCode: String?
    let hashtags: String?
    let accountsToTag: String?
    let toneSuggestions: String?

    // Legacy fields
    let title: String?
    let description: String?
    let city: String?

    // Included relations
    let restaurantProfile: RestaurantProfileData?
    let collabLocations: [CollaborationLocation]?
    let provinces: [String]?
    let collaborations: [CollaborationSummary]?

    var displayTitle: String {
        if let eventName = eventName, !eventName.isEmpty {
            return eventName
        }
        if let productName = productName, !productName.isEmpty {
            return productName
        }
        return restaurantProfile?.restaurantName ?? String(localized: "Colaboracion")
    }

    var displayLocation: String {
        if type == .event {
            return [eventCity, eventProvince].compactMap { $0 }.joined(separator: ", ")
        }
        if let locations = collabLocations, !locations.isEmpty {
            return locations.first?.city ?? ""
        }
        return city ?? ""
    }

    var creditDescription: String {
        switch creditMode {
        case "exchange":
            return String(localized: "Intercambio")
        case "credit":
            if creditType == "percentage" {
                return "\(creditValue)% \(String(localized: "credito"))"
            }
            return "\(creditValue)€ \(String(localized: "credito"))"
        case "discount":
            if creditType == "percentage" {
                return "\(creditValue)% \(String(localized: "descuento"))"
            }
            return "\(creditValue)€ \(String(localized: "descuento"))"
        case "payment":
            return String(localized: "Remunerado")
        default:
            return String(localized: "Intercambio")
        }
    }
}

struct CollaborationSummary: Codable, Identifiable {
    let id: String
}

// MARK: - Restaurant Profile Data (for collaborations)

struct RestaurantProfileData: Codable, Identifiable {
    let id: String
    let restaurantName: String
    let contactName: String?
    let coverImage: String?
    let bio: String?
    let followers: Int?
    let profilePicture: String?
    let user: RestaurantUserData?
    let address: Address?
    let locations: [CollaborationLocation]?
}

struct RestaurantUserData: Codable, Identifiable {
    let id: String
    let name: String
    let igUsername: String?
}

// MARK: - Collaboration (Application)

struct Collaboration: Codable, Identifiable {
    let id: String
    let publicCollaborationId: String?
    let foodieId: String
    let restaurantId: String
    let message: String?
    let numberOfPeople: Int?
    let specialRequirements: String?
    let status: ApplicationStatus
    let isInvitation: Bool
    let image: String?
    let scheduledDate: Date?
    let selectedLocationId: String?
    let selectedLocationName: String?
    let numberOfActualPeople: Int?
    let notes: String?
    let contentLinks: [String]
    let proposedRate: Double?
    let createdAt: Date
    let updatedAt: Date

    // Delivery-specific
    let deliveryAddress: String?
    let deliveryCity: String?
    let deliveryState: String?
    let deliveryZipCode: String?
    let deliveryCountry: String?
    let deliveryPhone: String?
    let deliveryAvailableDays: [String]?
    let deliveryTimeSlot: String?
    let deliveryInfoConfirmed: Bool?

    // Payment tracking
    let chargeStatus: String?
    let chargeAmount: Double?

    // Relations
    let foodie: CollaborationUser?
    let restaurant: CollaborationUser?
    let publicCollaboration: PublicCollaboration?
    let ratings: [Rating]?
}

struct CollaborationUser: Codable, Identifiable {
    let id: String
    let name: String
    let igUsername: String?
    let email: String?
    let phone: String?
}

// MARK: - Rating

struct Rating: Codable, Identifiable {
    let id: String
    let collaborationId: String?
    let raterId: String
    let ratedId: String
    let score: Int
    let comment: String?
    let punctuality: Int?
    let professionalism: Int?
    let contentQuality: Int?
    let communication: Int?
    let overall: Int?
    let createdAt: Date
}

// MARK: - API Requests

struct ApplyForCollaborationRequest: Encodable {
    let publicCollaborationId: String
    let message: String?
    let numberOfPeople: Int?
    let specialRequirements: String?
    let proposedRate: Double?
}

struct ScheduleCollaborationRequest: Encodable {
    let scheduledDate: String
    let selectedLocationId: String?
    let selectedLocationName: String?
}

struct ContentLinkRequest: Encodable {
    let link: String
}

struct DeliveryInfoRequest: Encodable {
    let address: String
    let city: String
    let state: String?
    let zipCode: String?
    let country: String?
    let phone: String?
    let availableDays: [String]
    let timeSlot: String
    let saveAsDefault: Bool?
}

struct InvitationResponseRequest: Encodable {
    let response: String  // "accept" or "reject"
}

struct StatusUpdateRequest: Encodable {
    let status: String
}

struct CreatePublicCollaborationRequest: Encodable {
    let type: String
    let image: String?
    let requirements: String?
    let minFollowers: Int
    let maxCompanions: Int
    let creditMode: String
    let creditType: String
    let creditValue: Int
    let allowFoodieRateProposal: Bool
    let availableDays: [String]
    let locationIds: [String]
    let isPrivate: Bool

    // Delivery-specific
    let productName: String?
    let productRequirements: String?
    let quantityPerCreator: Int?
    let productValue: Double?
    let productVariations: String?
    let shipsWorldwide: Bool?

    // Event-specific
    let eventName: String?
    let venueName: String?
    let venueAddress: String?
    let eventCity: String?
    let eventProvince: String?
    let eventCountry: String?
    let eventCountryIso: String?
    let eventContactPerson: String?
    let eventContactPhone: String?
    let eventType: String?
    let eventDate: String?
    let eventStartTime: String?
    let eventEndTime: String?
    let creatorArrivalTime: String?
    let rsvpDeadline: String?
    let eventRequirements: String?
    let whatToExpect: [String]?
    let dressCode: String?
    let hashtags: String?
    let accountsToTag: String?
    let toneSuggestions: String?
}

// MARK: - API Responses

struct PublicCollaborationsResponse: Decodable {
    let data: [PublicCollaboration]
    let pagination: PaginationInfo?
}

struct PaginationInfo: Decodable {
    let limit: Int
    let offset: Int
    let total: Int
}

struct DeliveryDefaultsResponse: Decodable {
    let address: String?
    let city: String?
    let state: String?
    let zipCode: String?
    let country: String?
    let availableDays: [String]?
    let timeSlot: String?
}
