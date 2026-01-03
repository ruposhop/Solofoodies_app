//
//  ContentView.swift
//  Solofoodies
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()

    var body: some View {
        Group {
            if authViewModel.isAuthenticated {
                if authViewModel.needsEmailVerification {
                    VerifyEmailView()
                } else if let user = authViewModel.currentUser {
                    // Show appropriate tab view based on role
                    switch user.role {
                    case .foodie:
                        FoodieTabView()
                    case .restaurant:
                        RestaurantTabView()
                    default:
                        // For admin/investor, show login for now
                        LoginView()
                    }
                } else {
                    // Loading current user
                    LoadingView()
                }
            } else {
                LoginView()
            }
        }
        .environmentObject(authViewModel)
    }
}

// MARK: - Loading View

struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            Text(String(localized: "Cargando..."))
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Foodie Tab View (Placeholder)

struct FoodieTabView: View {
    var body: some View {
        TabView {
            PlaceholderView(title: "Explorar", icon: "magnifyingglass")
                .tabItem {
                    Label(String(localized: "Explorar"), systemImage: "magnifyingglass")
                }

            PlaceholderView(title: "Colaboraciones", icon: "star.fill")
                .tabItem {
                    Label(String(localized: "Colaboraciones"), systemImage: "star.fill")
                }

            PlaceholderView(title: "Chat", icon: "message.fill")
                .tabItem {
                    Label(String(localized: "Chat"), systemImage: "message.fill")
                }

            ProfilePlaceholderView()
                .tabItem {
                    Label(String(localized: "Perfil"), systemImage: "person.fill")
                }
        }
        .tint(Color(hex: "E53935"))
    }
}

// MARK: - Restaurant Tab View (Placeholder)

struct RestaurantTabView: View {
    var body: some View {
        TabView {
            PlaceholderView(title: "Colaboraciones", icon: "star.fill")
                .tabItem {
                    Label(String(localized: "Colaboraciones"), systemImage: "star.fill")
                }

            PlaceholderView(title: "Solicitudes", icon: "person.2.fill")
                .tabItem {
                    Label(String(localized: "Solicitudes"), systemImage: "person.2.fill")
                }

            PlaceholderView(title: "Chat", icon: "message.fill")
                .tabItem {
                    Label(String(localized: "Chat"), systemImage: "message.fill")
                }

            ProfilePlaceholderView()
                .tabItem {
                    Label(String(localized: "Perfil"), systemImage: "person.fill")
                }
        }
        .tint(Color(hex: "E53935"))
    }
}

// MARK: - Placeholder Views

struct PlaceholderView: View {
    let title: String
    let icon: String

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 60))
                    .foregroundStyle(.tertiary)

                Text("Proximamente")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .navigationTitle(title)
        }
    }
}

struct ProfilePlaceholderView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                if let user = authViewModel.currentUser {
                    // Avatar placeholder
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(Color(hex: "E53935"))

                    VStack(spacing: 4) {
                        Text(user.name)
                            .font(.title2.bold())

                        Text(user.email)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Text(user.role.rawValue.capitalized)
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(Color(hex: "E53935").opacity(0.1))
                            .foregroundStyle(Color(hex: "E53935"))
                            .cornerRadius(8)
                    }
                }

                Spacer()

                // Logout button
                Button(role: .destructive) {
                    authViewModel.logout()
                } label: {
                    HStack {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                        Text(String(localized: "Cerrar sesion"))
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
            }
            .padding(.top, 40)
            .navigationTitle(String(localized: "Perfil"))
        }
    }
}

#Preview {
    ContentView()
}
