//
//  BirdDataService.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/22/20.
//

import Foundation

// MARK: Structs
struct Bird: Codable, Equatable {
    let sciName: String
    let comName: String
    let speciesCode: String
    let category: String
    let taxonOrder: Int
    let bandingCodes: [String]
    let comNameCodes: [String]
    let sciNameCodes: [String]
    let order: String?
    var familyComName: String?
    var familySciName: String?
    let extinct: Bool?
    let extinctYear: Int?
    var subSpecies: [Bird]?
    var intergrades: [Bird]?
    var speciesGroupIndex: Int?
    let reportAs: String?
    var photos: [Photo]?
}

struct Family: Codable, Equatable {
    let groupName: String
    let groupOrder: Int
    let taxonOrderBounds: [[Int]]
    var birds: [Bird]?
    var hybrids: [Bird]?
}

struct Observation: Codable, Equatable {
    let speciesCode: String
    let comName: String
    let sciName: String
    let locId: String
    let locName: String
    let obsDt: String
    let howMany: Int?
    let lat: Float
    let lng: Float
    let obsValid: Bool
    let obsReviewed: Bool
    let locationPrivate: Bool
    let subId: String
}

// MARK: Bird Data Service
class BirdDataService {
    let apiKey = "5kkpf1onaqj5"

    static let shared = BirdDataService()
    
    // MARK: Initialization
    private init() {
        if UserDefaults.standard.float(forKey: "lat") != 0.0 {
            self.lat = UserDefaults.standard.float(forKey: "lat")
            self.lng = UserDefaults.standard.float(forKey: "lng")
        }
        if UserDefaults.standard.string(forKey: "placeName") != nil {
            self.placeName = UserDefaults.standard.string(forKey: "placeName")
        }
        fetchData { [self] in
            for i in 0..<families.count {
                let family = families[i]
                for taxonOrder in family.taxonOrderBounds[0][0]...family.taxonOrderBounds[0][1] {
                    taxonOrders[taxonOrder] = i
                    if taxonOrder == 216 {
                        print("\(family.groupName): \(i), \(taxonOrder), \(taxonOrders[taxonOrder] ?? -1)\n")
                    }
                }
            }
            print("bunny") // For testing
            
            // Edit Birds Array Here
            for i in 0..<birds.count {
                let bird = birds[i]
                birds[i].familyComName = birds[i].familyComName ?? ""
                birds[i].familySciName = birds[i].familySciName ?? ""
                
                if let familyIndex = taxonOrders[birds[i].taxonOrder] {
                    birds[i].speciesGroupIndex = familyIndex
                }
                
                // Filling up "birdsBySpeciesCode"
                birdsBySpeciesCode[bird.speciesCode] = bird
                
                // Adding Subspecies
                if bird.category == "issf" || bird.category == "form" {
                    if birdsBySpeciesCode[bird.reportAs ?? ""]?.subSpecies == nil {
                        birdsBySpeciesCode[bird.reportAs ?? ""]?.subSpecies = []
                    }
                    birdsBySpeciesCode[bird.reportAs ?? ""]?.subSpecies?.append(bird)
                } else if bird.category == "intergrade" {
                    if birdsBySpeciesCode[bird.reportAs ?? ""]?.intergrades == nil {
                        birdsBySpeciesCode[bird.reportAs ?? ""]?.intergrades = []
                    }
                    birdsBySpeciesCode[bird.reportAs ?? ""]?.intergrades?.append(bird)
                }
                
                // Adding birds to families
                if taxonOrders.count > bird.taxonOrder,
                      let j = taxonOrders[bird.taxonOrder]
                {
                    if !bird.comName.contains("sp.") {
                        if bird.category == "slash" || bird.category == "hybrid"  {
                            if families[j].hybrids == nil { families[j].hybrids = [] }
                            families[j].hybrids!.append(bird)
                        } else if bird.category == "species" || bird.category == "domestic" {
                            if families[j].birds == nil { families[j].birds = [] }
                            families[j].birds!.append(bird)
                        }
                    }
                }
            }
            
            // Adding Favorited & Seen Birds
            for bird in birds where UserDefaults.standard.bool(forKey: "isFavorited \(bird.sciName)") {
                favoritedBirds.append(bird)
            }
            favoritedBirds.sort { (lhs, rhs) -> Bool in lhs.comName < rhs.comName }
            for bird in birds where UserDefaults.standard.bool(forKey: "hasSeen \(bird.sciName)") {
                seenBirds.append(bird)
            }
            favoritedBirds.sort { (lhs, rhs) -> Bool in lhs.comName < rhs.comName }
            families = families.filter { $0.birds != nil }
            isReady = true
            for completion in onReadyHandlers {
                completion()
            }
            onReadyHandlers.removeAll()
        }
    }
    
