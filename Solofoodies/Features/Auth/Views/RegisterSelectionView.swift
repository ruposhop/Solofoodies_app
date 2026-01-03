//
//  RegisterSelectionView.swift
//  Solofoodies
//

import SwiftUI

struct RegisterSelectionView: View {
    @State private var showFoodieRegister = false
    @State private var showRestaurantRegister = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(String(localized: "Como quieres registrarte?"))
                .font(.title2.bold())
                .foregroundStyle(Color(hex: "333333"))

            VStack(spacing: 16) {
                // Foodie option
                Button {
                    showFoodieRegister = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "person.crop.circle.fill")
                            .font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "Soy Creador"))
                                .font(.headline)
                            Text(String(localized: "Quiero colaborar con restaurantes"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)

                // Restaurant option
                Button {
                    showRestaurantRegister = true
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: "building.2.crop.circle.fill")
                            .font(.system(size: 40))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "Soy Restaurante"))
                                .font(.headline)
                            Text(String(localized: "Quiero encontrar creadores"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer()
        }
        .navigationTitle(String(localized: "Registrarse"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showFoodieRegister) {
            RegisterFoodieView()
        }
        .navigationDestination(isPresented: $showRestaurantRegister) {
            RegisterRestaurantView()
        }
    }
}

#Preview {
    NavigationStack {
        RegisterSelectionView()
    }
}
