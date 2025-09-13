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
                // Temperature Line Chart
                HourlyTemperatureChart(forecasts: forecasts)
                    .padding(.horizontal, 20)
                
                // Individual Hour Cards
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

// MARK: - Hourly Temperature Chart
struct HourlyTemperatureChart: View {
    let forecasts: [HourlyForecast]
    @State private var selectedIndex: Int? = nil
    
    private var chartData: [(time: String, temperature: Double, feelsLike: Double?)] {
        return forecasts.compactMap { forecast in
            guard let time = forecast.time,
                  let temperature = forecast.temperature else { return nil }
            return (time: timeString(from: time), temperature: temperature, feelsLike: forecast.feelsLike)
        }
    }
    
    private var minTemp: Double {
        let temps = chartData.map(\.temperature)
        return (temps.min() ?? 0) - 2 // Add some padding
    }
    
    private var maxTemp: Double {
        let temps = chartData.map(\.temperature)
        return (temps.max() ?? 0) + 2 // Add some padding
    }
    
    private var tempRange: Double {
        maxTemp - minTemp
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Temperature Trend")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if let selectedIndex = selectedIndex,
                   selectedIndex < chartData.count {
                    let data = chartData[selectedIndex]
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(Int(data.temperature))°")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        if let feelsLike = data.feelsLike {
                            Text("Feels like \(Int(feelsLike))°")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            if chartData.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    Text("No temperature data available")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(height: 140)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemGray6))
                )
            } else {
                VStack(spacing: 8) {
                    // Chart area
                    GeometryReader { geometry in
                        ZStack {
                            // Background gradient
                            LinearGradient(
                                colors: [Color.blue.opacity(0.05), Color.cyan.opacity(0.02)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .cornerRadius(8)
                            
                            // Grid lines
                            VStack(spacing: 0) {
                                ForEach(0..<5) { _ in
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(height: 1)
                                    Spacer()
                                }
                            }
                            
                            // Temperature area fill
                            if chartData.count > 1 {
                                Path { path in
                                    let width = geometry.size.width
                                    let height = geometry.size.height
                                    let stepX = width / CGFloat(max(1, chartData.count - 1))
                                    
                                    // Start from bottom left
                                    path.move(to: CGPoint(x: 0, y: height))
                                    
                                    for (index, data) in chartData.enumerated() {
                                        let x = CGFloat(index) * stepX
                                        let normalizedTemp = tempRange > 0 ? (data.temperature - minTemp) / tempRange : 0.5
                                        let y = height - (normalizedTemp * height)
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                    
                                    // Close the path to create filled area
                                    path.addLine(to: CGPoint(x: geometry.size.width, y: height))
                                    path.closeSubpath()
                                }
                                .fill(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.3), Color.cyan.opacity(0.1)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                            }
                            
                            // Temperature line
                            Path { path in
                                let width = geometry.size.width
                                let height = geometry.size.height
                                let stepX = width / CGFloat(max(1, chartData.count - 1))
                                
                                for (index, data) in chartData.enumerated() {
                                    let x = CGFloat(index) * stepX
                                    let normalizedTemp = tempRange > 0 ? (data.temperature - minTemp) / tempRange : 0.5
                                    let y = height - (normalizedTemp * height)
                                    
                                    if index == 0 {
                                        path.move(to: CGPoint(x: x, y: y))
                                    } else {
                                        path.addLine(to: CGPoint(x: x, y: y))
                                    }
                                }
                            }
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .cyan],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                            )
                            
                            // Temperature points
                            ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                                let x = CGFloat(index) * (geometry.size.width / CGFloat(max(1, chartData.count - 1)))
                                let normalizedTemp = tempRange > 0 ? (data.temperature - minTemp) / tempRange : 0.5
                                let y = geometry.size.height - (normalizedTemp * geometry.size.height)
                                
                                Circle()
                                    .fill(selectedIndex == index ? Color.blue : Color.white)
                                    .frame(width: selectedIndex == index ? 10 : 6, height: selectedIndex == index ? 10 : 6)
                                    .position(x: x, y: y)
                                    .overlay(
                                        Circle()
                                            .stroke(selectedIndex == index ? Color.blue : Color.blue.opacity(0.6), lineWidth: selectedIndex == index ? 3 : 2)
                                            .frame(width: selectedIndex == index ? 16 : 12, height: selectedIndex == index ? 16 : 12)
                                            .position(x: x, y: y)
                                    )
                                    .onTapGesture {
                                        withAnimation(.easeInOut(duration: 0.2)) {
                                            selectedIndex = selectedIndex == index ? nil : index
                                        }
                                    }
                            }
                        }
                    }
                    .frame(height: 120)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    )
                    
                    // X-axis labels (time)
                    HStack {
                        ForEach(Array(chartData.enumerated()), id: \.offset) { index, data in
                            if index % max(1, chartData.count / 6) == 0 || index == chartData.count - 1 {
                                Text(data.time)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                }
            }
        }
    }
    
    private func timeString(from timeString: String?) -> String {
        guard let timeString = timeString else { return "N/A" }
        
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
                return timeFormatter.string(from: date)
            }
        }
        
        if timeString.contains("T") {
            let components = timeString.components(separatedBy: "T")
            if components.count > 1 {
                let timePart = components[1]
                let timeComponents = timePart.components(separatedBy: ":")
                if timeComponents.count >= 2 {
                    return "\(timeComponents[0]):\(timeComponents[1])"
                }
            }
        }
        
        if timeString.contains(":") {
            return timeString
        }
        
        return "N/A"
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
