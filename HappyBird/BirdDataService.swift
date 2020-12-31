//
//  BirdDataService.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/22/20.
//

import Foundation

struct Bird: Codable, Equatable {
    let sciName: String
    let comName: String
    let speciesCode: String
    let category: String
    let taxonOrder: Int
    let bandingCodes: [String]
    let comNameCodes: [String]
    let sciNameCodes: [String]
    let order: String
    let familyComName: String?
    let familySciName: String?
    let extinct: Bool?
}

struct Family: Codable, Equatable {
    let groupName: String
    let groupOrder: Int
    let taxonOrderBounds: [[Int]]
    var birds: [Bird]?
}

class BirdDataService {
    let apiKey = "5kkpf1onaqj5"

    static let shared = BirdDataService()
    
    private init() {
        fetchData { [self] in
            for i in 0..<families.count {
                let family = families[i]
                if taxonOrders.count <= family.taxonOrderBounds[0][1] {
                    for _ in taxonOrders.count...family.taxonOrderBounds[0][1] {
                        taxonOrders.append(nil)
                    }
                }
                for taxonOrder in family.taxonOrderBounds[0][0]...family.taxonOrderBounds[0][1] {
                    taxonOrders[taxonOrder] = i
                }
            }
            for i in 0..<birds.count {
                let bird = birds[i]
                if taxonOrders.count > bird.taxonOrder,
                      let j = taxonOrders[bird.taxonOrder]
                {
                    if !excludeBirdSpecies.contains(bird.taxonOrder) {
                        if !bird.comName.contains("sp.") {
                            if families[j].birds == nil { families[j].birds = [] }
                            families[j].birds!.append(bird)
                        }
                    }
                }
            }
            taxonOrders.removeAll()
            for bird in birds where UserDefaults.standard.bool(forKey: "isFavorited \(bird.sciName)") {
                favoritedBirds.append(bird)
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
    
    var birds: [Bird] = []
    var families: [Family] = []
    var taxonOrders: [Int?] = []
    let minSpecies = 1
    var isReady = false
    var onReadyHandlers: [() -> Void] = []
    var favoritedBirds: [Bird] = []
    
    // Extinct
    let familiesToExclude: [String] = [
        "Hawaiian Honeyeaters",
        "Others"
    ]
    let excludeBirdSpecies: [Int] = [
        12549,
    ]
    
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
        getData(endPoint: "taxonomy/ebird") { (data, request) in
            // print("taxonomy/ebird")
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
        getData(endPoint: "sppgroup/merlin") { (data, request) in
            // print("sppgroup/merlin")
            if let data = data {
                do {
                    let families = try JSONDecoder().decode([Family].self, from: data)
                    self.families = families.filter {
                        !self.familiesToExclude.contains($0.groupName)
                        && $0.taxonOrderBounds[0][1] -                         $0.taxonOrderBounds[0][0] >= self.minSpecies
                    }
                    // print(self.families.count, self.families[0].groupName)
                    
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
        DataService.shared.request("https://api.ebird.org/v2/ref/\(endPoint)?fmt=json", headers: ["X-eBirdApiToken": self.apiKey], completion: completion)
    }
    
    func getDataOld(endPoint: String, completion: @escaping (_ data: Data?) -> Void) {
        var urlRequest = URLRequest(url: URL(string: "https://api.ebird.org/v2/ref/\(endPoint)?fmt=json")!, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 10)
        urlRequest.allHTTPHeaderFields = [
            "Content-Type": "application/json",
            "Accept": "application/json",
            "X-eBirdApiToken": self.apiKey
        ]
        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                // print("task completion")
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
