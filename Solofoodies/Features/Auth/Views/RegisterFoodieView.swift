//
//  RegisterFoodieView.swift
//  Solofoodies
//

import SwiftUI

struct RegisterFoodieView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var igUsername = ""
    @State private var inviteCode = ""

    private var isFormValid: Bool {
        !name.isEmpty &&
        !email.isEmpty &&
        !igUsername.isEmpty &&
        !inviteCode.isEmpty &&
        !password.isEmpty &&
        password == confirmPassword &&
        password.count >= 8
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
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color(hex: "E53935"))

                    Text(String(localized: "Registro de Creador"))
                        .font(.title2.bold())
                }
                .padding(.top, 20)

                // Form
                VStack(spacing: 16) {
                    TextField(String(localized: "Nombre completo"), text: $name)
                        .textContentType(.name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    TextField(String(localized: "Email"), text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    TextField(String(localized: "Usuario de Instagram"), text: $igUsername)
                        .textContentType(.username)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    TextField(String(localized: "Codigo de invitacion"), text: $inviteCode)
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    SecureField(String(localized: "Contrasena"), text: $password)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    SecureField(String(localized: "Confirmar contrasena"), text: $confirmPassword)
                        .textContentType(.newPassword)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    // Password validation message
                    if let passwordError = passwordError {
                        Text(passwordError)
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 24)

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
                        await authViewModel.registerFoodie(
                            name: name,
                            email: email,
                            password: password,
                            igUsername: igUsername,
                            inviteCode: inviteCode
                        )
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
            }
        }
        .navigationTitle(String(localized: "Creador"))
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            authViewModel.clearError()
        }
    }
}

#Preview {
    NavigationStack {
        RegisterFoodieView()
            .environmentObject(AuthViewModel())
    }
}
