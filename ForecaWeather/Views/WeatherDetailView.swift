//
//  WeatherDetailView.swift
//  ForecaWeather
//
//  Created by Assistant on 9.09.2025.
//

import SwiftUI

struct WeatherDetailView: View {
    let location: Location
    @StateObject private var viewModel: WeatherDetailViewModel
    
    init(location: Location) {
        self.location = location
        self._viewModel = StateObject(wrappedValue: WeatherDetailViewModel(location: location))
    }
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.cyan.opacity(0.05)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Current Weather
                    if let current = viewModel.current {
                        CurrentWeatherCard(current: current, location: location)
                    } else if viewModel.isLoading {
                        LoadingWeatherView()
                    } else {
                        ErrorWeatherView(error: viewModel.errorMessage)
                    }
                    
                    // Daily Forecast
                    if !viewModel.daily.isEmpty {
                        DailyForecastSection(forecasts: viewModel.daily)
                    }
                    
                    // Hourly Forecast
                    if !viewModel.hourly.isEmpty {
                        HourlyForecastSection(forecasts: viewModel.hourly)
                    }
                }
                .padding(.vertical, 20)
            }
        }
        .navigationTitle(location.name ?? "Weather")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            Task {
                await viewModel.loadWeather()
            }
        }
    }
}

// MARK: - Loading Weather View
struct LoadingWeatherView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading weather data...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Error Weather View
struct ErrorWeatherView: View {
    let error: String?
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            Text("Unable to load weather data")
                .font(.headline)
            if let error = error {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    NavigationStack {
        WeatherDetailView(location: Location(
            id: 1,
            name: "Istanbul",
            country: "Turkey",
            timezone: "Europe/Istanbul",
            lat: 41.0082,
            lon: 28.9784,
            coordinates: nil
        ))
    }
}
