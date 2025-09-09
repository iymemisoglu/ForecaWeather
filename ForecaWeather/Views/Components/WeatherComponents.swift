//
//  WeatherComponents.swift
//  ForecaWeather
//
//  Created by Assistant on 9.09.2025.
//

import SwiftUI

// MARK: - Current Weather Card
struct CurrentWeatherCard: View {
    let current: CurrentConditions
    let location: Location
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(location.name ?? "Unknown")
                        .font(.title2)
                        .fontWeight(.bold)
                    if let country = location.country {
                        Text(country)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                WeatherIcon(symbol: current.symbol)
                    .font(.system(size: 50))
            }
            
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("\(Int(current.temperature ?? 0))°")
                        .font(.system(size: 48, weight: .thin))
                        .foregroundColor(.primary)
                    
                    if let feelsLike = current.feelsLike {
                        Text("Feels like \(Int(feelsLike))°")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    WeatherDetailRow(icon: "humidity", value: "\(current.humidity ?? 0)%", label: "Humidity")
                    WeatherDetailRow(icon: "wind", value: "\(Int(current.windSpeed ?? 0)) m/s", label: "Wind")
                    if let pressure = current.pressure {
                        WeatherDetailRow(icon: "barometer", value: "\(Int(pressure)) hPa", label: "Pressure")
                    }
                }
            }
        }
        .padding(20)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 20)
    }
}

// MARK: - Weather Detail Row
struct WeatherDetailRow: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 16)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Daily Forecast Section
struct DailyForecastSection: View {
    let forecasts: [DailyForecast]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("7-Day Forecast")
                .font(.headline)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(forecasts) { forecast in
                        DailyForecastCard(forecast: forecast)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

// MARK: - Daily Forecast Card
struct DailyForecastCard: View {
    let forecast: DailyForecast
    
    var body: some View {
        VStack(spacing: 8) {
            Text(dayOfWeek(from: forecast.date))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            WeatherIcon(symbol: forecast.symbol)
                .font(.title2)
            
            VStack(spacing: 2) {
                Text("\(Int(forecast.maxTemp ?? 0))°")
                    .font(.headline)
                    .fontWeight(.semibold)
                Text("\(Int(forecast.minTemp ?? 0))°")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let precip = forecast.precipitationProbability {
                Text("\(precip)%")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func dayOfWeek(from dateString: String?) -> String {
        guard let dateString = dateString else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let date = formatter.date(from: dateString) else { return "N/A" }
        
        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "E"
        return dayFormatter.string(from: date)
    }
}

// MARK: - Hourly Forecast Section
struct HourlyForecastSection: View {
    let forecasts: [HourlyForecast]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("24-Hour Forecast")
                    .font(.headline)
                Spacer()
                Text("\(forecasts.count) hours")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            
            if forecasts.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "clock")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("Hourly forecast not available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(20)
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .padding(.horizontal, 20)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        ForEach(forecasts) { forecast in
                            HourlyForecastCard(forecast: forecast)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }
}

// MARK: - Hourly Forecast Card
struct HourlyForecastCard: View {
    let forecast: HourlyForecast
    
    var body: some View {
        VStack(spacing: 8) {
            Text(timeString(from: forecast.time))
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            WeatherIcon(symbol: forecast.symbol)
                .font(.title3)
            
            Text("\(Int(forecast.temperature ?? 0))°")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 12)
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
    
    private func timeString(from timeString: String?) -> String {
        guard let timeString = timeString else { 
            print("🕐 Time string is nil")
            return "N/A" 
        }
        
        print("🕐 Parsing time string: '\(timeString)'")
        
        // Try multiple date formats
        let dateFormats = [
            "yyyy-MM-dd'T'HH:mm:ss",
            "yyyy-MM-dd'T'HH:mm:ss.SSS",
            "yyyy-MM-dd'T'HH:mm:ss'Z'",
            "yyyy-MM-dd HH:mm:ss",
            "HH:mm:ss",
            "HH:mm"
        ]
        
        for format in dateFormats {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            if let date = formatter.date(from: timeString) {
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let result = timeFormatter.string(from: date)
                print("🕐 Successfully parsed with format '\(format)': \(result)")
                return result
            }
        }
        
        // If all parsing fails, try to extract time from string
        if timeString.contains("T") {
            let components = timeString.components(separatedBy: "T")
            if components.count > 1 {
                let timePart = components[1]
                let timeComponents = timePart.components(separatedBy: ":")
                if timeComponents.count >= 2 {
                    let result = "\(timeComponents[0]):\(timeComponents[1])"
                    print("🕐 Extracted time from T format: \(result)")
                    return result
                }
            }
        }
        
        // Last resort: return the original string if it looks like a time
        if timeString.contains(":") {
            print("🕐 Using original string as time: \(timeString)")
            return timeString
        }
        
        print("🕐 Failed to parse time, returning N/A")
        return "N/A"
    }
}

// MARK: - Weather Icon
struct WeatherIcon: View {
    let symbol: String?
    
    var body: some View {
        Group {
            if let symbol = symbol {
                Image(systemName: weatherIconName(for: symbol))
                    .foregroundColor(weatherIconColor(for: symbol))
            } else {
                Image(systemName: "questionmark.circle")
                    .foregroundColor(.gray)
            }
        }
    }
    
    private func weatherIconName(for symbol: String) -> String {
        switch symbol.lowercased() {
        case "sunny", "clear":
            return "sun.max.fill"
        case "partly_cloudy", "partly cloudy":
            return "cloud.sun.fill"
        case "cloudy", "overcast":
            return "cloud.fill"
        case "rain", "rainy":
            return "cloud.rain.fill"
        case "snow", "snowy":
            return "cloud.snow.fill"
        case "thunderstorm", "storm":
            return "cloud.bolt.fill"
        case "fog", "mist":
            return "cloud.fog.fill"
        default:
            return "cloud.fill"
        }
    }
    
    private func weatherIconColor(for symbol: String) -> Color {
        switch symbol.lowercased() {
        case "sunny", "clear":
            return .yellow
        case "partly_cloudy", "partly cloudy":
            return .orange
        case "cloudy", "overcast":
            return .gray
        case "rain", "rainy":
            return .blue
        case "snow", "snowy":
            return .white
        case "thunderstorm", "storm":
            return .purple
        case "fog", "mist":
            return .gray
        default:
            return .blue
        }
    }
}
