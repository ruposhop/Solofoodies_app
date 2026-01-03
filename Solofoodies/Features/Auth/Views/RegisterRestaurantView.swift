//
//  RegisterRestaurantView.swift
//  Solofoodies
//

import SwiftUI

struct RegisterRestaurantView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    // Basic info
    @State private var restaurantName = ""
    @State private var contactName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var igUsername = ""
    @State private var phone = ""

    // Address
    @State private var addressLine = ""
    @State private var city = ""
    @State private var state = ""
    @State private var zipCode = ""
    @State private var country = "Espana"

    // Billing (same as address for now)
    @State private var cif = ""
    @State private var businessName = ""

    // Agreements
    @State private var termsAccepted = false
    @State private var communicationsAccepted = false

    private var isFormValid: Bool {
        !restaurantName.isEmpty &&
        !contactName.isEmpty &&
        !email.isEmpty &&
        !igUsername.isEmpty &&
        !phone.isEmpty &&
        !addressLine.isEmpty &&
        !city.isEmpty &&
        !cif.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 8 &&
        termsAccepted
    }

    private var passwordError: String? {
        if !password.isEmpty && password.count < 8 {
            return String(localized: "La contrasena debe tener al menos 8 caracteres")
        }
        if !confirmPassword.isEmpty && password != confirmPassword {
            return String(localized: "Las contrasenas no coinciden")
        }
        return nil
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "building.2.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(hex: "E53935"))

                    Text(String(localized: "Registro de Restaurante"))
                        .font(.title2.bold())
                }
                .padding(.top, 20)

                // Form sections
                VStack(spacing: 24) {
                    // Basic Info Section
                    FormSection(title: "Informacion basica") {
                        TextField(String(localized: "Nombre del restaurante"), text: $restaurantName)
                            .textContentType(.organizationName)

                        TextField(String(localized: "Nombre de contacto"), text: $contactName)
                            .textContentType(.name)

                        TextField(String(localized: "Email"), text: $email)
                            .textContentType(.emailAddress)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        TextField(String(localized: "Usuario de Instagram"), text: $igUsername)
                            .autocapitalization(.none)

                        TextField(String(localized: "Telefono"), text: $phone)
                            .textContentType(.telephoneNumber)
                            .keyboardType(.phonePad)
                    }

                    // Address Section
                    FormSection(title: "Direccion") {
                        TextField(String(localized: "Direccion"), text: $addressLine)
                            .textContentType(.streetAddressLine1)

                        TextField(String(localized: "Ciudad"), text: $city)
                            .textContentType(.addressCity)

                        TextField(String(localized: "Provincia"), text: $state)
                            .textContentType(.addressState)

                        TextField(String(localized: "Codigo postal"), text: $zipCode)
                            .textContentType(.postalCode)
                            .keyboardType(.numberPad)
                    }

                    // Billing Section
                    FormSection(title: "Facturacion") {
                        TextField(String(localized: "CIF/NIF"), text: $cif)

                        TextField(String(localized: "Razon social"), text: $businessName)
                    }

                    // Password Section
                    FormSection(title: "Contrasena") {
                        SecureField(String(localized: "Contrasena"), text: $password)
                            .textContentType(.newPassword)

                        SecureField(String(localized: "Confirmar contrasena"), text: $confirmPassword)
                            .textContentType(.newPassword)

                        if let passwordError = passwordError {
                            Text(passwordError)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }

                    // Agreements
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle(isOn: $termsAccepted) {
                            Text(String(localized: "Acepto los terminos y condiciones"))
                                .font(.subheadline)
                        }

                        Toggle(isOn: $communicationsAccepted) {
                            Text(String(localized: "Acepto recibir comunicaciones"))
                                .font(.subheadline)
                        }
                    }
                    .padding(.horizontal, 24)
                }

                // Error message
                if let error = authViewModel.error {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.horizontal)
                        .multilineTextAlignment(.center)
                }

                // Register Button
                Button {
                    Task {
                        let request = RegisterRestaurantRequest(
                            name: restaurantName,
                            email: email,
                            password: password,
                            passwordConfirmation: confirmPassword,
                            igUsername: igUsername,
                            contactName: contactName,
                            phone: phone,
                            line: addressLine,
                            city: city,
                            state: state,
                            zipCode: zipCode,
                            country: country,
                            countryIso: "ES",
                            cif: cif,
                            businessName: businessName.isEmpty ? restaurantName : businessName,
                            addressLine: addressLine,
                            billingCity: city,
                            billingState: state,
                            billingZipCode: zipCode,
                            billingCountry: country,
                            billingCountryIso: "ES",
                            termsAccepted: termsAccepted,
                            communicationsAccepted: communicationsAccepted
                        )
                        await authViewModel.registerRestaurant(request: request)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(String(localized: "Crear cuenta"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "E53935"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .disabled(!isFormValid || authViewModel.isLoading)
                .opacity(!isFormValid ? 0.6 : 1)

                Spacer()
                    .frame(height: 40)
            }
        }
        .navigationTitle(String(localized: "Restaurante"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authViewModel.clearError()
        }
    }
}

// MARK: - Form Section Component

struct FormSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color(hex: "333333"))
                .padding(.horizontal, 24)

            VStack(spacing: 12) {
                content
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
            .padding(.horizontal, 24)
        }
    }
}

#Preview {
    NavigationStack {
        RegisterRestaurantView()
            .environmentObject(AuthViewModel())
    }
}
