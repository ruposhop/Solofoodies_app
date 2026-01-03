# App iOS Nativa para Solofoodies - Plan Detallado

## Decisión: Swift Nativo con SwiftUI

Basado en tu preferencia, este plan detalla el desarrollo de una app iOS nativa usando Swift y SwiftUI.

---

## 1. STACK TECNOLÓGICO

```
- Lenguaje: Swift 5.9+
- UI Framework: SwiftUI
- Mínimo iOS: 16.0
- Arquitectura: MVVM (Model-View-ViewModel)
- Networking: URLSession + async/await
- Almacenamiento seguro: Keychain (para JWT)
- Persistencia local: SwiftData o Core Data
- Inyección de dependencias: Swift Package (o Swinject)
```

---

## 2. ESTRUCTURA DEL PROYECTO XCODE

```
Solofoodies/
├── App/
│   ├── SolofoodiesApp.swift          # Entry point
│   └── ContentView.swift              # Root view con navegación
│
├── Features/
│   ├── Auth/
│   │   ├── Views/
│   │   │   ├── LoginView.swift
│   │   │   ├── RegisterFoodieView.swift
│   │   │   ├── RegisterRestaurantView.swift
│   │   │   └── VerifyEmailView.swift
│   │   ├── ViewModels/
│   │   │   └── AuthViewModel.swift
│   │   └── Models/
│   │       └── AuthModels.swift
│   │
│   ├── Foodies/
│   │   ├── Views/
│   │   │   ├── FoodieProfileView.swift
│   │   │   ├── FoodiePublicProfileView.swift
│   │   │   ├── EditFoodieProfileView.swift
│   │   │   └── FoodieListView.swift
│   │   ├── ViewModels/
│   │   │   └── FoodieViewModel.swift
│   │   └── Models/
│   │       └── FoodieModels.swift
│   │
│   ├── Restaurants/
│   │   ├── Views/
│   │   │   ├── RestaurantProfileView.swift
│   │   │   ├── EditRestaurantProfileView.swift
│   │   │   ├── LocationsManagementView.swift
│   │   │   └── SubscriptionView.swift
│   │   ├── ViewModels/
│   │   │   └── RestaurantViewModel.swift
│   │   └── Models/
│   │       └── RestaurantModels.swift
│   │
│   ├── Collaborations/
│   │   ├── Views/
│   │   │   ├── CollaborationBrowseView.swift
│   │   │   ├── CollaborationDetailView.swift
│   │   │   ├── ApplicationFormView.swift
│   │   │   ├── MyCollaborationsView.swift
│   │   │   ├── CreateCollaborationView.swift
│   │   │   └── ManageApplicationsView.swift
│   │   ├── ViewModels/
│   │   │   └── CollaborationViewModel.swift
│   │   └── Models/
│   │       └── CollaborationModels.swift
│   │
│   ├── Chat/
│   │   ├── Views/
│   │   │   ├── ConversationsListView.swift
│   │   │   └── ChatView.swift
│   │   ├── ViewModels/
│   │   │   └── ChatViewModel.swift
│   │   └── Models/
│   │       └── ChatModels.swift
│   │
│   └── Ratings/
│       ├── Views/
│       │   ├── LeaveRatingView.swift
│       │   └── RatingsListView.swift
│       ├── ViewModels/
│       │   └── RatingViewModel.swift
│       └── Models/
│           └── RatingModels.swift
│
├── Core/
│   ├── Network/
│   │   ├── APIClient.swift            # HTTP client con async/await
│   │   ├── APIEndpoints.swift         # Endpoints enum
│   │   ├── APIError.swift             # Error handling
│   │   └── AuthInterceptor.swift      # Añade Bearer token
│   │
│   ├── Services/
│   │   ├── AuthService.swift
│   │   ├── FoodieService.swift
│   │   ├── RestaurantService.swift
│   │   ├── CollaborationService.swift
│   │   ├── ChatService.swift
│   │   └── RatingService.swift
│   │
│   ├── Storage/
│   │   ├── KeychainManager.swift      # JWT storage seguro
│   │   └── UserDefaultsManager.swift  # Preferencias no sensibles
│   │
│   └── Utilities/
│       ├── DateFormatter+Extensions.swift
│       ├── String+Extensions.swift
│       └── View+Extensions.swift
│
├── Shared/
│   ├── Components/
│   │   ├── LoadingView.swift
│   │   ├── ErrorView.swift
│   │   ├── AvatarView.swift
│   │   ├── StarRatingView.swift
│   │   ├── CollaborationCard.swift
│   │   └── EmptyStateView.swift
│   │
│   ├── Styles/
│   │   ├── Colors.swift               # Brand colors
│   │   ├── Typography.swift           # Font styles
│   │   └── ButtonStyles.swift
│   │
│   └── Localization/
│       ├── es.lproj/Localizable.strings
│       └── en.lproj/Localizable.strings
│
└── Resources/
    ├── Assets.xcassets
    ├── Info.plist
    └── Solofoodies.entitlements
```

---

## 3. MODELOS DE DATOS (Swift)

### 3.1 Enums

```swift
// Roles de usuario
enum UserRole: String, Codable {
    case foodie = "FOODIE"
    case restaurant = "RESTAURANT"
    case admin = "ADMIN"
    case investor = "INVESTOR"
}

// Estados de colaboración
enum CollaborationStatus: String, Codable {
    case pending = "PENDING"
    case accepted = "ACCEPTED"
    case rejected = "REJECTED"
    case completed = "COMPLETED"
    case cancelled = "CANCELLED"
}

// Tipos de colaboración pública
enum CollaborationType: String, Codable {
    case influencerVisit = "INFLUENCER_VISIT"
    case delivery = "DELIVERY"
    case event = "EVENT"
}

// Modos de crédito
enum CreditMode: String, Codable {
    case exchange = "exchange"
    case credit = "credit"
    case discount = "discount"
    case payment = "payment"
}

// Estados de restaurant
enum RestaurantStatus: String, Codable {
    case active = "ACTIVE"
    case paused = "PAUSED"
}
```

### 3.2 Modelos Base

```swift
// Usuario
struct User: Codable, Identifiable {
    let id: String
    let email: String
    let name: String
    let role: UserRole
    let language: String
    let emailVerified: Bool
    let creditBalance: Double?
    let isAllStar: Bool?
    let igUsername: String?
    let createdAt: Date
    let updatedAt: Date

    // Relaciones opcionales
    var foodieProfile: FoodieProfile?
    var restaurants: [RestaurantProfile]?
    var subscription: Subscription?
}

// Perfil Foodie
struct FoodieProfile: Codable, Identifiable {
    let id: String
    let userId: String
    var bio: String?
    var followers: Int
    var profilePicture: String?
    var address: Address?
    var socialNetworks: [SocialNetwork]
    var rates: [FoodieRate]
    var trips: [Trip]
    var defaultDeliveryAddress: String?
    var city: String?
    var state: String?
    var availableDays: [String]?
}

// Perfil Restaurante
struct RestaurantProfile: Codable, Identifiable {
    let id: String
    let userId: String
    var restaurantName: String
    var contactName: String
    var cif: String?
    var bio: String?
    var followers: Int?
    var engagementRate: Double?
    var profilePicture: String?
    var status: RestaurantStatus
    var isVerified: Bool
    var address: Address?
    var locations: [RestaurantLocation]
    var billingAddress: BillingAddress?
}

// Dirección
struct Address: Codable {
    var line: String?
    var city: String?
    var state: String?
    var zipCode: String?
    var country: String?
}

// Ubicación de restaurante
struct RestaurantLocation: Codable, Identifiable {
    let id: String
    var name: String
    var address: Address
    var googleMapsUrl: String?
}

// Red social
struct SocialNetwork: Codable, Identifiable {
    var id: String { platform }
    let platform: String
    let username: String
    let followers: Int
    let engagementRate: Double?
}
```

### 3.3 Modelos de Colaboración

```swift
// Colaboración Pública (creada por restaurants)
struct PublicCollaboration: Codable, Identifiable {
    let id: String
    let restaurantProfileId: String
    let type: CollaborationType
    var image: String?
    var requirements: String?
    var minFollowers: Int
    var maxCompanions: Int
    var creditMode: CreditMode
    var creditValue: Int
    var allowFoodieRateProposal: Bool
    var availableDays: [String]
    var locationIds: [String]
    var status: String
    var isPrivate: Bool
    let createdAt: Date

    // Relaciones
    var restaurant: RestaurantProfile?
    var applications: [Collaboration]?

    // Campos específicos DELIVERY
    var productName: String?
    var productRequirements: String?
    var quantityPerCreator: Int?
    var productValue: Double?
    var shipsWorldwide: Bool?

    // Campos específicos EVENT
    var eventName: String?
    var venueName: String?
    var eventDate: Date?
    var eventStartTime: String?
    var eventEndTime: String?
}

// Colaboración (aplicación de foodie)
struct Collaboration: Codable, Identifiable {
    let id: String
    let publicCollaborationId: String?
    let foodieId: String
    let restaurantId: String
    var message: String?
    var numberOfPeople: Int
    var specialRequirements: String?
    var status: CollaborationStatus
    var isInvitation: Bool
    var scheduledDate: Date?
    var selectedLocationId: String?
    var selectedLocationName: String?
    var contentLinks: [String]
    let createdAt: Date

    // Relaciones
    var foodie: FoodieProfile?
    var restaurant: RestaurantProfile?
    var publicCollaboration: PublicCollaboration?

    // Delivery específico
    var deliveryAddress: String?
    var deliveryCity: String?
    var deliveryInfoConfirmed: Bool?
    var proposedRate: Double?

    // Pago
    var chargeStatus: String?
    var chargeAmount: Double?
}
```

