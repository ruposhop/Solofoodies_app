//
//  APIError.swift
//  Solofoodies
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case unauthorized
    case forbidden
    case notFound
    case serverError(String)
    case decodingError(Error)
    case networkError(Error)
    case unknown(Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "URL invalida")
        case .invalidResponse:
            return String(localized: "Respuesta invalida del servidor")
        case .unauthorized:
            return String(localized: "Sesion expirada. Inicia sesion de nuevo")
        case .forbidden:
            return String(localized: "No tienes permiso para esta accion")
        case .notFound:
            return String(localized: "Recurso no encontrado")
        case .serverError(let message):
            return message
        case .decodingError:
            return String(localized: "Error procesando datos")
        case .networkError:
            return String(localized: "Error de conexion. Verifica tu internet")
        case .unknown(let code):
            return String(localized: "Error desconocido (codigo: \(code))")
        }
    }
}
