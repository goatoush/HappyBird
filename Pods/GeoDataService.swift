//
//  GeoDataService.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 7/7/23.
//

import Foundation

// MARK: Structs

struct Region: Codable, Equatable {
    let code: String!
    let name: String!
    var subregions: [Region]?
}

// MARK: Geo Data Service

class GeoDataService {
    
    // API Key
    let apiKey = "5kkpf1onaqj5"
    
    // Allowing access from other files
    static let shared = GeoDataService()
    
    // MARK: Init
    private init() {
        // Setting the regions list
    }
    
    // MARK: Variables
    var world = Region(code: "world", name: "World")
}