### 3.4 Modelos de Chat

```swift
// Conversación
struct Conversation: Codable, Identifiable {
    let id: String
    let participant1Id: String
    let participant2Id: String
    var collaborationId: String?
    var lastMessageAt: Date?
    var lastMessagePreview: String?
    let createdAt: Date

    // Para UI
    var otherParticipant: User?
    var unreadCount: Int?
}

// Mensaje
struct ChatMessage: Codable, Identifiable {
    let id: String
    let conversationId: String
    let senderId: String
    let content: String
    var isRead: Bool
    var readAt: Date?
    let createdAt: Date

    // Para UI
    var sender: User?
}
```

### 3.5 Modelos de Rating

```swift
// Valoración
struct Rating: Codable, Identifiable {
    let id: String
    let collaborationId: String
    let raterId: String
    let ratedId: String
    var score: Int
    var comment: String?
    var punctuality: Int?
    var professionalism: Int?
    var contentQuality: Int?
    var communication: Int?
    var overall: Int?
    let createdAt: Date

    // Relaciones
    var rater: User?
    var rated: User?
    var collaboration: Collaboration?
}
```

---

## 4. CLIENTE HTTP (APIClient)

```swift
// Core/Network/APIClient.swift

import Foundation

actor APIClient {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        // Configurar desde Environment o Config
        self.baseURL = URL(string: "https://api.solofoodies.com/api")!

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
    }

    // MARK: - Request Methods

    func get<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        return try await request(endpoint, method: "GET")
    }

    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        return try await request(endpoint, method: "POST", body: body)
    }

    func put<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        return try await request(endpoint, method: "PUT", body: body)
    }

    func patch<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        return try await request(endpoint, method: "PATCH", body: body)
    }

    func delete(_ endpoint: APIEndpoint) async throws {
        let _: EmptyResponse = try await request(endpoint, method: "DELETE")
    }

    // MARK: - Private

    private func request<T: Decodable, B: Encodable>(
        _ endpoint: APIEndpoint,
        method: String,
        body: B? = nil as EmptyBody?
    ) async throws -> T {
        var request = URLRequest(url: baseURL.appendingPathComponent(endpoint.path))
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        // Añadir token de autenticación
        if let token = KeychainManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Añadir body si existe
        if let body = body {
            request.httpBody = try encoder.encode(body)
        }

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        switch httpResponse.statusCode {
        case 200...299:
            return try decoder.decode(T.self, from: data)
        case 401:
            KeychainManager.shared.clearToken()
            throw APIError.unauthorized
        case 403:
            throw APIError.forbidden
        case 404:
            throw APIError.notFound
        default:
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.unknown(httpResponse.statusCode)
        }
    }
}

// Tipos auxiliares
struct EmptyBody: Encodable {}
struct EmptyResponse: Decodable {}
struct ErrorResponse: Decodable {
    let error: String
}
```

---

## 5. ENDPOINTS API

```swift
// Core/Network/APIEndpoints.swift

enum APIEndpoint {
    // Auth
    case login
    case registerFoodie
    case registerRestaurant
    case verifyEmail
    case resendCode
    case forgotPassword
    case resetPassword
    case me

    // Users
    case userProfile
    case updateUser
    case changePassword
    case deleteAccount

    // Foodies
    case listFoodies(limit: Int, offset: Int, search: String?, province: String?)
    case foodieProfile(id: String)
    case foodieByUsername(username: String)
    case updateFoodieProfile
    case updateFoodieAddress
    case pendingFoodieRatings

    // Restaurants
    case listRestaurants(limit: Int, offset: Int, city: String?, search: String?)
    case restaurantProfile(id: String)
    case myRestaurants
    case createRestaurant
    case updateRestaurantProfile
    case updateRestaurantAddress
    case restaurantLocations(restaurantId: String)
    case addLocation(restaurantId: String)
    case updateLocation(restaurantId: String, locationId: String)
    case deleteLocation(restaurantId: String, locationId: String)
    case pendingRestaurantRatings

    // Public Collaborations
    case listPublicCollaborations(limit: Int, offset: Int, filters: [String: String]?)
    case publicCollaboration(id: String)
    case myPublicCollaborations
    case createPublicCollaboration
    case updatePublicCollaboration(id: String)
    case updatePublicCollaborationStatus(id: String)
    case deletePublicCollaboration(id: String)
    case inviteFoodie(collaborationId: String)

    // Collaborations (Applications)
    case applyCollaboration
    case myCollaborations
    case collaboration(id: String)
    case updateCollaborationStatus(id: String)
    case cancelCollaboration(id: String)
    case scheduleCollaboration(id: String)
    case addContentLink(id: String)
    case respondToInvitation(id: String)

    // Chat
    case conversations
    case createConversation
    case messages(conversationId: String, limit: Int, offset: Int)
    case sendMessage(conversationId: String)
    case markAsRead(conversationId: String)
    case unreadCount
    case hideConversation(conversationId: String)

    // Ratings
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
        case .pendingFoodieRatings: return "foodies/pending-ratings"

        // Restaurants
        case .listRestaurants: return "restaurants"
        case .restaurantProfile(let id): return "restaurants/\(id)"
        case .myRestaurants: return "restaurants/my"
        case .createRestaurant: return "restaurants"
        case .updateRestaurantProfile: return "restaurants/me/profile"
        case .updateRestaurantAddress: return "restaurants/me/address"
        case .restaurantLocations(let id): return "restaurants/\(id)/locations"
        case .addLocation(let id): return "restaurants/\(id)/locations"
        case .updateLocation(let rid, let lid): return "restaurants/\(rid)/locations/\(lid)"
        case .deleteLocation(let rid, let lid): return "restaurants/\(rid)/locations/\(lid)"
        case .pendingRestaurantRatings: return "restaurants/pending-ratings"

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
        case .messages(let id, _, _): return "chat/conversations/\(id)/messages"
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
```

---

## 6. KEYCHAIN MANAGER

```swift
// Core/Storage/KeychainManager.swift

import Foundation
import Security

final class KeychainManager {
    static let shared = KeychainManager()

    private let service = "com.solofoodies.app"
    private let tokenKey = "jwt_token"

    private init() {}

    func saveToken(_ token: String) {
        let data = Data(token.utf8)

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecValueData as String: data
        ]

        // Borrar existente
        SecItemDelete(query as CFDictionary)

        // Guardar nuevo
        SecItemAdd(query as CFDictionary, nil)
    }

    func getToken() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let data = result as? Data,
              let token = String(data: data, encoding: .utf8) else {
            return nil
        }

        return token
    }

    func clearToken() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: tokenKey
        ]

        SecItemDelete(query as CFDictionary)
    }

    var isAuthenticated: Bool {
        getToken() != nil
    }
}
```

---

## 7. EJEMPLO DE SERVICIO (AuthService)

```swift
// Core/Services/AuthService.swift

import Foundation

final class AuthService {
    static let shared = AuthService()
    private let api = APIClient.shared

    private init() {}

    // MARK: - Login

    struct LoginRequest: Encodable {
        let email: String
        let password: String
    }

    struct LoginResponse: Decodable {
        let token: String
        let user: User
    }

    func login(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, password: password)
        let response: LoginResponse = try await api.post(.login, body: request)

        KeychainManager.shared.saveToken(response.token)
        return response.user
    }

    // MARK: - Register Foodie

    struct RegisterFoodieRequest: Encodable {
        let email: String
        let password: String
        let name: String
        let igUsername: String?
        let language: String
        let referralCode: String?
    }

    func registerFoodie(
        email: String,
        password: String,
        name: String,
        igUsername: String?,
        language: String = "es",
        referralCode: String? = nil
    ) async throws -> User {
        let request = RegisterFoodieRequest(
            email: email,
            password: password,
            name: name,
            igUsername: igUsername,
            language: language,
            referralCode: referralCode
        )
        let response: LoginResponse = try await api.post(.registerFoodie, body: request)

        KeychainManager.shared.saveToken(response.token)
        return response.user
    }

    // MARK: - Verify Email

    struct VerifyRequest: Encodable {
        let code: String
    }

    func verifyEmail(code: String) async throws {
        let request = VerifyRequest(code: code)
        let _: EmptyResponse = try await api.post(.verifyEmail, body: request)
    }

    // MARK: - Get Current User

    func getCurrentUser() async throws -> User {
        return try await api.get(.me)
    }

    // MARK: - Logout

    func logout() {
        KeychainManager.shared.clearToken()
    }
}
```

---

## 8. EJEMPLO DE VIEWMODEL

