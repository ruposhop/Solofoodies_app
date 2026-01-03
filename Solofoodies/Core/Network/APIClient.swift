//
//  APIClient.swift
//  Solofoodies
//

import Foundation

final class APIClient: @unchecked Sendable {
    static let shared = APIClient()

    private let baseURL: URL
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    private init() {
        self.baseURL = URL(string: "https://solofoodiesnewreact-production-7dd9.up.railway.app/api")!

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 30
        self.session = URLSession(configuration: config)

        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase

        self.encoder = JSONEncoder()
        self.encoder.dateEncodingStrategy = .iso8601
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    // MARK: - Public Methods

    func get<T: Decodable>(_ endpoint: APIEndpoint, queryItems: [URLQueryItem]? = nil) async throws -> T {
        return try await request(endpoint, method: "GET", queryItems: queryItems)
    }

    func post<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        return try await request(endpoint, method: "POST", body: body)
    }

    func post<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        let _: EmptyResponse = try await request(endpoint, method: "POST", body: body)
    }

    func put<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        return try await request(endpoint, method: "PUT", body: body)
    }

    func patch<T: Decodable, B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws -> T {
        return try await request(endpoint, method: "PATCH", body: body)
    }

    func patch<B: Encodable>(_ endpoint: APIEndpoint, body: B) async throws {
        let _: EmptyResponse = try await request(endpoint, method: "PATCH", body: body)
    }

    func delete(_ endpoint: APIEndpoint) async throws {
        let _: EmptyResponse = try await request(endpoint, method: "DELETE")
    }

    // MARK: - Private

    private func request<T: Decodable>(
        _ endpoint: APIEndpoint,
        method: String,
        queryItems: [URLQueryItem]? = nil,
        body: (any Encodable)? = nil
    ) async throws -> T {
        // Build URL
        let path = endpoint.path
        var urlComponents = URLComponents(url: baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: true)
        urlComponents?.queryItems = queryItems

        guard let url = urlComponents?.url else {
            throw APIError.invalidURL
        }

        // Build request
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // Add auth token if available
        if let token = KeychainManager.shared.getToken() {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        // Add body if present
        if let body = body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }

        // Debug logging
        print("🌐 API Request: \(method) \(url)")
        if let bodyData = request.httpBody, let bodyString = String(data: bodyData, encoding: .utf8) {
            print("📤 Body: \(bodyString)")
        }

        // Execute request
        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            print("❌ Network Error: \(error)")
            throw APIError.networkError(error)
        }

        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        // Debug logging
        print("📥 Response: \(httpResponse.statusCode)")
        if let responseString = String(data: data, encoding: .utf8) {
            print("📥 Data: \(responseString.prefix(500))")
        }

        // Handle status codes
        switch httpResponse.statusCode {
        case 200...299:
            if T.self == EmptyResponse.self {
                return EmptyResponse() as! T
            }
            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                print("❌ Decoding Error: \(error)")
                throw APIError.decodingError(error)
            }

        case 401:
            KeychainManager.shared.clearToken()
            throw APIError.unauthorized

        case 403:
            throw APIError.forbidden

        case 404:
            throw APIError.notFound

        default:
            if let errorResponse = try? decoder.decode(ErrorResponse.self, from: data) {
                throw APIError.serverError(errorResponse.error)
            }
            throw APIError.unknown(httpResponse.statusCode)
        }
    }
}

// MARK: - Helper Types

struct EmptyResponse: Decodable {}

struct ErrorResponse: Decodable {
    let error: String
}

private struct AnyEncodable: Encodable {
    private let value: any Encodable

    init(_ value: any Encodable) {
        self.value = value
    }

    func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}
