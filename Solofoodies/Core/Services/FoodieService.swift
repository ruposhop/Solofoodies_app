//
//  FoodieService.swift
//  Solofoodies
//

import Foundation

final class FoodieService {
    static let shared = FoodieService()
    private let api = APIClient.shared

    private init() {}

    // MARK: - List Foodies

    func listFoodies(
        limit: Int = 20,
        offset: Int = 0,
        province: String? = nil,
        search: String? = nil
    ) async throws -> [FoodieListItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "offset", value: String(offset))
        ]

        if let province = province, province != "todos" {
            queryItems.append(URLQueryItem(name: "province", value: province))
        }

        if let search = search, !search.isEmpty {
            queryItems.append(URLQueryItem(name: "search", value: search))
        }

        let response: FoodiesListResponse = try await api.get(.listFoodies, queryItems: queryItems)
        return response.data
    }

    // MARK: - Get Foodie Profile

    func getFoodieProfile(id: String) async throws -> FoodieProfile {
        return try await api.get(.foodieProfile(id: id))
    }

    func getFoodieByUsername(username: String) async throws -> FoodieProfile {
        return try await api.get(.foodieByUsername(username: username))
    }

    // MARK: - Get Provinces

    func getProvinces() async throws -> [ProvinceWithCountry] {
        let response: ProvincesResponse = try await api.get(.foodieProvinces)
        return response.provincesWithCountry ?? []
    }
}