```swift
// Features/Auth/ViewModels/AuthViewModel.swift

import Foundation
import SwiftUI

@MainActor
final class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isAuthenticated = false

    private let authService = AuthService.shared

    init() {
        isAuthenticated = KeychainManager.shared.isAuthenticated
        if isAuthenticated {
            Task { await loadCurrentUser() }
        }
    }

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            currentUser = try await authService.login(email: email, password: password)
            isAuthenticated = true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = "Error desconocido"
        }

        isLoading = false
    }

    func register(
        email: String,
        password: String,
        name: String,
        igUsername: String?
    ) async {
        isLoading = true
        error = nil

        do {
            currentUser = try await authService.registerFoodie(
                email: email,
                password: password,
                name: name,
                igUsername: igUsername
            )
            isAuthenticated = true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = "Error desconocido"
        }

        isLoading = false
    }

    func verifyEmail(code: String) async -> Bool {
        isLoading = true
        error = nil

        do {
            try await authService.verifyEmail(code: code)
            await loadCurrentUser()
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
            isLoading = false
            return false
        } catch {
            self.error = "Error desconocido"
            isLoading = false
            return false
        }
    }

    func logout() {
        authService.logout()
        currentUser = nil
        isAuthenticated = false
    }

    private func loadCurrentUser() async {
        do {
            currentUser = try await authService.getCurrentUser()
        } catch {
            logout()
        }
    }
}
```

---

## 9. EJEMPLO DE VISTA (LoginView)

```swift
// Features/Auth/Views/LoginView.swift

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegister = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // Logo
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200)
                    .padding(.top, 60)

                Spacer()

                // Form
                VStack(spacing: 16) {
                    TextField(String(localized: "Email"), text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    SecureField(String(localized: "Contraseña"), text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .padding(.horizontal, 24)

                // Error
                if let error = authViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                }

                // Login Button
                Button(action: {
                    Task {
                        await authViewModel.login(email: email, password: password)
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(String(localized: "Iniciar sesión"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("Primary"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)

                // Register Link
                Button(String(localized: "¿No tienes cuenta? Regístrate")) {
                    showRegister = true
                }
                .foregroundColor(Color("Primary"))

                Spacer()
            }
            .navigationDestination(isPresented: $showRegister) {
                RegisterSelectionView()
            }
        }
    }
}
```

---

## 10. NAVEGACIÓN PRINCIPAL

```swift
// App/ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if let user = authViewModel.currentUser {
                    switch user.role {
                    case .foodie:
                        FoodieTabView()
                    case .restaurant:
                        RestaurantTabView()
                    default:
                        LoginView()
                    }
                } else {
                    LoadingView()
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}

// Tab View para Foodies
struct FoodieTabView: View {
    var body: some View {
        TabView {
            CollaborationBrowseView()
                .tabItem {
                    Label(String(localized: "Explorar"), systemImage: "magnifyingglass")
                }

            MyCollaborationsView()
                .tabItem {
                    Label(String(localized: "Colaboraciones"), systemImage: "star.fill")
                }

            ConversationsListView()
                .tabItem {
                    Label(String(localized: "Chat"), systemImage: "message.fill")
                }

            FoodieProfileView()
                .tabItem {
                    Label(String(localized: "Perfil"), systemImage: "person.fill")
                }
        }
        .tint(Color("Primary"))
    }
}

// Tab View para Restaurants
struct RestaurantTabView: View {
    var body: some View {
        TabView {
            MyPublicCollaborationsView()
                .tabItem {
                    Label(String(localized: "Colaboraciones"), systemImage: "star.fill")
                }

            ManageApplicationsView()
                .tabItem {
                    Label(String(localized: "Solicitudes"), systemImage: "person.2.fill")
                }

            ConversationsListView()
                .tabItem {
                    Label(String(localized: "Chat"), systemImage: "message.fill")
                }

            RestaurantProfileView()
                .tabItem {
                    Label(String(localized: "Perfil"), systemImage: "person.fill")
                }
        }
        .tint(Color("Primary"))
    }
}
```

---

## 11. LOCALIZACIÓN (i18n)

### es.lproj/Localizable.strings
```
// Auth
"login.title" = "Iniciar sesión";
"login.email" = "Email";
"login.password" = "Contraseña";
"login.button" = "Iniciar sesión";
"login.noAccount" = "¿No tienes cuenta? Regístrate";
"login.forgotPassword" = "¿Olvidaste tu contraseña?";

"register.title" = "Crear cuenta";
"register.asFoodie" = "Soy Creador";
"register.asRestaurant" = "Soy Restaurante";
"register.name" = "Nombre";
"register.igUsername" = "Usuario de Instagram";
"register.button" = "Registrarse";

"verify.title" = "Verificar email";
"verify.message" = "Ingresa el código enviado a tu email";
"verify.button" = "Verificar";
"verify.resend" = "Reenviar código";

// Navigation
"tab.explore" = "Explorar";
"tab.collaborations" = "Colaboraciones";
"tab.chat" = "Chat";
"tab.profile" = "Perfil";

// Collaborations
"collab.apply" = "Aplicar";
"collab.details" = "Detalles";
"collab.requirements" = "Requisitos";
"collab.minFollowers" = "Mínimo %d seguidores";
"collab.companions" = "Máximo %d acompañantes";

// Chat
"chat.noMessages" = "No hay mensajes";
"chat.sendFirst" = "Envía el primer mensaje";
"chat.typeMessage" = "Escribe un mensaje...";

// Ratings
"rating.leave" = "Dejar valoración";
"rating.score" = "Puntuación";
"rating.comment" = "Comentario (opcional)";
"rating.submit" = "Enviar";

// Common
"common.loading" = "Cargando...";
"common.error" = "Error";
"common.retry" = "Reintentar";
"common.cancel" = "Cancelar";
"common.save" = "Guardar";
"common.delete" = "Eliminar";
```

### en.lproj/Localizable.strings
```
// Auth
"login.title" = "Log in";
"login.email" = "Email";
"login.password" = "Password";
"login.button" = "Log in";
"login.noAccount" = "Don't have an account? Sign up";
"login.forgotPassword" = "Forgot your password?";

"register.title" = "Create account";
"register.asFoodie" = "I'm a Creator";
"register.asRestaurant" = "I'm a Restaurant";
"register.name" = "Name";
"register.igUsername" = "Instagram username";
"register.button" = "Sign up";

// ... resto de traducciones
```

---

## 12. COLORES Y ESTILOS

```swift
// Shared/Styles/Colors.swift

import SwiftUI

extension Color {
    static let primary = Color("Primary")       // #E53935 (rojo Solofoodies)
    static let lowblack = Color("Lowblack")     // #333333
    static let dgray = Color("Dgray")           // #666666
    static let lgray = Color("Lgray")           // #F5F5F5
}

// Assets.xcassets/Colors/
// Primary: #E53935
// Lowblack: #333333
// Dgray: #666666
// Lgray: #F5F5F5
```

---

## 13. FASES DE DESARROLLO

### Fase 1 - MVP Core (4-6 semanas)
- [x] Setup proyecto Xcode
- [ ] Implementar APIClient y Keychain
- [ ] Auth completo (login, registro, verificación)
- [ ] Navegación básica (tabs)
- [ ] Explorar colaboraciones públicas
- [ ] Ver detalle de colaboración
- [ ] Aplicar a colaboración (foodies)
- [ ] Ver mis colaboraciones

### Fase 2 - Features Principales (4-6 semanas)
- [ ] Chat funcional
- [ ] Perfiles (ver y editar)
- [ ] Sistema de ratings
- [ ] Crear colaboración (restaurants)
- [ ] Gestionar aplicaciones (restaurants)
- [ ] Agendar visitas

### Fase 3 - Polish (2-4 semanas)
- [ ] Push notifications
- [ ] Optimización de imágenes (caching)
- [ ] Manejo offline básico
- [ ] Animaciones y transiciones
- [ ] Accesibilidad
- [ ] Testing

### Fase 4 - Publicación (1-2 semanas)
- [ ] App Store Connect setup
- [ ] Screenshots y metadata
- [ ] TestFlight beta
- [ ] Review de Apple
- [ ] Launch

---

## 14. FLUJO RESTAURANTES: CREAR COLABORACIONES

### 14.1 Tipos de Colaboración

```swift
enum CollaborationType: String, Codable, CaseIterable {
    case influencerVisit = "INFLUENCER_VISIT"  // Visita al restaurante
    case delivery = "DELIVERY"                  // Envío de producto
    case event = "EVENT"                        // Evento especial

    var displayName: String {
        switch self {
        case .influencerVisit: return String(localized: "Visita")
        case .delivery: return String(localized: "Delivery")
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
```

### 14.2 Modelo de Creación

```swift
// Request para crear colaboración pública
struct CreatePublicCollaborationRequest: Encodable {
    // Campos comunes
    let type: CollaborationType
    let restaurantProfileId: String
    var image: String?                    // URL de imagen (opcional)
    var requirements: String?             // Requisitos para el foodie
    var minFollowers: Int                 // Mínimo de seguidores requerido
    var maxCompanions: Int                // Máximo acompañantes permitidos
    var creditMode: CreditMode            // exchange, credit, discount, payment
    var creditValue: Int                  // Valor (100 = 100% o monto fijo)
    var allowFoodieRateProposal: Bool     // Permitir propuesta de tarifa
    var availableDays: [String]           // ["monday", "tuesday", ...]
    var locationIds: [String]             // IDs de ubicaciones seleccionadas
    var isPrivate: Bool                   // Solo por invitación

    // Campos específicos DELIVERY
    var productName: String?
    var productRequirements: String?
    var quantityPerCreator: Int?
    var productValue: Double?
    var productValueCurrency: String?     // "EUR", "MXN", "USD"
    var shipsWorldwide: Bool?
    var shippingZoneIds: [String]?

    // Campos específicos EVENT
    var eventName: String?
    var venueName: String?
    var venueAddress: String?
    var eventCountry: String?
    var eventCity: String?
    var eventProvince: String?
    var eventDate: Date?
    var eventStartTime: String?           // "19:00"
    var eventEndTime: String?             // "23:00"
    var creatorArrivalTime: String?       // "18:30"
    var rsvpDeadline: Date?
    var whatToExpect: [String]?
    var dressCode: String?
    var hashtags: [String]?
    var accountsToTag: [String]?
    var toneSuggestions: String?
}
```

