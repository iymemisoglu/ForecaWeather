//
//  WeatherSearchView.swift
//  ForecaWeather
//
//  Created by Assistant on 9.09.2025.
//

import SwiftUI

struct WeatherSearchView: View {
    @StateObject private var viewModel = WeatherSearchViewModel()
    
    var body: some View {
        NavigationStack {
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
                        // Search Section
                        SearchSectionView(viewModel: viewModel)
                        
                        // Search Results
                        if !viewModel.locations.isEmpty {
                            SearchResultsView(locations: viewModel.locations)
                        }
                        
                        // Welcome message when no search results
                        if viewModel.locations.isEmpty && !viewModel.isLoading && viewModel.searchText.isEmpty {
                            WelcomeView()
                        }
                    }
                    .padding(.vertical, 20)
                }
            }
            .navigationTitle("Weather")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Search Section View
struct SearchSectionView: View {
    @ObservedObject var viewModel: WeatherSearchViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search for a city...", text: $viewModel.searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit { 
                            Task { await viewModel.search() } 
                        }
                    
                    // Clear button
                    if !viewModel.searchText.isEmpty {
                        Button(action: {
                            viewModel.clearSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16))
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                Button(action: { 
                    Task { await viewModel.search() } 
                }) {
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
                .disabled(viewModel.searchText.isEmpty || viewModel.isLoading)
            }
            
            if viewModel.isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Searching...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.red)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(.horizontal, 20)
    }
}

// MARK: - Search Results View
struct SearchResultsView: View {
    let locations: [Location]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Search Results")
                .font(.headline)
                .padding(.horizontal, 20)
            
            LazyVStack(spacing: 8) {
                ForEach(locations) { location in
                    NavigationLink(destination: WeatherDetailView(location: location)) {
                        LocationCard(location: location) {
                            // Navigation will handle the tap
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Welcome View
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "cloud.sun.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("Welcome to Weather")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Search for a city to see weather information")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .padding(.horizontal, 20)
    }
}

// MARK: - Location Card
struct LocationCard: View {
    let location: Location
    let action: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(location.name ?? "Unknown City")
                    .font(.headline)
                    .foregroundColor(.primary)
                if let country = location.country {
                    Text(country)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
                .font(.caption)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    WeatherSearchView()
}
