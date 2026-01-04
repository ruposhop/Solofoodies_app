//
//  ProfileMenuViews.swift
//  Solofoodies
//
//  Menu destination views for Foodie and Restaurant profiles
//

import SwiftUI

// MARK: - Foodie Menu Views

struct EditProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) private var dismiss

    private var user: User? { authViewModel.currentUser }
    private var foodieProfile: FoodieProfileData? { user?.foodieProfile }

    @State private var name: String = ""
    @State private var bio: String = ""
    @State private var isSaving = false

    var body: some View {
        Form {
            Section(String(localized: "Informacion personal")) {
                HStack {
                    Text(String(localized: "Nombre"))
                    Spacer()
                    TextField("", text: $name)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text(String(localized: "Instagram"))
                    Spacer()
                    Text("@\(user?.igUsername ?? "")")
                        .foregroundStyle(.secondary)
                }
            }

            Section(String(localized: "Bio")) {
                TextEditor(text: $bio)
                    .frame(minHeight: 100)
            }

            Section(String(localized: "Redes sociales")) {
                if let networks = viewModel.fullProfile?.foodieProfile?.socialNetworks {
                    ForEach(networks) { network in
                        HStack {
                            Image(systemName: network.platform.icon)
                                .foregroundStyle(Color(hex: "E53935"))
                            Text(network.platform.displayName)
                            Spacer()
                            Text("@\(network.username)")
                                .foregroundStyle(.secondary)
                            Text("\(network.followers.formatted())")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } else {
                    Text(String(localized: "No hay redes sociales configuradas"))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle(String(localized: "Editar perfil"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    // TODO: Save profile
                } label: {
                    if isSaving {
                        ProgressView()
                    } else {
                        Text(String(localized: "Guardar"))
                    }
                }
                .disabled(isSaving)
            }
        }
        .onAppear {
            name = user?.name ?? ""
            bio = foodieProfile?.bio ?? ""
        }
        .task {
            if let userId = user?.id {
                await viewModel.loadProfileData(for: userId)
            }
        }
    }
}

struct TripsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showAddTrip = false

    private var user: User? { authViewModel.currentUser }

    var body: some View {
        List {
            if let trips = viewModel.fullProfile?.foodieProfile?.trips, !trips.isEmpty {
                Section(String(localized: "Proximos viajes")) {
                    ForEach(trips.filter { $0.isUpcoming }) { trip in
                        tripRow(trip)
                    }
                }

                Section(String(localized: "Viajes activos")) {
                    ForEach(trips.filter { $0.isActive }) { trip in
                        tripRow(trip)
                    }
                }
            } else {
                ContentUnavailableView(
                    String(localized: "Sin viajes"),
                    systemImage: "airplane",
                    description: Text(String(localized: "Anade viajes para que los restaurantes de esas zonas puedan encontrarte"))
                )
            }
        }
        .navigationTitle(String(localized: "Viajes"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddTrip = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddTrip) {
            AddTripSheet()
        }
        .task {
            if let userId = user?.id {
                await viewModel.loadProfileData(for: userId)
            }
        }
    }

    private func tripRow(_ trip: ProfileTrip) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(trip.state), \(trip.country)")
                    .font(.headline)

                Text("\(trip.startDate.formatted(date: .abbreviated, time: .omitted)) - \(trip.endDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if trip.isActive {
                Text(String(localized: "Activo"))
                    .font(.caption.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .foregroundStyle(.green)
                    .cornerRadius(4)
            }
        }
    }
}

struct AddTripSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var country = "Espana"
    @State private var province = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(7 * 24 * 60 * 60)

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Destino")) {
                    TextField(String(localized: "Pais"), text: $country)
                    TextField(String(localized: "Provincia/Estado"), text: $province)
                }

                Section(String(localized: "Fechas")) {
                    DatePicker(String(localized: "Desde"), selection: $startDate, displayedComponents: .date)
                    DatePicker(String(localized: "Hasta"), selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle(String(localized: "Nuevo viaje"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Guardar")) {
                        // TODO: Save trip
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ReviewsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()

    private var user: User? { authViewModel.currentUser }

    var body: some View {
        List {
            if !viewModel.ratings.isEmpty {
                // Stats
                Section {
                    HStack {
                        VStack {
                            Text(String(format: "%.1f", viewModel.ratingStats.averageScore ?? 0))
                                .font(.largeTitle.bold())
                            HStack(spacing: 2) {
                                ForEach(1...5, id: \.self) { star in
                                    Image(systemName: star <= Int(viewModel.ratingStats.averageScore ?? 0) ? "star.fill" : "star")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                        }

                        Spacer()

                        VStack(alignment: .trailing) {
                            Text("\(viewModel.ratingStats.totalRatings)")
                                .font(.title2.bold())
                            Text(String(localized: "resenas"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Reviews
                Section(String(localized: "Resenas recientes")) {
                    ForEach(viewModel.ratings) { rating in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(rating.rater?.name ?? "Usuario")
                                    .font(.subheadline.bold())

                                Spacer()

                                HStack(spacing: 2) {
                                    ForEach(1...5, id: \.self) { star in
                                        Image(systemName: star <= rating.score ? "star.fill" : "star")
                                            .font(.caption2)
                                            .foregroundStyle(.orange)
                                    }
                                }
                            }

                            if let comment = rating.comment, !comment.isEmpty {
                                Text(comment)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Text(rating.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption2)
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                }
            } else {
                ContentUnavailableView(
                    String(localized: "Sin resenas"),
                    systemImage: "star",
                    description: Text(String(localized: "Completa colaboraciones para recibir resenas de los restaurantes"))
                )
            }
        }
        .navigationTitle(String(localized: "Resenas"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            if let userId = user?.id {
                await viewModel.loadProfileData(for: userId)
            }
        }
    }
}

struct RatesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showAddRate = false

    private var user: User? { authViewModel.currentUser }

    var body: some View {
        List {
            if let rates = viewModel.fullProfile?.foodieProfile?.rates, !rates.isEmpty {
                ForEach(rates) { rate in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(rate.description)
                                .font(.subheadline)
                        }

                        Spacer()

                        Text(String(format: "%.0f€", rate.price))
                            .font(.headline)
                            .foregroundStyle(Color(hex: "E53935"))
                    }
                }
            } else {
                ContentUnavailableView(
                    String(localized: "Sin tarifas"),
                    systemImage: "eurosign.circle",
                    description: Text(String(localized: "Anade tus tarifas para que los restaurantes conozcan tus precios"))
                )
            }
        }
        .navigationTitle(String(localized: "Tarifas"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showAddRate = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showAddRate) {
            AddRateSheet()
        }
        .task {
            if let userId = user?.id {
                await viewModel.loadProfileData(for: userId)
            }
        }
    }
}

struct AddRateSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var description = ""
    @State private var price = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(String(localized: "Descripcion")) {
                    TextField(String(localized: "Ej: Pack Historias + Reel"), text: $description)
                }

                Section(String(localized: "Precio")) {
                    HStack {
                        TextField("0", text: $price)
                            .keyboardType(.numberPad)
                        Text("€")
                    }
                }
            }
            .navigationTitle(String(localized: "Nueva tarifa"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(String(localized: "Cancelar")) {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Guardar")) {
                        // TODO: Save rate
                        dismiss()
                    }
                }
            }
        }
    }
}

struct HistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CollaborationsViewModel()

    var body: some View {
        List {
            if !viewModel.myCollaborations.isEmpty {
                ForEach(viewModel.myCollaborations.filter { $0.status == .completed }) { collab in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(collab.publicCollaboration?.type.displayName ?? "Colaboracion")
                                .font(.subheadline.bold())

                            Spacer()

                            Text(collab.status.displayName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color(hex: collab.status.color).opacity(0.2))
                                .foregroundStyle(Color(hex: collab.status.color))
                                .cornerRadius(4)
                        }

                        if let date = collab.scheduledDate {
                            Text(date.formatted(date: .abbreviated, time: .omitted))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else {
                ContentUnavailableView(
                    String(localized: "Sin historial"),
                    systemImage: "clock",
                    description: Text(String(localized: "Aqui apareceran tus colaboraciones completadas"))
                )
            }
        }
        .navigationTitle(String(localized: "Historial"))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMyCollaborations()
        }
    }
}

struct InvitationsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var inviteCode: String = ""
    @State private var copied = false

    private var user: User? { authViewModel.currentUser }

    var body: some View {
        VStack(spacing: 24) {
            // Invite Code Card
            VStack(spacing: 16) {
                Image(systemName: "gift.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color(hex: "E53935"))

                Text(String(localized: "Invita a tus amigos"))
                    .font(.title2.bold())

                Text(String(localized: "Comparte tu codigo y gana creditos cuando se registren"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                // Code display
                HStack {
                    Text(user?.igUsername?.uppercased() ?? "TUCODIGO")
                        .font(.title3.bold())
                        .kerning(2)

                    Button {
                        UIPasteboard.general.string = user?.igUsername?.uppercased() ?? ""
                        copied = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            copied = false
                        }
                    } label: {
                        Image(systemName: copied ? "checkmark" : "doc.on.doc")
                            .foregroundStyle(Color(hex: "E53935"))
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding(.horizontal)

            // Share Button
            ShareLink(
                item: "Unete a Solofoodies con mi codigo: \(user?.igUsername?.uppercased() ?? "")\nhttps://solofoodies.com/register?code=\(user?.igUsername ?? "")",
                subject: Text("Invitacion a Solofoodies"),
                message: Text("Te invito a unirte a Solofoodies")
            ) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text(String(localized: "Compartir invitacion"))
                }
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(hex: "E53935"))
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.horizontal)

            Spacer()
        }
        .padding(.top)
        .navigationTitle(String(localized: "Invitaciones"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Restaurant Menu Views

struct RestaurantProfileEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var restaurantName: String = ""
    @State private var bio: String = ""
    @State private var contactName: String = ""
    @State private var phone: String = ""

    private var user: User? { authViewModel.currentUser }
    private var restaurant: RestaurantProfile? { user?.restaurants?.first }

    var body: some View {
        Form {
            Section(String(localized: "Informacion del restaurante")) {
                HStack {
                    Text(String(localized: "Nombre"))
                    Spacer()
                    TextField("", text: $restaurantName)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text(String(localized: "Instagram"))
                    Spacer()
                    Text("@\(user?.igUsername ?? "")")
                        .foregroundStyle(.secondary)
                }
            }

            Section(String(localized: "Bio")) {
                TextEditor(text: $bio)
                    .frame(minHeight: 100)
            }

            Section(String(localized: "Contacto")) {
                HStack {
                    Text(String(localized: "Nombre de contacto"))
                    Spacer()
                    TextField("", text: $contactName)
                        .multilineTextAlignment(.trailing)
                }

                HStack {
                    Text(String(localized: "Telefono"))
                    Spacer()
                    TextField("", text: $phone)
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.phonePad)
                }
            }

            Section(String(localized: "Direccion")) {
                if let address = restaurant?.address {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(address.line ?? "")
                        Text("\(address.city ?? ""), \(address.state ?? "")")
                            .foregroundStyle(.secondary)
                        Text("\(address.zipCode ?? "") \(address.country ?? "")")
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle(String(localized: "Mi Restaurante"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(String(localized: "Guardar")) {
                    // TODO: Save
                }
            }
        }
        .onAppear {
            restaurantName = restaurant?.restaurantName ?? ""
            bio = restaurant?.bio ?? ""
            contactName = restaurant?.contactName ?? ""
            phone = restaurant?.phone ?? ""
        }
    }
}

struct SubscriptionView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    private var user: User? { authViewModel.currentUser }
    private var subscription: UserSubscription? { user?.subscription }

    var body: some View {
        VStack(spacing: 24) {
            // Current Plan
            VStack(spacing: 16) {
                Image(systemName: subscription?.status == .active ? "crown.fill" : "crown")
                    .font(.system(size: 48))
                    .foregroundStyle(subscription?.status == .active ? .yellow : .secondary)

                Text(subscription?.plan?.name ?? "Plan Gratuito")
                    .font(.title2.bold())

                if let subscription = subscription {
                    HStack {
                        Text(subscription.status == .active ? String(localized: "Activo") : String(localized: "Inactivo"))
                            .font(.caption.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(subscription.status == .active ? Color.green : Color.orange)
                            .foregroundStyle(.white)
                            .cornerRadius(8)

                        if subscription.isOnTrial == true {
                            Text(String(localized: "Periodo de prueba"))
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.blue)
                                .foregroundStyle(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(.systemBackground))
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
            .padding(.horizontal)

            // Plan Details
            if let plan = subscription?.plan {
                VStack(alignment: .leading, spacing: 12) {
                    Text(String(localized: "Detalles del plan"))
                        .font(.headline)

                    HStack {
                        Text(String(localized: "Precio mensual"))
                        Spacer()
                        Text(String(format: "%.2f€", plan.monthlyPrice))
                    }

                    HStack {
                        Text(String(localized: "Restaurantes permitidos"))
                        Spacer()
                        Text(plan.maxRestaurants != nil ? "\(plan.maxRestaurants!)" : "Ilimitados")
                    }

                    if let endDate = subscription?.currentPeriodEnd {
                        HStack {
                            Text(String(localized: "Proximo cobro"))
                            Spacer()
                            Text(endDate)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding(.horizontal)
            }

            Spacer()

            // Upgrade Button
            if subscription?.status != .active {
                Button {
                    // TODO: Open subscription flow
                } label: {
                    Text(String(localized: "Mejorar plan"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "E53935"))
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
        }
        .padding(.top)
        .navigationTitle(String(localized: "Suscripcion"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RestaurantHistoryView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = CollaborationsViewModel()

    var body: some View {
        restaurantHistoryContent
            .navigationTitle(String(localized: "Historial"))
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await viewModel.loadMyPublicCollaborations()
            }
    }

    @ViewBuilder
    private var restaurantHistoryContent: some View {
        let collabs = viewModel.myPublicCollaborations
        if collabs.isEmpty && !viewModel.isLoading {
            VStack(spacing: 16) {
                Image(systemName: "clock")
                    .font(.system(size: 48))
                    .foregroundStyle(.secondary)
                Text(String(localized: "Sin historial"))
                    .font(.headline)
                Text(String(localized: "Aqui apareceran tus colaboraciones completadas"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(collabs) { collab in
                        restaurantHistoryRow(collab)
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private func restaurantHistoryRow(_ collab: PublicCollaboration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(collab.type.displayName)
                    .font(.subheadline.bold())

                Spacer()

                Text(collab.status.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: collab.status.color).opacity(0.2))
                    .foregroundStyle(Color(hex: collab.status.color))
                    .cornerRadius(4)
            }

            if let requirements = collab.requirements {
                Text(requirements)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var notificationsEnabled = true
    @State private var emailNotifications = true
    @State private var language = "es"

    var body: some View {
        Form {
            Section(String(localized: "Notificaciones")) {
                Toggle(String(localized: "Notificaciones push"), isOn: $notificationsEnabled)
                Toggle(String(localized: "Notificaciones por email"), isOn: $emailNotifications)
            }

            Section(String(localized: "Preferencias")) {
                Picker(String(localized: "Idioma"), selection: $language) {
                    Text("Espanol").tag("es")
                    Text("English").tag("en")
                }
            }

            Section(String(localized: "Cuenta")) {
                Button(String(localized: "Cambiar contrasena")) {
                    // TODO
                }

                Button(String(localized: "Cambiar email")) {
                    // TODO
                }
            }

            Section {
                Button(role: .destructive) {
                    // TODO: Delete account
                } label: {
                    Text(String(localized: "Eliminar cuenta"))
                }
            }
        }
        .navigationTitle(String(localized: "Configuracion"))
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Previews

#Preview("Edit Profile") {
    NavigationStack {
        EditProfileView()
            .environmentObject(AuthViewModel())
    }
}

#Preview("Trips") {
    NavigationStack {
        TripsView()
            .environmentObject(AuthViewModel())
    }
}

#Preview("Reviews") {
    NavigationStack {
        ReviewsView()
            .environmentObject(AuthViewModel())
    }
}

#Preview("Rates") {
    NavigationStack {
        RatesView()
            .environmentObject(AuthViewModel())
    }
}

#Preview("Invitations") {
    NavigationStack {
        InvitationsView()
            .environmentObject(AuthViewModel())
    }
}

#Preview("Subscription") {
    NavigationStack {
        SubscriptionView()
            .environmentObject(AuthViewModel())
    }
}

#Preview("Settings") {
    NavigationStack {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