### 14.3 Servicio de Colaboraciones (Restaurant)

```swift
// Core/Services/CollaborationService.swift

extension CollaborationService {

    // MARK: - Crear Colaboración Pública

    func createPublicCollaboration(_ request: CreatePublicCollaborationRequest) async throws -> PublicCollaboration {
        return try await api.post(.createPublicCollaboration, body: request)
    }

    // MARK: - Obtener Mis Colaboraciones Públicas

    func getMyPublicCollaborations() async throws -> [PublicCollaboration] {
        return try await api.get(.myPublicCollaborations)
    }

    // MARK: - Actualizar Colaboración

    func updatePublicCollaboration(id: String, request: CreatePublicCollaborationRequest) async throws -> PublicCollaboration {
        return try await api.put(.updatePublicCollaboration(id: id), body: request)
    }

    // MARK: - Cambiar Estado

    struct UpdateStatusRequest: Encodable {
        let status: String  // "OPEN", "PAUSED", "CLOSED"
    }

    func updatePublicCollaborationStatus(id: String, status: String) async throws {
        let request = UpdateStatusRequest(status: status)
        let _: EmptyResponse = try await api.patch(.updatePublicCollaborationStatus(id: id), body: request)
    }

    // MARK: - Eliminar Colaboración

    func deletePublicCollaboration(id: String) async throws {
        try await api.delete(.deletePublicCollaboration(id: id))
    }

    // MARK: - Invitar Foodie

    struct InviteFoodieRequest: Encodable {
        let foodieId: String
    }

    func inviteFoodieToCollaboration(collaborationId: String, foodieId: String) async throws {
        let request = InviteFoodieRequest(foodieId: foodieId)
        let _: EmptyResponse = try await api.post(.inviteFoodie(collaborationId: collaborationId), body: request)
    }

    // MARK: - Gestionar Aplicaciones

    func getCollaborationApplications(collaborationId: String) async throws -> [Collaboration] {
        // Las aplicaciones vienen incluidas en el detalle de la colaboración pública
        let collab: PublicCollaboration = try await api.get(.publicCollaboration(id: collaborationId))
        return collab.applications ?? []
    }

    func acceptApplication(applicationId: String) async throws {
        let request = UpdateStatusRequest(status: "ACCEPTED")
        let _: EmptyResponse = try await api.patch(.updateCollaborationStatus(id: applicationId), body: request)
    }

    func rejectApplication(applicationId: String) async throws {
        let request = UpdateStatusRequest(status: "REJECTED")
        let _: EmptyResponse = try await api.patch(.updateCollaborationStatus(id: applicationId), body: request)
    }

    func completeCollaboration(applicationId: String) async throws {
        let request = UpdateStatusRequest(status: "COMPLETED")
        let _: EmptyResponse = try await api.patch(.updateCollaborationStatus(id: applicationId), body: request)
    }
}
```

### 14.4 ViewModel para Crear Colaboración

```swift
// Features/Collaborations/ViewModels/CreateCollaborationViewModel.swift

@MainActor
final class CreateCollaborationViewModel: ObservableObject {
    // MARK: - Estado del formulario

    // Tipo de colaboración
    @Published var selectedType: CollaborationType = .influencerVisit

    // Campos comunes
    @Published var requirements: String = ""
    @Published var minFollowers: Int = 1000
    @Published var maxCompanions: Int = 1
    @Published var creditMode: CreditMode = .exchange
    @Published var creditValue: Int = 100
    @Published var allowFoodieRateProposal: Bool = false
    @Published var selectedDays: Set<String> = []
    @Published var selectedLocationIds: Set<String> = []
    @Published var isPrivate: Bool = false
    @Published var selectedImage: UIImage?

    // Campos DELIVERY
    @Published var productName: String = ""
    @Published var productRequirements: String = ""
    @Published var quantityPerCreator: Int = 1
    @Published var productValue: Double = 0
    @Published var shipsWorldwide: Bool = false

    // Campos EVENT
    @Published var eventName: String = ""
    @Published var venueName: String = ""
    @Published var venueAddress: String = ""
    @Published var eventDate: Date = Date()
    @Published var eventStartTime: Date = Date()
    @Published var eventEndTime: Date = Date()
    @Published var dressCode: String = ""
    @Published var hashtags: String = ""

    // Estado UI
    @Published var isLoading = false
    @Published var error: String?
    @Published var createdCollaboration: PublicCollaboration?

    // Datos del restaurante
    @Published var restaurant: RestaurantProfile?
    @Published var locations: [RestaurantLocation] = []

    private let collaborationService = CollaborationService.shared
    private let restaurantService = RestaurantService.shared
    private let uploadService = UploadService.shared

    // MARK: - Cargar datos iniciales

    func loadRestaurantData() async {
        do {
            let restaurants = try await restaurantService.getMyRestaurants()
            if let activeRestaurant = restaurants.first(where: { $0.status == .active }) {
                restaurant = activeRestaurant
                locations = activeRestaurant.locations
            }
        } catch {
            self.error = "Error cargando datos del restaurante"
        }
    }

    // MARK: - Validación

    var isFormValid: Bool {
        guard restaurant != nil else { return false }
        guard !selectedLocationIds.isEmpty || selectedType == .event else { return false }
        guard !selectedDays.isEmpty else { return false }

        switch selectedType {
        case .influencerVisit:
            return true
        case .delivery:
            return !productName.isEmpty && productValue > 0
        case .event:
            return !eventName.isEmpty && !venueName.isEmpty
        }
    }

    // MARK: - Crear colaboración

    func createCollaboration() async -> Bool {
        guard let restaurant = restaurant else { return false }

        isLoading = true
        error = nil

        do {
            // Subir imagen si existe
            var imageUrl: String?
            if let image = selectedImage {
                imageUrl = try await uploadService.uploadImage(image)
            }

            // Construir request
            var request = CreatePublicCollaborationRequest(
                type: selectedType,
                restaurantProfileId: restaurant.id,
                image: imageUrl,
                requirements: requirements.isEmpty ? nil : requirements,
                minFollowers: minFollowers,
                maxCompanions: maxCompanions,
                creditMode: creditMode,
                creditValue: creditValue,
                allowFoodieRateProposal: allowFoodieRateProposal,
                availableDays: Array(selectedDays),
                locationIds: Array(selectedLocationIds),
                isPrivate: isPrivate
            )

            // Añadir campos específicos según tipo
            switch selectedType {
            case .delivery:
                request.productName = productName
                request.productRequirements = productRequirements.isEmpty ? nil : productRequirements
                request.quantityPerCreator = quantityPerCreator
                request.productValue = productValue
                request.productValueCurrency = "EUR"
                request.shipsWorldwide = shipsWorldwide

            case .event:
                request.eventName = eventName
                request.venueName = venueName
                request.venueAddress = venueAddress
                request.eventDate = eventDate
                request.eventStartTime = formatTime(eventStartTime)
                request.eventEndTime = formatTime(eventEndTime)
                request.dressCode = dressCode.isEmpty ? nil : dressCode
                request.hashtags = hashtags.isEmpty ? nil : hashtags.split(separator: " ").map(String.init)

            case .influencerVisit:
                break
            }

            createdCollaboration = try await collaborationService.createPublicCollaboration(request)
            isLoading = false
            return true

        } catch let apiError as APIError {
            error = apiError.localizedDescription
            isLoading = false
            return false
        } catch {
            self.error = "Error creando colaboración"
            isLoading = false
            return false
        }
    }

    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
}
```

### 14.5 Vista: Crear Colaboración

