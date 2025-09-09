//
//  WeatherSearchViewModel.swift
//  ForecaWeather
//
//  Created by Assistant on 9.09.2025.
//

import Foundation
import Combine

@MainActor
final class WeatherSearchViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var locations: [Location] = []
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private let weatherService: WeatherAPIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(weatherService: WeatherAPIServiceProtocol = WeatherAPIService.shared) {
        self.weatherService = weatherService
        setupBindings()
    }
    
    // MARK: - Public Methods
    func search() async {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔍 Searching for: \(searchText)")
            let result = try await weatherService.searchLocations(query: searchText, limit: 10)
            print("✅ Search result: \(result)")
            locations = result.locationList
            errorMessage = nil
        } catch {
            print("❌ Search error: \(error)")
            errorMessage = "Search failed: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func clearSearch() {
        searchText = ""
        locations = []
        errorMessage = nil
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Clear locations when search text changes
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .sink { [weak self] newValue in
                if newValue.isEmpty {
                    self?.locations = []
                    self?.errorMessage = nil
                }
            }
            .store(in: &cancellables)
    }
}
