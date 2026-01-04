//
//  AuthViewModel.swift
//  Solofoodies
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class AuthViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var error: String?
    @Published var isAuthenticated = false
    @Published var needsEmailVerification = false
    @Published var requiresSubscription = false

    // Multi-restaurant support
    @Published var activeRestaurantId: String?
    @Published var restaurants: [RestaurantProfile] = []

    private let authService = AuthService.shared

    // MARK: - Init

    init() {
        isAuthenticated = KeychainManager.shared.isAuthenticated
        if isAuthenticated {
            Task { await loadCurrentUser() }
        }
    }

    // MARK: - Login

    func login(email: String, password: String) async {
        isLoading = true
        error = nil

        do {
            currentUser = try await authService.login(email: email, password: password)
            isAuthenticated = true
            updateRestaurantState()

            // Check if email needs verification
            if currentUser?.emailVerified == false {
                needsEmailVerification = true
            }
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    // MARK: - Register Foodie

    func registerFoodie(
        name: String,
        email: String,
        password: String,
        igUsername: String,
        inviteCode: String
    ) async {
        isLoading = true
        error = nil

        do {
            currentUser = try await authService.registerFoodie(
                name: name,
                email: email,
                password: password,
                igUsername: igUsername,
                inviteCode: inviteCode
            )
            isAuthenticated = true
            needsEmailVerification = true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    // MARK: - Register Restaurant

    func registerRestaurant(request: RegisterRestaurantRequest) async {
        isLoading = true
        error = nil

        do {
            let (user, needsSubscription) = try await authService.registerRestaurant(request: request)
            currentUser = user
            isAuthenticated = true
            needsEmailVerification = true
            requiresSubscription = needsSubscription
            updateRestaurantState()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    // MARK: - Verify Email

    func verifyEmail(code: String) async -> Bool {
        isLoading = true
        error = nil

        do {
            try await authService.verifyEmail(code: code)
            await loadCurrentUser()
            needsEmailVerification = false
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
            isLoading = false
            return false
        } catch {
            self.error = String(localized: "Error desconocido")
            isLoading = false
            return false
        }
    }

    // MARK: - Resend Code

    func resendCode() async {
        isLoading = true
        error = nil

        do {
            try await authService.resendCode()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    // MARK: - Logout

    func logout() {
        authService.logout()
        currentUser = nil
        isAuthenticated = false
        needsEmailVerification = false
        requiresSubscription = false
        activeRestaurantId = nil
        restaurants = []
    }

    // MARK: - Clear Error

    func clearError() {
        error = nil
    }

    // MARK: - Multi-Restaurant

    func setActiveRestaurant(_ restaurantId: String) {
        activeRestaurantId = restaurantId
    }

    func getActiveRestaurant() -> RestaurantProfile? {
        guard let activeId = activeRestaurantId else { return restaurants.first }
        return restaurants.first { $0.id == activeId }
    }

    func switchRestaurant(to restaurantId: String) async {
        guard restaurantId != activeRestaurantId else { return }

        isLoading = true
        error = nil

        do {
            currentUser = try await authService.switchActiveRestaurant(restaurantId: restaurantId)
            updateRestaurantState()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error al cambiar de restaurante")
        }

        isLoading = false
    }

    var hasMultipleRestaurants: Bool {
        restaurants.count > 1
    }

    // MARK: - Private

    private func loadCurrentUser() async {
        do {
            currentUser = try await authService.getCurrentUser()
            updateRestaurantState()

            if currentUser?.emailVerified == false {
                needsEmailVerification = true
            }
        } catch {
            logout()
        }
    }

    private func updateRestaurantState() {
        activeRestaurantId = currentUser?.activeRestaurantId
        restaurants = currentUser?.restaurants ?? []
    }
}