```swift
// Features/Collaborations/Views/CreateCollaborationView.swift

struct CreateCollaborationView: View {
    @StateObject private var viewModel = CreateCollaborationViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Tipo de colaboración
                Section(String(localized: "Tipo de colaboración")) {
                    Picker(String(localized: "Tipo"), selection: $viewModel.selectedType) {
                        ForEach(CollaborationType.allCases, id: \.self) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // MARK: - Imagen
                Section(String(localized: "Imagen")) {
                    ImagePickerButton(selectedImage: $viewModel.selectedImage)
                }

                // MARK: - Requisitos
                Section(String(localized: "Requisitos")) {
                    TextField(
                        String(localized: "Describe los requisitos para el foodie..."),
                        text: $viewModel.requirements,
                        axis: .vertical
                    )
                    .lineLimit(3...6)

                    Stepper(
                        String(localized: "Mínimo \(viewModel.minFollowers) seguidores"),
                        value: $viewModel.minFollowers,
                        in: 500...1000000,
                        step: 500
                    )

                    Stepper(
                        String(localized: "Máximo \(viewModel.maxCompanions) acompañantes"),
                        value: $viewModel.maxCompanions,
                        in: 0...10
                    )
                }

                // MARK: - Compensación
                Section(String(localized: "Compensación")) {
                    Picker(String(localized: "Modo"), selection: $viewModel.creditMode) {
                        Text(String(localized: "Intercambio")).tag(CreditMode.exchange)
                        Text(String(localized: "Crédito")).tag(CreditMode.credit)
                        Text(String(localized: "Descuento")).tag(CreditMode.discount)
                        Text(String(localized: "Pago")).tag(CreditMode.payment)
                    }

                    if viewModel.creditMode != .exchange {
                        Stepper(
                            String(localized: "Valor: \(viewModel.creditValue)%"),
                            value: $viewModel.creditValue,
                            in: 10...100,
                            step: 10
                        )
                    }

                    Toggle(
                        String(localized: "Permitir propuesta de tarifa"),
                        isOn: $viewModel.allowFoodieRateProposal
                    )
                }

                // MARK: - Ubicaciones (solo VISIT)
                if viewModel.selectedType == .influencerVisit {
                    Section(String(localized: "Ubicaciones")) {
                        ForEach(viewModel.locations) { location in
                            Toggle(
                                location.name,
                                isOn: Binding(
                                    get: { viewModel.selectedLocationIds.contains(location.id) },
                                    set: { isSelected in
                                        if isSelected {
                                            viewModel.selectedLocationIds.insert(location.id)
                                        } else {
                                            viewModel.selectedLocationIds.remove(location.id)
                                        }
                                    }
                                )
                            )
                        }
                    }
                }

                // MARK: - Días disponibles
                Section(String(localized: "Días disponibles")) {
                    DaysPicker(selectedDays: $viewModel.selectedDays)
                }

                // MARK: - Campos específicos DELIVERY
                if viewModel.selectedType == .delivery {
                    Section(String(localized: "Producto")) {
                        TextField(String(localized: "Nombre del producto"), text: $viewModel.productName)

                        TextField(
                            String(localized: "Requisitos del producto..."),
                            text: $viewModel.productRequirements,
                            axis: .vertical
                        )
                        .lineLimit(2...4)

                        Stepper(
                            String(localized: "Cantidad: \(viewModel.quantityPerCreator)"),
                            value: $viewModel.quantityPerCreator,
                            in: 1...10
                        )

                        HStack {
                            Text(String(localized: "Valor"))
                            Spacer()
                            TextField("0", value: $viewModel.productValue, format: .currency(code: "EUR"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        }

                        Toggle(String(localized: "Envío mundial"), isOn: $viewModel.shipsWorldwide)
                    }
                }

                // MARK: - Campos específicos EVENT
                if viewModel.selectedType == .event {
                    Section(String(localized: "Evento")) {
                        TextField(String(localized: "Nombre del evento"), text: $viewModel.eventName)
                        TextField(String(localized: "Nombre del lugar"), text: $viewModel.venueName)
                        TextField(String(localized: "Dirección"), text: $viewModel.venueAddress)

                        DatePicker(
                            String(localized: "Fecha"),
                            selection: $viewModel.eventDate,
                            displayedComponents: .date
                        )

                        DatePicker(
                            String(localized: "Hora inicio"),
                            selection: $viewModel.eventStartTime,
                            displayedComponents: .hourAndMinute
                        )

                        DatePicker(
                            String(localized: "Hora fin"),
                            selection: $viewModel.eventEndTime,
                            displayedComponents: .hourAndMinute
                        )
                    }

                    Section(String(localized: "Detalles adicionales")) {
                        TextField(String(localized: "Código de vestimenta"), text: $viewModel.dressCode)
                        TextField(String(localized: "Hashtags (separados por espacio)"), text: $viewModel.hashtags)
                    }
                }

                // MARK: - Privacidad
                Section {
                    Toggle(
                        String(localized: "Solo por invitación"),
                        isOn: $viewModel.isPrivate
                    )
                } footer: {
                    Text(String(localized: "Si está activado, solo los foodies que invites podrán ver esta colaboración."))
                }
            }
            .navigationTitle(String(localized: "Nueva colaboración"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Crear")) {
                        Task {
                            if await viewModel.createCollaboration() {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(.ultraThinMaterial)
                }
            }
            .alert(String(localized: "Error"), isPresented: .constant(viewModel.error != nil)) {
                Button(String(localized: "OK")) {
                    viewModel.error = nil
                }
            } message: {
                Text(viewModel.error ?? "")
            }
            .task {
                await viewModel.loadRestaurantData()
            }
        }
    }
}

// MARK: - Componente auxiliar: Selector de días

struct DaysPicker: View {
    @Binding var selectedDays: Set<String>

    let days = [
        ("monday", "L"),
        ("tuesday", "M"),
        ("wednesday", "X"),
        ("thursday", "J"),
        ("friday", "V"),
        ("saturday", "S"),
        ("sunday", "D")
    ]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(days, id: \.0) { day, letter in
                Button {
                    if selectedDays.contains(day) {
                        selectedDays.remove(day)
                    } else {
                        selectedDays.insert(day)
                    }
                } label: {
                    Text(letter)
                        .font(.caption.bold())
                        .frame(width: 36, height: 36)
                        .background(selectedDays.contains(day) ? Color.primary : Color(.systemGray5))
                        .foregroundColor(selectedDays.contains(day) ? .white : .primary)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity)
    }
}
```

### 14.6 Vista: Gestionar Aplicaciones

```swift
// Features/Collaborations/Views/ManageApplicationsView.swift

struct ManageApplicationsView: View {
    @StateObject private var viewModel = ManageApplicationsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.applications.isEmpty {
                    ProgressView()
                } else if viewModel.applications.isEmpty {
                    EmptyStateView(
                        icon: "person.2.slash",
                        title: String(localized: "Sin solicitudes"),
                        message: String(localized: "Aún no tienes solicitudes de foodies.")
                    )
                } else {
                    List {
                        ForEach(viewModel.applications) { application in
                            ApplicationRow(
                                application: application,
                                onAccept: {
                                    Task { await viewModel.acceptApplication(application.id) }
                                },
                                onReject: {
                                    Task { await viewModel.rejectApplication(application.id) }
                                },
                                onComplete: {
                                    Task { await viewModel.completeApplication(application.id) }
                                }
                            )
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Solicitudes"))
            .refreshable {
                await viewModel.loadApplications()
            }
            .task {
                await viewModel.loadApplications()
            }
        }
    }
}

struct ApplicationRow: View {
    let application: Collaboration
    let onAccept: () -> Void
    let onReject: () -> Void
    let onComplete: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header con foodie info
            HStack {
                AsyncImage(url: URL(string: application.foodie?.profilePicture ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color(.systemGray4))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text("@\(application.foodie?.user?.igUsername ?? "foodie")")
                        .font(.headline)
                    Text("\(application.foodie?.followers ?? 0) seguidores")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                StatusBadge(status: application.status)
            }

            // Mensaje
            if let message = application.message, !message.isEmpty {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            // Info adicional
            HStack {
                Label("\(application.numberOfPeople)", systemImage: "person.2")
                Spacer()
                if let date = application.scheduledDate {
                    Label(date.formatted(date: .abbreviated, time: .shortened), systemImage: "calendar")
                }
            }
            .font(.caption)
            .foregroundColor(.secondary)

            // Acciones según estado
            switch application.status {
            case .pending:
                HStack(spacing: 12) {
                    Button(action: onReject) {
                        Text(String(localized: "Rechazar"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)

                    Button(action: onAccept) {
                        Text(String(localized: "Aceptar"))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }

            case .accepted:
                Button(action: onComplete) {
                    Text(String(localized: "Marcar completada"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)

            default:
                EmptyView()
            }
        }
        .padding(.vertical, 8)
    }
}

struct StatusBadge: View {
    let status: CollaborationStatus

    var body: some View {
        Text(status.displayName)
            .font(.caption2.bold())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(status.color.opacity(0.2))
            .foregroundColor(status.color)
            .clipShape(Capsule())
    }
}

extension CollaborationStatus {
    var displayName: String {
        switch self {
        case .pending: return String(localized: "Pendiente")
        case .accepted: return String(localized: "Aceptada")
        case .rejected: return String(localized: "Rechazada")
        case .completed: return String(localized: "Completada")
        case .cancelled: return String(localized: "Cancelada")
        }
    }

    var color: Color {
        switch self {
        case .pending: return .orange
        case .accepted: return .blue
        case .rejected: return .red
        case .completed: return .green
        case .cancelled: return .gray
        }
    }
}
```

### 14.7 Vista: Lista de Mis Colaboraciones (Restaurant)

