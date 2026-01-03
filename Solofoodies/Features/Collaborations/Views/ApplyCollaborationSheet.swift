//
//  ApplyCollaborationSheet.swift
//  Solofoodies
//

import SwiftUI

struct ApplyCollaborationSheet: View {
    let collaboration: PublicCollaboration
    @ObservedObject var viewModel: CollaborationsViewModel
    let onSuccess: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var message = ""
    @State private var numberOfPeople = 1
    @State private var specialRequirements = ""
    @State private var proposedRate: String = ""

    var body: some View {
        NavigationStack {
            Form {
                // Header
                Section {
                    HStack(spacing: 12) {
                        Image(systemName: collaboration.type.icon)
                            .font(.title2)
                            .foregroundStyle(Color(hex: "E53935"))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(collaboration.restaurantProfile?.restaurantName ?? "")
                                .font(.headline)
                            Text(collaboration.type.displayName)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                // Message
                Section {
                    TextField(String(localized: "Mensaje para el restaurante (opcional)"), text: $message, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text(String(localized: "Mensaje"))
                } footer: {
                    Text(String(localized: "Presentate brevemente y explica por que te interesa esta colaboracion"))
                }

                // Number of people
                if collaboration.maxCompanions > 0 {
                    Section {
                        Stepper(value: $numberOfPeople, in: 1...(collaboration.maxCompanions + 1)) {
                            HStack {
                                Text(String(localized: "Personas"))
                                Spacer()
                                Text("\(numberOfPeople)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    } header: {
                        Text(String(localized: "Acompanantes"))
                    } footer: {
                        Text(String(localized: "Maximo \(collaboration.maxCompanions + 1) personas (tu + \(collaboration.maxCompanions) acompanantes)"))
                    }
                }

                // Special requirements
                Section {
                    TextField(String(localized: "Alergias, preferencias, etc. (opcional)"), text: $specialRequirements, axis: .vertical)
                        .lineLimit(2...4)
                } header: {
                    Text(String(localized: "Requisitos especiales"))
                }

                // Proposed rate (if allowed)
                if collaboration.allowFoodieRateProposal {
                    Section {
                        HStack {
                            TextField(String(localized: "0"), text: $proposedRate)
                                .keyboardType(.decimalPad)
                            Text("€")
                                .foregroundStyle(.secondary)
                        }
                    } header: {
                        Text(String(localized: "Tu tarifa"))
                    } footer: {
                        Text(String(localized: "Puedes proponer una tarifa por tu trabajo. El restaurante decidira si la acepta"))
                    }
                }

                // Summary
                Section {
                    HStack {
                        Text(String(localized: "Compensacion"))
                        Spacer()
                        Text(collaboration.creditDescription)
                            .foregroundStyle(Color(hex: "E53935"))
                            .fontWeight(.semibold)
                    }

                    if !collaboration.availableDays.isEmpty {
                        HStack {
                            Text(String(localized: "Dias disponibles"))
                            Spacer()
                            Text(collaboration.availableDays.prefix(3).joined(separator: ", "))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                } header: {
                    Text(String(localized: "Resumen"))
                }
            }
            .navigationTitle(String(localized: "Solicitar colaboracion"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task {
                            await submitApplication()
                        }
                    } label: {
                        if viewModel.isLoading {
                            ProgressView()
                        } else {
                            Text(String(localized: "Enviar"))
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
            }
        }
    }

    private func submitApplication() async {
        let rate: Double? = {
            guard collaboration.allowFoodieRateProposal,
                  !proposedRate.isEmpty,
                  let value = Double(proposedRate.replacingOccurrences(of: ",", with: ".")) else {
                return nil
            }
            return value
        }()

        let success = await viewModel.applyForCollaboration(
            publicCollaborationId: collaboration.id,
            message: message.isEmpty ? nil : message,
            numberOfPeople: numberOfPeople,
            specialRequirements: specialRequirements.isEmpty ? nil : specialRequirements,
            proposedRate: rate
        )

        if success {
            dismiss()
            onSuccess()
        }
    }
}

#Preview {
    ApplyCollaborationSheet(
        collaboration: PublicCollaboration(
            id: "1",
            restaurantProfileId: "1",
            type: .influencerVisit,
            image: nil,
            requirements: nil,
            minFollowers: 5000,
            maxCompanions: 2,
            creditMode: "exchange",
            creditType: "percentage",
            creditValue: 100,
            allowFoodieRateProposal: true,
            availableDays: ["Lunes", "Martes"],
            locationIds: [],
            status: .open,
            isPrivate: false,
            createdAt: Date(),
            updatedAt: Date(),
            productName: nil,
            productRequirements: nil,
            quantityPerCreator: nil,
            productValue: nil,
            productValueCurrency: nil,
            productVariations: nil,
            shippingZoneName: nil,
            shipsWorldwide: nil,
            eventName: nil,
            venueName: nil,
            venueAddress: nil,
            eventCountry: nil,
            eventCountryIso: nil,
            eventCity: nil,
            eventProvince: nil,
            eventContactPerson: nil,
            eventContactPhone: nil,
            eventType: nil,
            eventDate: nil,
            eventStartTime: nil,
            eventEndTime: nil,
            creatorArrivalTime: nil,
            rsvpDeadline: nil,
            eventRequirements: nil,
            whatToExpect: nil,
            dressCode: nil,
            hashtags: nil,
            accountsToTag: nil,
            toneSuggestions: nil,
            title: nil,
            description: nil,
            city: "Madrid",
            restaurantProfile: RestaurantProfileData(
                id: "1",
                restaurantName: "Restaurante Demo",
                contactName: nil,
                coverImage: nil,
                bio: nil,
                followers: nil,
                profilePicture: nil,
                user: nil,
                address: nil,
                locations: nil
            ),
            collabLocations: nil,
            provinces: nil,
            collaborations: nil
        ),
        viewModel: CollaborationsViewModel()
    ) {}
}
