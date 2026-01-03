//
//  ProfileViewModel.swift
//  Solofoodies
//

import Foundation
import Combine

@MainActor
final class ProfileViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var ratings: [ProfileRating] = []
    @Published var ratingStats: RatingStats = RatingStats(totalRatings: 0, averageScore: nil)
    @Published var balance: Double = 0
    @Published var pendingRatingsCount: Int = 0

    @Published var isLoading = false
    @Published var error: String?

    private let profileService = ProfileService.shared

    // MARK: - Load Profile Data

    func loadProfileData(for userId: String) async {
        guard !isLoading else { return }
        isLoading = true
        error = nil

        do {
            // Load ratings
            let ratingsResponse = try await profileService.getUserRatings(userId: userId)
            ratings = ratingsResponse.ratings
            ratingStats = ratingsResponse.statistics

            // Load balance
            do {
                let balanceInfo = try await profileService.getBalance()
                balance = balanceInfo.balance + balanceInfo.pendingBalance
            } catch {
                // Balance might not be available for all users
            }

            // Load pending ratings count
            do {
                pendingRatingsCount = try await profileService.getPendingRatingsCount()
            } catch {
                // Silent fail
            }
        } catch let apiError as APIError {
            self.error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error cargando perfil")
        }

        isLoading = false
    }

    // MARK: - Helpers

    func formatFollowers(_ count: Int) -> String {
        if count >= 1_000_000 {
            return String(format: "%.1fM", Double(count) / 1_000_000)
        }
        if count >= 1000 {
            return String(format: "%.1fk", Double(count) / 1000)
        }
        return "\(count)"
    }

    func formatTimeAgo(_ date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)
        let days = Int(diff / 86400)
        let months = days / 30
        let years = days / 365

        if years > 0 {
            return String(localized: "hace \(years) año\(years > 1 ? "s" : "")")
        }
        if months > 0 {
            return String(localized: "hace \(months) mes\(months > 1 ? "es" : "")")
        }
        if days > 0 {
            return String(localized: "hace \(days) día\(days > 1 ? "s" : "")")
        }
        return String(localized: "Hoy")
    }

    func clearError() {
        error = nil
    }
}
