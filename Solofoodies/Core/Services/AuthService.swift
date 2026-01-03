//
//  AuthService.swift
//  Solofoodies
//

import Foundation

final class AuthService {
    static let shared = AuthService()
    private let api = APIClient.shared

    private init() {}

    // MARK: - Login

    func login(email: String, password: String) async throws -> User {
        let request = LoginRequest(email: email, password: password)
        let response: AuthResponse = try await api.post(.login, body: request)

        KeychainManager.shared.saveToken(response.token)
        return response.user
    }

    // MARK: - Register Foodie

    func registerFoodie(
        name: String,
        email: String,
        password: String,
        igUsername: String,
        inviteCode: String
    ) async throws -> User {
        let request = RegisterFoodieRequest(
            name: name,
            email: email,
            password: password,
            passwordConfirmation: password,
            inviteCode: inviteCode,
            igUsername: igUsername
        )
        let response: AuthResponse = try await api.post(.registerFoodie, body: request)

        KeychainManager.shared.saveToken(response.token)
        return response.user
    }

    // MARK: - Register Restaurant

    func registerRestaurant(request: RegisterRestaurantRequest) async throws -> (User, Bool) {
        let response: RegisterRestaurantResponse = try await api.post(.registerRestaurant, body: request)

        KeychainManager.shared.saveToken(response.token)
        return (response.user, response.requiresSubscription ?? false)
    }

    // MARK: - Verify Email

    func verifyEmail(code: String) async throws {
        let request = VerifyEmailRequest(code: code)
        try await api.post(.verifyEmail, body: request)
    }

    // MARK: - Resend Verification Code

    func resendCode() async throws {
        try await api.post(.resendCode, body: EmptyBody())
    }

    // MARK: - Forgot Password

    func forgotPassword(email: String) async throws {
        let request = ForgotPasswordRequest(email: email)
        try await api.post(.forgotPassword, body: request)
    }

    // MARK: - Reset Password

    func resetPassword(email: String, token: String, newPassword: String) async throws {
        let request = ResetPasswordRequest(email: email, token: token, newPassword: newPassword)
        try await api.post(.resetPassword, body: request)
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

// Empty body for requests without parameters
struct EmptyBody: Encodable {}