```swift
// Features/Collaborations/Views/MyPublicCollaborationsView.swift

struct MyPublicCollaborationsView: View {
    @StateObject private var viewModel = MyCollaborationsViewModel()
    @State private var showCreateSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.isLoading && viewModel.collaborations.isEmpty {
                    ProgressView()
                } else if viewModel.collaborations.isEmpty {
                    VStack(spacing: 16) {
                        EmptyStateView(
                            icon: "star.slash",
                            title: String(localized: "Sin colaboraciones"),
                            message: String(localized: "Crea tu primera colaboración para empezar a recibir solicitudes de foodies.")
                        )

                        Button {
                            showCreateSheet = true
                        } label: {
                            Label(String(localized: "Crear colaboración"), systemImage: "plus")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                } else {
                    List {
                        ForEach(viewModel.collaborations) { collab in
                            NavigationLink(value: collab) {
                                CollaborationRow(collaboration: collab)
                            }
                            .swipeActions(edge: .trailing) {
                                if collab.status == "OPEN" {
                                    Button {
                                        Task {
                                            await viewModel.pauseCollaboration(collab.id)
                                        }
                                    } label: {
                                        Label(String(localized: "Pausar"), systemImage: "pause")
                                    }
                                    .tint(.orange)
                                } else if collab.status == "PAUSED" {
                                    Button {
                                        Task {
                                            await viewModel.openCollaboration(collab.id)
                                        }
                                    } label: {
                                        Label(String(localized: "Abrir"), systemImage: "play")
                                    }
                                    .tint(.green)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "Mis colaboraciones"))
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateCollaborationView()
            }
            .refreshable {
                await viewModel.loadCollaborations()
            }
            .navigationDestination(for: PublicCollaboration.self) { collab in
                CollaborationDetailView(collaboration: collab)
            }
            .task {
                await viewModel.loadCollaborations()
            }
        }
    }
}

struct CollaborationRow: View {
    let collaboration: PublicCollaboration

    var body: some View {
        HStack(spacing: 12) {
            // Imagen
            AsyncImage(url: URL(string: collaboration.image ?? "")) { image in
                image.resizable().scaledToFill()
            } placeholder: {
                Rectangle().fill(Color(.systemGray5))
            }
            .frame(width: 60, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 4) {
                // Tipo y estado
                HStack {
                    Label(collaboration.type.displayName, systemImage: collaboration.type.icon)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text(collaboration.status)
                        .font(.caption2.bold())
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(statusColor(collaboration.status).opacity(0.2))
                        .foregroundColor(statusColor(collaboration.status))
                        .clipShape(Capsule())
                }

                // Requisitos
                if let requirements = collaboration.requirements {
                    Text(requirements)
                        .font(.subheadline)
                        .lineLimit(2)
                }

                // Stats
                HStack {
                    Label("\(collaboration.minFollowers)+", systemImage: "person.2")
                    Spacer()
                    Label("\(collaboration.applications?.count ?? 0)", systemImage: "envelope")
                }
                .font(.caption)
                .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    private func statusColor(_ status: String) -> Color {
        switch status {
        case "OPEN": return .green
        case "PAUSED": return .orange
        case "CLOSED": return .red
        default: return .gray
        }
    }
}
```

### 14.8 Localizaciones adicionales

```
// es.lproj/Localizable.strings (añadir)

// Crear colaboración
"createCollab.title" = "Nueva colaboración";
"createCollab.type" = "Tipo de colaboración";
"createCollab.type.visit" = "Visita";
"createCollab.type.delivery" = "Delivery";
"createCollab.type.event" = "Evento";
"createCollab.requirements" = "Requisitos";
"createCollab.minFollowers" = "Mínimo %d seguidores";
"createCollab.maxCompanions" = "Máximo %d acompañantes";
"createCollab.compensation" = "Compensación";
"createCollab.mode.exchange" = "Intercambio";
"createCollab.mode.credit" = "Crédito";
"createCollab.mode.discount" = "Descuento";
"createCollab.mode.payment" = "Pago";
"createCollab.value" = "Valor: %d%%";
"createCollab.allowProposal" = "Permitir propuesta de tarifa";
"createCollab.locations" = "Ubicaciones";
"createCollab.days" = "Días disponibles";
"createCollab.private" = "Solo por invitación";
"createCollab.privateHint" = "Si está activado, solo los foodies que invites podrán ver esta colaboración.";
"createCollab.product" = "Producto";
"createCollab.productName" = "Nombre del producto";
"createCollab.productValue" = "Valor";
"createCollab.quantity" = "Cantidad: %d";
"createCollab.shipsWorldwide" = "Envío mundial";
"createCollab.event" = "Evento";
"createCollab.eventName" = "Nombre del evento";
"createCollab.venueName" = "Nombre del lugar";
"createCollab.venueAddress" = "Dirección";
"createCollab.eventDate" = "Fecha";
"createCollab.startTime" = "Hora inicio";
"createCollab.endTime" = "Hora fin";
"createCollab.dressCode" = "Código de vestimenta";
"createCollab.hashtags" = "Hashtags";
"createCollab.create" = "Crear";
"createCollab.cancel" = "Cancelar";

// Gestión de solicitudes
"applications.title" = "Solicitudes";
"applications.empty" = "Sin solicitudes";
"applications.emptyMessage" = "Aún no tienes solicitudes de foodies.";
"applications.accept" = "Aceptar";
"applications.reject" = "Rechazar";
"applications.complete" = "Marcar completada";
"applications.followers" = "%d seguidores";

// Estados
"status.pending" = "Pendiente";
"status.accepted" = "Aceptada";
"status.rejected" = "Rechazada";
"status.completed" = "Completada";
"status.cancelled" = "Cancelada";
"status.open" = "Abierta";
"status.paused" = "Pausada";
"status.closed" = "Cerrada";

// Mis colaboraciones
"myCollabs.title" = "Mis colaboraciones";
"myCollabs.empty" = "Sin colaboraciones";
"myCollabs.emptyMessage" = "Crea tu primera colaboración para empezar a recibir solicitudes de foodies.";
"myCollabs.create" = "Crear colaboración";
"myCollabs.pause" = "Pausar";
"myCollabs.open" = "Abrir";
```

---

## 15. DOCUMENTACIÓN COMPLETA DE ENDPOINTS API

### 15.1 Autenticación (`/api/auth/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| POST | `/register/foodie` | Registrar foodie | `{ email, password, name, igUsername, phone?, address? }` |
| POST | `/register/restaurant` | Registrar restaurant | `{ email, password, name, contactName, cif, billingAddress }` |
| POST | `/login` | Login | `{ email, password }` |
| GET | `/me` | Usuario actual | - |
| PUT | `/pending` | Actualizar email/ig pendiente | `{ email?, igUsername? }` |
| POST | `/resend-code` | Reenviar código verificación | - |
| POST | `/verify` | Verificar email | `{ code }` |
| POST | `/forgot-password` | Solicitar reset | `{ email }` |
| POST | `/reset-password` | Reset contraseña | `{ email, code, newPassword }` |

### 15.2 Usuarios (`/api/users/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| GET | `/me/profile` | Perfil completo | - |
| PUT | `/me` | Actualizar info básica | `{ name, phone }` |
| PUT | `/me/password` | Cambiar contraseña | `{ currentPassword, newPassword }` |
| DELETE | `/me` | Eliminar cuenta | - |
| POST | `/me/email` | Solicitar cambio email | `{ newEmail }` |
| POST | `/me/email/verify` | Verificar cambio email | `{ code }` |
| DELETE | `/me/email` | Cancelar cambio email | - |

### 15.3 Foodies (`/api/foodies/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| GET | `/` | Listar foodies | Query: `page, limit, province` |
| GET | `/provinces` | Provincias únicas | - |
| GET | `/pending-ratings` | Count ratings pendientes | - |
| GET | `/pending-ratings/list` | Lista ratings pendientes | - |
| GET | `/username/:username` | Perfil por username | - |
| GET | `/:id` | Perfil por ID | - |
| PUT | `/me/profile` | Actualizar perfil | `{ bio, followers, profilePicture }` |
| PUT | `/me/address` | Actualizar dirección | `{ line, city, state, zipCode, country }` |
| POST | `/me/trips` | Crear viaje | `{ destination, startDate, endDate, description }` |
| GET | `/me/trips` | Listar viajes | - |
| PUT | `/me/trips/:id` | Actualizar viaje | `{ destination, startDate, endDate }` |
| DELETE | `/me/trips/:id` | Eliminar viaje | - |
| GET | `/me/rates` | Listar tarifas | - |
| POST | `/me/rates` | Crear tarifa | `{ platform, priceMin, priceMax, description }` |
| PUT | `/me/rates/:id` | Actualizar tarifa | `{ platform, priceMin, priceMax }` |
| DELETE | `/me/rates/:id` | Eliminar tarifa | - |
| GET | `/me/social-networks` | Listar redes sociales | - |
| POST | `/me/social-networks` | Añadir/actualizar red | `{ platform, username, followers }` |
| DELETE | `/me/social-networks/:platform` | Eliminar red social | - |

### 15.4 Restaurantes (`/api/restaurants/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| GET | `/` | Listar restaurantes | Query: `page, limit, city` |
| GET | `/my` | **MIS RESTAURANTES (multi)** | - |
| GET | `/pending-ratings` | Count ratings pendientes | - |
| GET | `/pending-ratings/list` | Lista ratings pendientes | - |
| POST | `/` | **CREAR RESTAURANTE ADICIONAL** | `{ name, contactName, cif, address }` |
| PUT | `/:restaurantId/active` | **CAMBIAR RESTAURANTE ACTIVO** | - |
| PATCH | `/:restaurantId/status` | Pausar/activar restaurant | `{ status: "ACTIVE" \| "PAUSED" }` |
| GET | `/:id` | Perfil público | - |
| PUT | `/me/profile` | Actualizar perfil | `{ restaurantName, contactName, bio }` |
| PUT | `/me/address` | Actualizar dirección | `{ line, city, state, zipCode, country }` |
| PUT | `/me/billing` | Actualizar facturación | `{ businessName, cif, addressLine }` |
| PATCH | `/me/billing/cif` | Solo CIF | `{ cif }` |
| GET | `/:restaurantId/locations` | Listar ubicaciones | - |
| POST | `/:restaurantId/locations` | Añadir ubicación | `{ name, line, city, state, zipCode }` |
| PUT | `/:restaurantId/locations/:locationId` | Actualizar ubicación | `{ name, line, city }` |
| DELETE | `/:restaurantId/locations/:locationId` | Eliminar ubicación | - |

