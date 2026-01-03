//
//  CollaborationsViewModel.swift
//  Solofoodies
//

import Foundation
import Combine

@MainActor
final class CollaborationsViewModel: ObservableObject {
    // MARK: - Published Properties

    // Public collaborations (for browse)
    @Published var publicCollaborations: [PublicCollaboration] = []
    @Published var selectedPublicCollaboration: PublicCollaboration?

    // My collaborations (applications)
    @Published var myCollaborations: [Collaboration] = []
    @Published var selectedCollaboration: Collaboration?

    // Restaurant's own public collaborations
    @Published var myPublicCollaborations: [PublicCollaboration] = []

    // State
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var error: String?
    @Published var successMessage: String?

    // Pagination
    @Published var hasMore = true
    private var currentOffset = 0
    private let pageSize = 20

    // Filters
    @Published var cityFilter: String?

    private let service = CollaborationService.shared

    // MARK: - Public Collaborations (Browse)

    func loadPublicCollaborations(refresh: Bool = false) async {
        if refresh {
            currentOffset = 0
            hasMore = true
        }

        guard !isLoading else { return }

        isLoading = refresh || currentOffset == 0
        isLoadingMore = !refresh && currentOffset > 0
        error = nil

        do {
            let collaborations = try await service.listPublicCollaborations(
                limit: pageSize,
                offset: currentOffset,
                city: cityFilter,
                status: "OPEN"
            )

            if refresh || currentOffset == 0 {
                publicCollaborations = collaborations
            } else {
                publicCollaborations.append(contentsOf: collaborations)
            }

            hasMore = collaborations.count >= pageSize
            currentOffset += collaborations.count
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        isLoadingMore = false
    }

    func loadMoreIfNeeded(currentItem: PublicCollaboration) async {
        guard hasMore, !isLoadingMore else { return }

        let thresholdIndex = publicCollaborations.index(publicCollaborations.endIndex, offsetBy: -5)
        if let currentIndex = publicCollaborations.firstIndex(where: { $0.id == currentItem.id }),
           currentIndex >= thresholdIndex {
            await loadPublicCollaborations()
        }
    }

    func refreshPublicCollaborations() async {
        await loadPublicCollaborations(refresh: true)
    }

    func getPublicCollaboration(id: String) async {
        isLoading = true
        error = nil

        do {
            selectedPublicCollaboration = try await service.getPublicCollaboration(id: id)
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    // MARK: - My Collaborations (Applications)

    func loadMyCollaborations() async {
        isLoading = true
        error = nil

        do {
            myCollaborations = try await service.getMyCollaborations()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    func getCollaboration(id: String) async {
        isLoading = true
        error = nil

        do {
            selectedCollaboration = try await service.getCollaboration(id: id)
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    // MARK: - Apply for Collaboration (Foodie)

    func applyForCollaboration(
        publicCollaborationId: String,
        message: String?,
        numberOfPeople: Int?,
        specialRequirements: String?,
        proposedRate: Double?
    ) async -> Bool {
        isLoading = true
        error = nil

        do {
            let request = ApplyForCollaborationRequest(
                publicCollaborationId: publicCollaborationId,
                message: message,
                numberOfPeople: numberOfPeople,
                specialRequirements: specialRequirements,
                proposedRate: proposedRate
            )
            let collaboration = try await service.applyForCollaboration(request: request)
            myCollaborations.insert(collaboration, at: 0)
            successMessage = String(localized: "Solicitud enviada correctamente")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Cancel Collaboration (Foodie)

    func cancelCollaboration(id: String) async -> Bool {
        isLoading = true
        error = nil

        do {
            try await service.cancelCollaboration(id: id)
            myCollaborations.removeAll { $0.id == id }
            successMessage = String(localized: "Solicitud cancelada")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Respond to Invitation (Foodie)

    func respondToInvitation(id: String, accept: Bool) async -> Bool {
        isLoading = true
        error = nil

        do {
            let updated = try await service.respondToInvitation(id: id, accept: accept)
            if let index = myCollaborations.firstIndex(where: { $0.id == id }) {
                myCollaborations[index] = updated
            }
            successMessage = accept ?
                String(localized: "Invitacion aceptada") :
                String(localized: "Invitacion rechazada")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Schedule Collaboration (Foodie)

    func scheduleCollaboration(
        id: String,
        date: Date,
        locationId: String?,
        locationName: String?
    ) async -> Bool {
        isLoading = true
        error = nil

        do {
            let formatter = ISO8601DateFormatter()
            let request = ScheduleCollaborationRequest(
                scheduledDate: formatter.string(from: date),
                selectedLocationId: locationId,
                selectedLocationName: locationName
            )
            let updated = try await service.scheduleCollaboration(id: id, request: request)
            if let index = myCollaborations.firstIndex(where: { $0.id == id }) {
                myCollaborations[index] = updated
            }
            selectedCollaboration = updated
            successMessage = String(localized: "Visita programada")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Content Links (Foodie)

    func addContentLink(id: String, link: String) async -> Bool {
        isLoading = true
        error = nil

        do {
            let updated = try await service.addContentLink(id: id, link: link)
            if let index = myCollaborations.firstIndex(where: { $0.id == id }) {
                myCollaborations[index] = updated
            }
            selectedCollaboration = updated
            successMessage = String(localized: "Enlace agregado")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Restaurant: My Public Collaborations

    func loadMyPublicCollaborations() async {
        isLoading = true
        error = nil

        do {
            myPublicCollaborations = try await service.getMyPublicCollaborations()
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
    }

    // MARK: - Restaurant: Update Collaboration Status

    func updateCollaborationStatus(id: String, status: ApplicationStatus) async -> Bool {
        isLoading = true
        error = nil

        do {
            let updated = try await service.updateCollaborationStatus(id: id, status: status.rawValue)
            if let index = myCollaborations.firstIndex(where: { $0.id == id }) {
                myCollaborations[index] = updated
            }
            selectedCollaboration = updated
            successMessage = String(localized: "Estado actualizado")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Restaurant: Update Public Collaboration Status

    func updatePublicCollaborationStatus(id: String, status: CollaborationStatus) async -> Bool {
        isLoading = true
        error = nil

        do {
            try await service.updatePublicCollaborationStatus(id: id, status: status.rawValue)
            if myPublicCollaborations.contains(where: { $0.id == id }) {
                await loadMyPublicCollaborations()
            }
            successMessage = String(localized: "Estado actualizado")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Restaurant: Delete Public Collaboration

    func deletePublicCollaboration(id: String) async -> Bool {
        isLoading = true
        error = nil

        do {
            try await service.deletePublicCollaboration(id: id)
            myPublicCollaborations.removeAll { $0.id == id }
            successMessage = String(localized: "Colaboracion eliminada")
            isLoading = false
            return true
        } catch let apiError as APIError {
            error = apiError.localizedDescription
        } catch {
            self.error = String(localized: "Error desconocido")
        }

        isLoading = false
        return false
    }

    // MARK: - Helpers

    func clearError() {
        error = nil
    }

    func clearSuccess() {
        successMessage = nil
    }

    // Filter active collaborations
    var activeCollaborations: [Collaboration] {
        myCollaborations.filter { $0.status == .pending || $0.status == .accepted }
    }

    // Filter historical collaborations
    var historyCollaborations: [Collaboration] {
        myCollaborations.filter { $0.status == .completed || $0.status == .rejected || $0.status == .cancelled }
    }

    // Filter invitations
    var invitations: [Collaboration] {
        myCollaborations.filter { $0.isInvitation && $0.status == .pending }
    }
}
