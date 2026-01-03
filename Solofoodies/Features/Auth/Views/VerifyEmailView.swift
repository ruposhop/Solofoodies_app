//
//  VerifyEmailView.swift
//  Solofoodies
//

import SwiftUI

struct VerifyEmailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var code = ""
    @State private var showResendMessage = false

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // Icon
            Image(systemName: "envelope.badge.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color(hex: "E53935"))

            // Title and description
            VStack(spacing: 12) {
                Text(String(localized: "Verifica tu email"))
                    .font(.title2.bold())

                Text(String(localized: "Hemos enviado un codigo de verificacion a tu email. Ingresalo a continuacion."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let email = authViewModel.currentUser?.email {
                    Text(email)
                        .font(.subheadline.bold())
                        .foregroundStyle(Color(hex: "E53935"))
                }
            }

            // Code input
            TextField(String(localized: "Codigo de verificacion"), text: $code)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2.monospaced())
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal, 48)

            // Error message
            if let error = authViewModel.error {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }

            // Resend message
            if showResendMessage {
                Text(String(localized: "Codigo reenviado"))
                    .foregroundColor(.green)
                    .font(.caption)
            }

            // Verify Button
            Button {
                Task {
                    await authViewModel.verifyEmail(code: code)
                }
            } label: {
                if authViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(String(localized: "Verificar"))
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(hex: "E53935"))
            .foregroundColor(.white)
            .cornerRadius(12)
            .padding(.horizontal, 24)
            .disabled(code.isEmpty || authViewModel.isLoading)
            .opacity(code.isEmpty ? 0.6 : 1)

            // Resend button
            Button {
                Task {
                    await authViewModel.resendCode()
                    showResendMessage = true
                    // Hide message after 3 seconds
                    try? await Task.sleep(nanoseconds: 3_000_000_000)
                    showResendMessage = false
                }
            } label: {
                Text(String(localized: "Reenviar codigo"))
                    .foregroundColor(Color(hex: "E53935"))
            }
            .disabled(authViewModel.isLoading)

            Spacer()

            // Logout option
            Button {
                authViewModel.logout()
            } label: {
                Text(String(localized: "Usar otra cuenta"))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            .padding(.bottom, 20)
        }
        .onAppear {
            authViewModel.clearError()
        }
    }
}

#Preview {
    VerifyEmailView()
        .environmentObject(AuthViewModel())
}