### 15.5 Suscripciones (`/api/subscriptions/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| GET | `/plans` | **LISTAR PLANES** | - |
| GET | `/trial-days` | Días de trial por provincia | - |
| GET | `/current` | **SUSCRIPCIÓN ACTUAL** | - |
| POST | `/` | Crear/cambiar suscripción | `{ planId }` |
| POST | `/checkout` | **CREAR CHECKOUT STRIPE** | `{ planId }` |
| GET | `/checkout/success` | Verificar checkout | Query: `session_id` |
| POST | `/billing-portal` | Portal de facturación | - |

**Planes disponibles:**
```swift
struct SubscriptionPlan: Codable {
    let id: String
    let name: String                    // "Individual", "Multi 4", "Multi 9", "Ilimitado"
    let maxRestaurants: Int?            // 1, 4, 9, nil (ilimitado)
    let monthlyPrice: Double            // 29, 79, 139, 199
    let quarterlyPrice: Double          // 69, 189, 339, 479
    let yearlyPrice: Double             // 249, 699, 1249, 1899
    let features: [String]
}
```

### 15.6 Colaboraciones Públicas (`/api/collaborations/public/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| GET | `/` | Listar públicas | Query: `page, limit, restaurantId, type, city` |
| GET | `/my` | Mis colaboraciones (restaurant) | - |
| GET | `/shipping-zones` | Zonas de envío guardadas | - |
| POST | `/shipping-zones` | Guardar zona | `{ name, zones[] }` |
| DELETE | `/shipping-zones/:id` | Eliminar zona | - |
| GET | `/:id` | Detalle colaboración | - |
| POST | `/` | **CREAR COLABORACIÓN** | Ver sección 14.2 |
| PUT | `/:id` | Actualizar | `{ requirements, minFollowers, ... }` |
| PATCH | `/:id/status` | Cambiar estado | `{ status: "OPEN" \| "PAUSED" \| "CLOSED" }` |
| DELETE | `/:id` | Eliminar | - |
| POST | `/:id/cancel` | Cancelar | `{ reason? }` |
| POST | `/:id/invite` | Invitar foodie | `{ foodieId }` |
| GET | `/:id/export-csv` | Exportar delivery CSV | - |

### 15.7 Colaboraciones/Aplicaciones (`/api/collaborations/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| POST | `/` | **APLICAR (foodie)** | `{ publicCollaborationId, message, numberOfPeople, specialRequirements }` |
| GET | `/me` | Mis aplicaciones | Query: `status, role` |
| GET | `/delivery/defaults` | Info entrega default | - |
| GET | `/:id` | Detalle aplicación | - |
| PATCH | `/:id/status` | Cambiar estado (restaurant) | `{ status: "ACCEPTED" \| "REJECTED" \| "COMPLETED" }` |
| PUT | `/:id` | Actualizar | `{ scheduledDate, notes }` |
| POST | `/:id/respond` | Responder invitación | `{ response: "accept" \| "reject" }` |
| POST | `/:id/schedule` | Agendar visita (foodie) | `{ scheduledDate, selectedLocationId }` |
| POST | `/:id/content-link` | Añadir link contenido | `{ url }` |
| DELETE | `/:id/content-link` | Eliminar link | `{ url }` |
| DELETE | `/:id` | Cancelar aplicación | - |
| POST | `/:collaborationId/delivery-info` | Confirmar delivery | `{ address, phone, availableDays }` |
| GET | `/:id/receipt` | Obtener recibo | - |
| GET | `/:id/payment-status` | Estado pago 3DS | - |
| POST | `/:id/refund` | Reembolsar | `{ reason }` |
| POST | `/:id/pay` | Pagar colaboración | - |

### 15.8 Chat (`/api/chat/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| GET | `/conversations` | Listar conversaciones | - |
| POST | `/conversations` | Crear/obtener conversación | `{ otherUserId }` |
| POST | `/conversations/from-collaboration` | Iniciar desde colab | `{ collaborationId, initialMessage? }` |
| GET | `/conversations/:id/messages` | Listar mensajes | Query: `limit, offset` |
| POST | `/conversations/:id/messages` | Enviar mensaje | `{ content }` |
| PUT | `/conversations/:id/read` | Marcar leído | - |
| GET | `/unread` | Count no leídos | - |
| DELETE | `/conversations/:id` | Ocultar conversación | - |
| POST | `/bulk-message` | Mensaje masivo (restaurant) | `{ publicCollaborationId, message, statuses[] }` |

### 15.9 Valoraciones (`/api/ratings/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| POST | `/` | Crear valoración | `{ collaborationId, ratedId, score, comment, punctuality, professionalism, contentQuality, communication, overall }` |
| GET | `/collaboration/:id` | Ratings de colaboración | - |
| GET | `/my-given` | Ratings que he dado | - |
| GET | `/user/:userId` | Ratings recibidos + stats | - |
| PUT | `/:id` | Actualizar (7 días) | `{ score, comment }` |
| DELETE | `/:id` | Eliminar (7 días) | - |

### 15.10 Balance/Retiros (`/api/balance/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| GET | `/` | Mi balance | - |
| POST | `/withdraw` | Solicitar retiro | `{ amount, bankAccount }` |

### 15.11 Referidos (`/api/referrals/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| POST | `/generate` | Generar código único | - |
| GET | `/me` | Mi info de referidos | - |
| GET | `/validate/:code` | Validar código | - |

### 15.12 Uploads (`/api/upload/`)

| Método | Endpoint | Descripción | Body |
|--------|----------|-------------|------|
| POST | `/image` | Subir imagen | FormData: `image` |
| POST | `/invoice` | Subir factura PDF | FormData: `invoice` |

---

## 16. FLUJO MULTI-RESTAURANTE

### 16.1 Modelo de Datos

Un usuario `RESTAURANT` puede tener múltiples `RestaurantProfile`:
- Cada perfil tiene sus propias ubicaciones, colaboraciones, ratings
- Solo UN restaurante puede estar "activo" a la vez
- El plan de suscripción limita cuántos restaurantes puede tener

```swift
// El usuario tiene array de restaurants
struct User {
    // ...
    var restaurants: [RestaurantProfile]?
    var activeRestaurantId: String?  // Cuál está seleccionado
}
```

### 16.2 Servicio Multi-Restaurante

```swift
// Core/Services/RestaurantService.swift

extension RestaurantService {

    // Obtener todos mis restaurantes
    func getMyRestaurants() async throws -> [RestaurantProfile] {
        return try await api.get(.myRestaurants)
    }

    // Cambiar restaurante activo
    func setActiveRestaurant(restaurantId: String) async throws {
        let _: EmptyResponse = try await api.put(.setActiveRestaurant(restaurantId: restaurantId), body: EmptyBody())
    }

    // Crear restaurante adicional (requiere plan Multi)
    func createRestaurant(_ request: CreateRestaurantRequest) async throws -> RestaurantProfile {
        return try await api.post(.createRestaurant, body: request)
    }

    // Pausar/activar restaurante
    func updateRestaurantStatus(restaurantId: String, status: RestaurantStatus) async throws -> RestaurantProfile {
        let body = ["status": status.rawValue]
        return try await api.patch(.updateRestaurantStatus(restaurantId: restaurantId), body: body)
    }
}

struct CreateRestaurantRequest: Encodable {
    let name: String
    let contactName: String
    let cif: String?
    let phone: String?
    let address: Address
    let billingAddress: BillingAddress?
}
```

### 16.3 ViewModel Multi-Restaurante

```swift
// Features/Restaurants/ViewModels/RestaurantSelectorViewModel.swift

@MainActor
final class RestaurantSelectorViewModel: ObservableObject {
    @Published var restaurants: [RestaurantProfile] = []
    @Published var activeRestaurant: RestaurantProfile?
    @Published var isLoading = false
    @Published var error: String?
    @Published var canAddMore = false  // Basado en plan de suscripción

    private let restaurantService = RestaurantService.shared
    private let subscriptionService = SubscriptionService.shared

    func loadRestaurants() async {
        isLoading = true
        do {
            restaurants = try await restaurantService.getMyRestaurants()
            activeRestaurant = restaurants.first { $0.status == .active }

            // Verificar si puede añadir más según plan
            if let subscription = try? await subscriptionService.getCurrentSubscription() {
                let maxAllowed = subscription.plan?.maxRestaurants ?? 1
                canAddMore = restaurants.count < maxAllowed || maxAllowed == 0 // 0 = ilimitado
            }
        } catch {
            self.error = "Error cargando restaurantes"
        }
        isLoading = false
    }

    func switchRestaurant(_ restaurant: RestaurantProfile) async -> Bool {
        isLoading = true
        do {
            try await restaurantService.setActiveRestaurant(restaurantId: restaurant.id)
            activeRestaurant = restaurant
            isLoading = false
            return true
        } catch {
            self.error = "Error cambiando restaurante"
            isLoading = false
            return false
        }
    }
}
```

### 16.4 Vista: Selector de Restaurante

