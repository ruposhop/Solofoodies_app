//
//  LoginView.swift
//  Solofoodies
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showRegisterSelection = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Logo placeholder
                Image(systemName: "fork.knife.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(Color(hex: "E53935"))

                Text("Solofoodies")
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color(hex: "333333"))

                Spacer()

                // Form
                VStack(spacing: 16) {
                    TextField(String(localized: "Email"), text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .autocorrectionDisabled()
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)

                    SecureField(String(localized: "Contrasena"), text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
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

                // Login Button
                Button {
                    Task {
                        await authViewModel.login(email: email, password: password)
                    }
                } label: {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text(String(localized: "Iniciar sesion"))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "E53935"))
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 24)
                .disabled(email.isEmpty || password.isEmpty || authViewModel.isLoading)
                .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1)

                // Register Link
                Button {
                    showRegisterSelection = true
                } label: {
                    Text(String(localized: "No tienes cuenta? Registrate"))
                        .foregroundColor(Color(hex: "E53935"))
                }

                Spacer()
            }
            .navigationDestination(isPresented: $showRegisterSelection) {
                RegisterSelectionView()
            }
            .onAppear {
                authViewModel.clearError()
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
