//
//  WeatherModels.swift
//  ForecaWeather
//
//  Created by Assistant on 9.09.2025.
//

import Foundation

// MARK: - Location Models
struct LocationSearchResponse: Codable {
    let locations: [Location]?
    let data: [Location]?
    let results: [Location]?
    let items: [Location]?
    
    var locationList: [Location] {
        return locations ?? data ?? results ?? items ?? []
    }
}

struct Location: Codable, Identifiable {
    let id: Int?
    let name: String?
    let country: String?
    let timezone: String?
    let lat: Double?
    let lon: Double?
    let coordinates: Coordinates?
    
    var identifier: String {
        return id?.description ?? ""
    }

    struct Coordinates: Codable {
        let lat: Double?
        let lon: Double?
        let latitude: Double?
        let longitude: Double?
        
        var latitudeValue: Double? {
            return lat ?? latitude
        }
        
        var longitudeValue: Double? {
            return lon ?? longitude
        }
    }
    
    var latitude: Double? {
        return lat ?? coordinates?.latitudeValue
    }
    
    var longitude: Double? {
        return lon ?? coordinates?.longitudeValue
    }
}

// MARK: - Current Weather Models
struct CurrentConditionsResponse: Codable {
    let current: CurrentConditions?
}

struct CurrentConditions: Codable {
    let temperature: Double?
    let feelsLike: Double?
    let windSpeed: Double?
    let windDirection: Int?
    let humidity: Int?
    let symbol: String?
    let symbolPhrase: String?
    let time: String?
    let pressure: Double?
    let dewPoint: Double?
    let visibility: Double?
    let uvIndex: Double?
    let cloudiness: Double?
    let precipitation1h: Double?

    enum CodingKeys: String, CodingKey {
        case temperature
        case feelsLike
        case windSpeed
        case windDirection
        case humidity
        case symbol
        case symbolPhrase
        case time
        case pressure
        case dewPoint
        case visibility
        case uvIndex
        case cloudiness
        case precipitation1h = "precipitation"
    }
}

// MARK: - Daily Forecast Models
struct DailyForecastResponse: Codable {
    let forecast: [DailyForecast]?
}

struct DailyForecast: Codable, Identifiable {
    var id: String { date ?? UUID().uuidString }

    let date: String?
    let maxTemp: Double?
    let minTemp: Double?
    let symbol: String?
    let symbolPhrase: String?
    let precipitationProbability: Int?
    let windSpeed: Double?
    let windDirection: Int?
    let precipitation: Double?
    let sunrise: String?
    let sunset: String?

    enum CodingKeys: String, CodingKey {
        case date
        case maxTemp
        case minTemp
        case symbol
        case symbolPhrase
        case precipitationProbability
        case windSpeed
        case windDirection
        case precipitation
        case sunrise
        case sunset
    }
}

// MARK: - Hourly Forecast Models
struct HourlyForecastResponse: Codable {
    let forecast: [HourlyForecast]?
    let data: [HourlyForecast]?
    let hourly: [HourlyForecast]?
    let hours: [HourlyForecast]?
    
    var forecastList: [HourlyForecast] {
        return forecast ?? data ?? hourly ?? hours ?? []
    }
}

struct HourlyForecast: Codable, Identifiable {
    var id: String { time ?? UUID().uuidString }

    let time: String?
    let temperature: Double?
    let feelsLike: Double?
    let windSpeed: Double?
    let windGust: Double?
    let windDir: Double?
    let precipitation: Double?
    let precipProbability: Double?
    let cloudiness: Double?
    let uvIndex: Double?
    let symbol: String?

    enum CodingKeys: String, CodingKey {
        case time
        case temperature
        case feelsLike
        case windSpeed
        case windGust
        case windDir
        case precipitation
        case precipProbability
        case cloudiness
        case uvIndex
        case symbol
    }
}

// MARK: - Warning Models
struct WarningsResponse: Codable {
    let warnings: [Warning]
}

struct Warning: Codable, Identifiable {
    var id: String { (type ?? "") + (validFrom ?? "") + (validUntil ?? "") }

    let type: String?
    let significance: String?
    let validFrom: String?
    let validUntil: String?
    let description: [WarningText]?

    struct WarningText: Codable {
        let lang: String?
        let text: String?
    }
}

// MARK: - Marine Forecast Models
struct MarineDailyForecastResponse: Codable {
    let forecast: [MarineDailyForecast]
}

struct MarineDailyForecast: Codable, Identifiable {
    var id: String { date }

    let date: String
    let maxSigWaveHeight: Double?
    let maxSeaTemp: Double?
}