```swift
// Features/Restaurants/Views/RestaurantSelectorView.swift

struct RestaurantSelectorView: View {
    @StateObject private var viewModel = RestaurantSelectorViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showAddRestaurant = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.restaurants) { restaurant in
                    RestaurantRow(
                        restaurant: restaurant,
                        isActive: restaurant.id == viewModel.activeRestaurant?.id,
                        onSelect: {
                            Task {
                                if await viewModel.switchRestaurant(restaurant) {
                                    dismiss()
                                }
                            }
                        }
                    )
                }

                if viewModel.canAddMore {
                    Button {
                        showAddRestaurant = true
                    } label: {
                        Label(String(localized: "Añadir restaurante"), systemImage: "plus.circle")
                    }
                }
            }
            .navigationTitle(String(localized: "Mis restaurantes"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cerrar")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showAddRestaurant) {
                AddRestaurantView()
            }
            .task {
                await viewModel.loadRestaurants()
            }
        }
    }
}

struct RestaurantRow: View {
    let restaurant: RestaurantProfile
    let isActive: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                AsyncImage(url: URL(string: restaurant.profilePicture ?? "")) { image in
                    image.resizable().scaledToFill()
                } placeholder: {
                    Circle().fill(Color(.systemGray4))
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(restaurant.restaurantName)
                        .font(.headline)
                    Text(restaurant.address?.city ?? "")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isActive {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }

                if restaurant.status == .paused {
                    Text(String(localized: "Pausado"))
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.orange.opacity(0.2))
                        .foregroundColor(.orange)
                        .clipShape(Capsule())
                }
            }
        }
        .buttonStyle(.plain)
    }
}
```

---

## 17. SUSCRIPCIONES CON APPLE PAY / IN-APP PURCHASE

### 17.1 Consideraciones Apple

**Opción A: Stripe + WebView (Recomendado inicialmente)**
- Redirigir a web para checkout
- Evita comisión del 30% de Apple
- Más rápido de implementar

**Opción B: StoreKit 2 (In-App Purchase)**
- Requiere configurar productos en App Store Connect
- Apple toma 30% (15% para pequeños negocios)
- Mejor UX nativa

### 17.2 Implementación con Stripe (WebView)

```swift
// Core/Services/SubscriptionService.swift

final class SubscriptionService {
    static let shared = SubscriptionService()
    private let api = APIClient.shared

    // Obtener planes disponibles
    func getPlans() async throws -> [SubscriptionPlan] {
        return try await api.get(.subscriptionPlans)
    }

    // Obtener suscripción actual
    func getCurrentSubscription() async throws -> Subscription? {
        return try await api.get(.currentSubscription)
    }

    // Crear sesión de checkout (retorna URL)
    func createCheckoutSession(planId: String, billingPeriod: BillingPeriod) async throws -> String {
        struct CheckoutRequest: Encodable {
            let planId: String
            let billingPeriod: String
        }
        struct CheckoutResponse: Decodable {
            let checkoutSessionUrl: String
        }

        let request = CheckoutRequest(planId: planId, billingPeriod: billingPeriod.rawValue)
        let response: CheckoutResponse = try await api.post(.subscriptionCheckout, body: request)
        return response.checkoutSessionUrl
    }

    // Verificar checkout exitoso
    func verifyCheckoutSuccess(sessionId: String) async throws -> Subscription {
        struct VerifyResponse: Decodable {
            let subscription: Subscription
        }
        // Añadir session_id como query parameter
        let response: VerifyResponse = try await api.get(.checkoutSuccess(sessionId: sessionId))
        return response.subscription
    }

    // Abrir portal de facturación
    func getBillingPortalUrl() async throws -> String {
        struct PortalResponse: Decodable {
            let billingPortalUrl: String
        }
        let response: PortalResponse = try await api.post(.billingPortal, body: EmptyBody())
        return response.billingPortalUrl
    }
}

enum BillingPeriod: String, Codable, CaseIterable {
    case monthly = "MONTHLY"
    case quarterly = "QUARTERLY"
    case yearly = "YEARLY"

    var displayName: String {
        switch self {
        case .monthly: return String(localized: "Mensual")
        case .quarterly: return String(localized: "Trimestral")
        case .yearly: return String(localized: "Anual")
        }
    }

    var discount: String? {
        switch self {
        case .monthly: return nil
        case .quarterly: return "-20%"
        case .yearly: return "-30%"
        }
    }
}
```

### 17.3 Vista: Planes de Suscripción

```swift
// Features/Subscription/Views/SubscriptionPlansView.swift

struct SubscriptionPlansView: View {
    @StateObject private var viewModel = SubscriptionViewModel()
    @State private var selectedPlan: SubscriptionPlan?
    @State private var selectedPeriod: BillingPeriod = .monthly
    @State private var showCheckout = false
    @State private var checkoutUrl: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Selector de período
                    Picker(String(localized: "Período"), selection: $selectedPeriod) {
                        ForEach(BillingPeriod.allCases, id: \.self) { period in
                            HStack {
                                Text(period.displayName)
                                if let discount = period.discount {
                                    Text(discount)
                                        .foregroundColor(.green)
                                }
                            }
                            .tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Lista de planes
                    ForEach(viewModel.plans) { plan in
                        PlanCard(
                            plan: plan,
                            period: selectedPeriod,
                            isSelected: selectedPlan?.id == plan.id,
                            isCurrent: viewModel.currentSubscription?.planId == plan.id,
                            onSelect: { selectedPlan = plan }
                        )
                    }

                    // Botón de suscribirse
                    if let plan = selectedPlan {
                        Button {
                            Task {
                                if let url = await viewModel.startCheckout(planId: plan.id, period: selectedPeriod) {
                                    checkoutUrl = url
                                    showCheckout = true
                                }
                            }
                        } label: {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(String(localized: "Suscribirse a \(plan.name)"))
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("Primary"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .padding(.horizontal)
                        .disabled(viewModel.isLoading)
                    }

                    // Enlace a gestionar suscripción existente
                    if viewModel.currentSubscription != nil {
                        Button(String(localized: "Gestionar mi suscripción")) {
                            Task {
                                if let url = await viewModel.getBillingPortalUrl() {
                                    checkoutUrl = url
                                    showCheckout = true
                                }
                            }
                        }
                        .foregroundColor(Color("Primary"))
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle(String(localized: "Planes"))
            .sheet(isPresented: $showCheckout) {
                if let url = checkoutUrl {
                    SafariView(url: URL(string: url)!)
                }
            }
            .task {
                await viewModel.loadPlans()
                await viewModel.loadCurrentSubscription()
            }
        }
    }
}

struct PlanCard: View {
    let plan: SubscriptionPlan
    let period: BillingPeriod
    let isSelected: Bool
    let isCurrent: Bool
    let onSelect: () -> Void

    var price: Double {
        switch period {
        case .monthly: return plan.monthlyPrice
        case .quarterly: return plan.quarterlyPrice
        case .yearly: return plan.yearlyPrice
        }
    }

    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(plan.name)
                        .font(.title2.bold())

                    Spacer()

                    if isCurrent {
                        Text(String(localized: "Actual"))
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .clipShape(Capsule())
                    }
                }

                if let maxRestaurants = plan.maxRestaurants {
                    Text(String(localized: "\(maxRestaurants) restaurante(s)"))
                        .foregroundColor(.secondary)
                } else {
                    Text(String(localized: "Restaurantes ilimitados"))
                        .foregroundColor(.secondary)
                }

                HStack(alignment: .bottom) {
                    Text("€\(price, specifier: "%.0f")")
                        .font(.title.bold())
                    Text("/\(period.displayName.lowercased())")
                        .foregroundColor(.secondary)
                }

                // Features
                ForEach(plan.features, id: \.self) { feature in
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text(feature)
                            .font(.subheadline)
                    }
                }
            }
            .padding()
            .background(isSelected ? Color("Primary").opacity(0.1) : Color(.systemGray6))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color("Primary") : Color.clear, lineWidth: 2)
            )
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
        .padding(.horizontal)
    }
}

// Safari WebView para checkout
import SafariServices
import SwiftUI

struct SafariView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
```

### 17.4 Localizaciones Suscripción

```
// es.lproj/Localizable.strings (añadir)

// Suscripciones
"subscription.title" = "Planes";
"subscription.period" = "Período";
"subscription.monthly" = "Mensual";
"subscription.quarterly" = "Trimestral";
"subscription.yearly" = "Anual";
"subscription.current" = "Actual";
"subscription.subscribe" = "Suscribirse a %@";
"subscription.manage" = "Gestionar mi suscripción";
"subscription.restaurants" = "%d restaurante(s)";
"subscription.unlimited" = "Restaurantes ilimitados";

// Planes
"plan.individual" = "Individual";
"plan.multi4" = "Multi 4";
"plan.multi9" = "Multi 9";
"plan.unlimited" = "Ilimitado";
```

---

## 18. RECURSOS Y REFERENCIAS

### Documentación
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [URLSession](https://developer.apple.com/documentation/foundation/urlsession)
- [Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [StoreKit 2](https://developer.apple.com/documentation/storekit)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Librerías Recomendadas (opcionales)
- **Kingfisher** - Carga/cache de imágenes
- **SwiftLint** - Code style
- **KeychainAccess** - Wrapper para Keychain

### Backend API
- Base URL Producción: `https://api.solofoodies.com/api`
- Autenticación: Bearer JWT en header
- Formato: JSON
- Timeout recomendado: 30 segundos

---

## 19. NOTAS IMPORTANTES

1. **NO incluir en app iOS:**
   - Panel Admin
   - Gestión de suscripciones (redirect a web)
   - Landing page

2. **Priorizar:**
   - Performance nativa
   - UX fluida
   - Offline graceful degradation

3. **Seguridad:**
   - Nunca almacenar tokens en UserDefaults
   - Usar Keychain exclusivamente
   - Validar SSL certificates

4. **App Store:**
   - Necesitas Apple Developer Account ($99/año)
   - Review puede tomar 1-7 días
   - Tener política de privacidad lista
