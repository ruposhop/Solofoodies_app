//
//  ExploreFoodiesViewModel.swift
//  Solofoodies
//

import Foundation
import Combine

@MainActor
final class ExploreFoodiesViewModel: ObservableObject {
    // MARK: - Published Properties

    @Published var foodies: [FoodieListItem] = []
    @Published var provinces: [ProvinceWithCountry] = []
    @Published var selectedProvince: String = "todos"
    @Published var searchText: String = ""

    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: String?

    // Pagination
    @Published var hasMore = true
    private var currentOffset = 0
    private let pageSize = 20

    private let service = FoodieService.shared

    // MARK: - Load Foodies

    func loadFoodies(refresh: Bool = false) async {
        if refresh {
            currentOffset = 0
            hasMore = true
        }

        guard !isLoading else { return }

        isLoading = refresh || currentOffset == 0
        isLoadingMore = !refresh && currentOffset > 0
        error = nil

        do {
            let result = try await service.listFoodies(
                limit: pageSize,
                offset: currentOffset,
                province: selectedProvince == "todos" ? nil : selectedProvince,
                search: searchText.isEmpty ? nil : searchText
            )

            if refresh || currentOffset == 0 {
                foodies = result
            } else {
                foodies.append(contentsOf: result)
            }

            hasMore = result.count >= pageSize
            currentOffset += result.count
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        isLoadingMore = false
    }

    func loadMoreIfNeeded(currentItem: FoodieListItem) async {
        guard hasMore, !isLoadingMore else { return }

        let thresholdIndex = foodies.index(foodies.endIndex, offsetBy: -5)
        if let currentIndex = foodies.firstIndex(where: { $0.id == currentItem.id }),
           currentIndex >= thresholdIndex {
            await loadFoodies()
        }
    }

    func refresh() async {
        await loadFoodies(refresh: true)
    }

    // MARK: - Load Provinces

    func loadProvinces() async {
        do {
            provinces = try await service.getProvinces()
        } catch {
            // Silent fail - provinces are optional
            print("Error loading provinces: \(error)")
        }
    }

    // MARK: - Filters

    func applyProvinceFilter(_ province: String) async {
        selectedProvince = province
        await loadFoodies(refresh: true)
    }

    func search() async {
        await loadFoodies(refresh: true)
    }

    func clearSearch() async {
        searchText = ""
        await loadFoodies(refresh: true)
    }

    // MARK: - Helpers

    func clearError() {
        error = nil
    }
}