    // MARK: Variables
    var birds: [Bird] = []
    var families: [Family] = []
    var taxonOrders: [Int: Int] = [:]
    let minSpecies = 1
    var isReady = false
    var onReadyHandlers: [() -> Void] = []
    var favoritedBirds: [Bird] = []
    var seenBirds: [Bird] = []
    var birdsBySpeciesCode: [String: Bird] = [:]
    var lat: Float?
    var lng: Float?
    var placeName: String?
    var observations: [Observation]?
    

    // MARK: Favorite & Seen
    func toggleFavorite(bird: Bird) -> Bool {
        var isFavorite = false
        if UserDefaults.standard.bool(forKey: "isFavorited \(bird.sciName)") {
            UserDefaults.standard.set(false, forKey: "isFavorited \(bird.sciName)")
            favoritedBirds = favoritedBirds.filter { $0 != bird }
        }
        else {
            UserDefaults.standard.set(true, forKey: "isFavorited \(bird.sciName)")
            favoritedBirds.append(bird)
            isFavorite = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "favoritesChanged"), object: nil)
        return isFavorite
    }
    
    func toggleSeen(bird: Bird) -> Bool {
        var hasSeen = false
        if UserDefaults.standard.bool(forKey: "hasSeen \(bird.sciName)") {
            UserDefaults.standard.set(false, forKey: "hasSeen \(bird.sciName)")
            seenBirds = seenBirds.filter { $0 != bird }
        }
        else {
            UserDefaults.standard.set(true, forKey: "hasSeen \(bird.sciName)")
            seenBirds.append(bird)
            hasSeen = true
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "seenChanged"), object: nil)
        return hasSeen
    }
    
    // MARK: Observations
    func getObservationsNearby(completion: @escaping () -> Void) {
        getData(endPoint: "data/obs/geo/recent?lat=\(String(format: "%.2f", lat!))&lng=\(String(format: "%.2f", lng!))&back=30") { (data, request) in
            print("something")
            if let data = data {
                do {
                    self.observations = try JSONDecoder().decode([Observation].self, from: data)
                    // print(self.observations?.count)
                }
                catch let error {
                    print(error)
                    DataService.shared.clearCacheFor(request: request)
                }
            }
            completion()
        }
    }
    
    func getObservationsBySpeciesCode(_ speciesCode: String, completion: @escaping (_ observation: [Observation]) -> Void) {
        var observations: [Observation] = []
        getData(endPoint: "data/obs/geo/recent/\(speciesCode)?lat=\(String(format: "%.2f", lat!))&lng=\(String(format: "%.2f", lng!))&back=30&dist=50&includeProvisional=true") { (data, request) in
            if let data = data {
                do {
                    observations = try JSONDecoder().decode([Observation].self, from: data)
                    completion(observations)
                }
                catch let error {
                    print(error)
                    DataService.shared.clearCacheFor(request: request)
                    completion([])
                }
            }
        }
    }

    // MARK: Data Management
    func onDataReady(completion: @escaping () -> Void) {
        if isReady {
            completion()
        }
        else {
            onReadyHandlers.append(completion)
        }
    }

    func fetchData(completion: @escaping () -> Void) {
        var canComplete = false
        getData(endPoint: "ref/taxonomy/ebird?fmt=json") { (data, request) in
            if let data = data {
                do {
                    self.birds = try JSONDecoder().decode([Bird].self, from: data)
                    print(self.birds.count)
                    
                    if canComplete {
                        completion()
                    }
                    else {
                        canComplete = true
                    }
                }
                catch let error {
                    print(error)
                    DataService.shared.clearCacheFor(request: request)
                }
            }
        }
        getData(endPoint: "ref/sppgroup/merlin?fmt=json") { (data, request) in
            if let data = data {
                do {
                    let families = try JSONDecoder().decode([Family].self, from: data)
                    self.families = families.filter {
                        $0.groupName != "Others"
                        && $0.taxonOrderBounds[0][1] -                         $0.taxonOrderBounds[0][0] >= self.minSpecies
                    }
                    
                    if canComplete {
                        completion()
                    }
                    else {
                        canComplete = true
                    }
                }
                catch let error {
                    print(error)
                    DataService.shared.clearCacheFor(request: request)
                }
            }
        }
    }
    
    func getData(endPoint: String, completion: @escaping (_ data: Data?, _ request: URLRequest?) -> Void) {
        print("📘Starting: \(endPoint)")
        DataService.shared.request("https://api.ebird.org/v2/\(endPoint)", headers: ["X-eBirdApiToken": self.apiKey], completion: completion)
    }
    
    // Useless
    func getDataOld(endPoint: String, completion: @escaping (_ data: Data?) -> Void) {
        var urlRequest = URLRequest(url: URL(string: "https://api.ebird.org/v2/ref/\(endPoint)?fmt=json")!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-eBirdApiToken": self.apiKey
        ]
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let error = error {
                print(error)
                completion(nil)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
                print(1)
                completion(nil)
                return
            }
            guard let mimeType = httpResponse.mimeType, mimeType == "application/json" else {
                print(2)
                completion(nil)
                return
            }
            completion(data)
        }
        task.resume()
    }

}
