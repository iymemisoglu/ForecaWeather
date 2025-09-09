//
//  WeatherAPIService.swift
//  ForecaWeather
//
//  Created by Assistant on 9.09.2025.
//

import Foundation

protocol WeatherAPIServiceProtocol {
    func searchLocations(query: String, limit: Int?) async throws -> LocationSearchResponse
    func getCurrentConditions(locationId: String) async throws -> CurrentConditionsResponse
    func getDailyForecast(locationId: String, days: Int?) async throws -> DailyForecastResponse
    func getHourlyForecast(locationId: String, hours: Int?) async throws -> HourlyForecastResponse
}

final class WeatherAPIService: WeatherAPIServiceProtocol {
    static let shared = WeatherAPIService()
    
    private let baseURL = URL(string: "https://pfa.foreca.com/api/v1")!
    private let urlSession: URLSession
    private let apiToken: String
    
    init(session: URLSession = .shared) {
        self.urlSession = session
        self.apiToken = Self.getAPIToken()
    }
    
    private static func getAPIToken() -> String {
        // Try reading from Info.plist first (from .xcconfig)
        if let token = Bundle.main.object(forInfoDictionaryKey: "FORECA_API_TOKEN") as? String,
           !token.isEmpty {
            return token
        }
        
        // Fallback: read directly from Config.xcconfig file
        if let configPath = Bundle.main.path(forResource: "Config", ofType: "xcconfig"),
           let configContent = try? String(contentsOfFile: configPath) {
            let lines = configContent.components(separatedBy: .newlines)
            for line in lines {
                if line.hasPrefix("FORECA_API_TOKEN") {
                    let components = line.components(separatedBy: "=")
                    if components.count > 1 {
                        let token = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        if !token.isEmpty {
                            return token
                        }
                    }
                }
            }
        }
        
        print("⚠️ FORECA_API_TOKEN not found in Config.xcconfig")
        return ""
    }
    
    // MARK: - Public Methods
    
    func searchLocations(query: String, limit: Int? = nil) async throws -> LocationSearchResponse {
        let url = baseURL.appendingPathComponent("location/search").appendingPathComponent(query)
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        if let limit { queryItems.append(URLQueryItem(name: "limit", value: String(limit))) }
        components.queryItems = queryItems
        let request = try makeRequest(url: try validatedURL(from: components))
        
        return try await perform(request)
    }
    
    func getCurrentConditions(locationId: String) async throws -> CurrentConditionsResponse {
        let url = baseURL.appendingPathComponent("current").appendingPathComponent(locationId)
        let request = try makeRequest(url: url)
        return try await perform(request)
    }
    
    func getDailyForecast(locationId: String, days: Int? = nil) async throws -> DailyForecastResponse {
        var components = URLComponents(url: baseURL.appendingPathComponent("forecast/daily").appendingPathComponent(locationId), resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        if let days { queryItems.append(URLQueryItem(name: "days", value: String(days))) }
        if !queryItems.isEmpty { components.queryItems = queryItems }
        let request = try makeRequest(url: try validatedURL(from: components))
        return try await perform(request)
    }
    
    func getHourlyForecast(locationId: String, hours: Int? = nil) async throws -> HourlyForecastResponse {
        // Try different possible endpoint structures
        let possibleEndpoints = [
            "forecast/hourly/\(locationId)",
            "forecast/hourly/\(locationId)/hourly",
            "forecast/\(locationId)/hourly",
            "hourly/\(locationId)"
        ]
        
        for endpoint in possibleEndpoints {
            do {
                var components = URLComponents(url: baseURL.appendingPathComponent(endpoint), resolvingAgainstBaseURL: false)!
                var queryItems: [URLQueryItem] = []
                if let hours { queryItems.append(URLQueryItem(name: "hours", value: String(hours))) }
                if !queryItems.isEmpty { components.queryItems = queryItems }
                let request = try makeRequest(url: try validatedURL(from: components))
                
                let result: HourlyForecastResponse = try await perform(request)
                print("✅ Successfully loaded hourly forecast from \(endpoint)")
                return result
            } catch {
                print("❌ Failed to load from \(endpoint): \(error)")
                continue
            }
        }
        
        throw WeatherAPIError.endpointNotFound
    }
    
    // MARK: - Private Methods
    
    private func makeRequest(url: URL) throws -> URLRequest {
        guard !apiToken.isEmpty else {
            throw WeatherAPIError.missingToken
        }
        
        // Add token as query parameter
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        var queryItems = components.queryItems ?? []
        queryItems.append(URLQueryItem(name: "token", value: apiToken))
        components.queryItems = queryItems
        
        guard let finalURL = components.url else {
            throw WeatherAPIError.invalidURL
        }
        
        var request = URLRequest(url: finalURL)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
    
    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await urlSession.data(for: request)
        try validate(response: response, data: data)
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("❌ JSON Decoding Error: \(error)")
            print("❌ Expected type: \(T.self)")
            throw WeatherAPIError.decodingFailed(error)
        }
    }
    
    private func validate(response: URLResponse, data: Data) throws {
        guard let http = response as? HTTPURLResponse else { return }
        guard (200...299).contains(http.statusCode) else {
            let message = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw WeatherAPIError.httpError(http.statusCode, message)
        }
    }
    
    private func validatedURL(from components: URLComponents) throws -> URL {
        guard let url = components.url else {
            throw WeatherAPIError.invalidURL
        }
        return url
    }
}

// MARK: - Weather API Errors

enum WeatherAPIError: LocalizedError {
    case missingToken
    case invalidURL
    case endpointNotFound
    case httpError(Int, String)
    case decodingFailed(Error)
    
    var errorDescription: String? {
        switch self {
        case .missingToken:
            return "API token is missing. Please check your configuration."
        case .invalidURL:
            return "Invalid URL format."
        case .endpointNotFound:
            return "Hourly forecast endpoint not found."
        case .httpError(let code, let message):
            return "HTTP Error \(code): \(message)"
        case .decodingFailed(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        }
    }
}
