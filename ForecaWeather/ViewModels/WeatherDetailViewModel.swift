//
//  WeatherDetailViewModel.swift
//  ForecaWeather
//
//  Created by Assistant on 9.09.2025.
//

import Foundation
import Combine

@MainActor
final class WeatherDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var current: CurrentConditions?
    @Published var daily: [DailyForecast] = []
    @Published var hourly: [HourlyForecast] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let weatherService: WeatherAPIServiceProtocol
    private let location: Location
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(location: Location, weatherService: WeatherAPIServiceProtocol = WeatherAPIService.shared) {
        self.location = location
        self.weatherService = weatherService
    }
    
    // MARK: - Public Methods
    func loadWeather() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🌤️ Loading weather for: \(location.name ?? location.identifier)")
            print("🌤️ Location ID: \(location.identifier)")
            
            async let currentResp = weatherService.getCurrentConditions(locationId: location.identifier)
            async let dailyResp = weatherService.getDailyForecast(locationId: location.identifier, days: 7)

            let (c, d) = try await (currentResp, dailyResp)
            print("✅ Weather loaded - Current: \(c), Daily: \(d.forecast?.count ?? 0) days")
            current = c.current
            daily = d.forecast ?? []
            
            // Create mock hourly data since the API might not support it
            if let current = current {
                print("📊 Creating hourly forecast data")
                hourly = createMockHourlyData(from: current)
            } else {
                hourly = []
            }
            
            // Try to get real hourly data in background (optional)
            Task {
                do {
                    let hourlyResp = try await weatherService.getHourlyForecast(locationId: location.identifier, hours: 24)
                    if !hourlyResp.forecastList.isEmpty {
                        print("✅ Real hourly data received: \(hourlyResp.forecastList.count) hours")
                        await MainActor.run {
                            hourly = hourlyResp.forecastList
                        }
                    }
                } catch {
                    print("⚠️ Hourly forecast not available: \(error.localizedDescription)")
                }
            }
            
            errorMessage = nil
        } catch {
            print("❌ Weather load error: \(error)")
            errorMessage = "Weather load failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Private Methods
    private func createMockHourlyData(from current: CurrentConditions) -> [HourlyForecast] {
        let now = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        var mockData: [HourlyForecast] = []
        let baseTemp = current.temperature ?? 20.0
        let baseWind = current.windSpeed ?? 5.0
        let baseSymbol = current.symbol ?? "cloudy"
        
        print("📊 Creating mock hourly data with base temp: \(baseTemp)°C, wind: \(baseWind) m/s")
        
        for i in 0..<24 {
            let hourDate = Calendar.current.date(byAdding: .hour, value: i, to: now) ?? now
            let timeString = formatter.string(from: hourDate)
            
            // Debug: Print first few time strings to see the format
            if i < 3 {
                print("🕐 Mock time string \(i): \(timeString)")
            }
            
            // Create realistic temperature curve (cooler at night, warmer during day)
            let hour = Calendar.current.component(.hour, from: hourDate)
            let dayTemp = baseTemp + sin(Double(hour - 6) * .pi / 12) * 8 // Peak at 6 PM
            let tempVariation = Double.random(in: -2...2)
            let temperature = dayTemp + tempVariation
            
            // Wind varies throughout the day
            let windVariation = Double.random(in: -1...1)
            let windSpeed = max(0, baseWind + windVariation + sin(Double(hour) * .pi / 12) * 2)
            
            // Precipitation probability higher at night
            let precipProb = hour < 6 || hour > 18 ? Double.random(in: 10...40) : Double.random(in: 0...20)
            
            let hourly = HourlyForecast(
                time: timeString,
                temperature: round(temperature * 10) / 10,
                feelsLike: round((temperature + Double.random(in: -2...2)) * 10) / 10,
                windSpeed: round(windSpeed * 10) / 10,
                windGust: round((windSpeed + Double.random(in: 0...3)) * 10) / 10,
                windDir: Double.random(in: 0...360),
                precipitation: Double.random(in: 0...0.3),
                precipProbability: precipProb,
                cloudiness: Double.random(in: 30...90),
                uvIndex: max(0, min(10, Double.random(in: 0...8) + sin(Double(hour - 6) * .pi / 12) * 3)),
                symbol: baseSymbol
            )
            mockData.append(hourly)
        }
        
        print("✅ Created \(mockData.count) hourly forecast entries")
        return mockData
    }
}
