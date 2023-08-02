//
//  DataService.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/27/20.
//

import Foundation
import Alamofire

class DataService {
    
    static let shared = DataService()
    
    @discardableResult func request(_ urlString: String, headers: [String : String] = [:], duration: Int = 31556952,  completion: @escaping (_ data: Data?, _ URLRequest: URLRequest?) -> Void) ->  Alamofire.Request? {
        var req = URLRequest(url: URL(string: urlString.folding(options: .diacriticInsensitive, locale: .current))!)
        req.httpMethod = "GET"
        req.cachePolicy = NSURLRequest.CachePolicy.returnCacheDataElseLoad
        req.allHTTPHeaderFields = headers
        if let cachedData = URLCache.shared.cachedResponse(for: req) {
            completion(cachedData.data, req)
            if urlString.starts(with: "https://api.ebird.org/v2") {
                print("📗Success: \(urlString)")
            }
        }
        else {
            return AF.request(req).validate().response { response in
                guard
                    let res = response.response,
                    let data = response.data,
                    response.error == nil
                else {
                    print("📕Faliure: \(urlString)")
                    return completion(nil, nil)
                }
                let cachedURLResponse = CachedURLResponse(response: res, data: data, userInfo: nil, storagePolicy: .allowed).response(withExpirationDuration: duration)
                URLCache.shared.storeCachedResponse(cachedURLResponse, for: req)
                completion(data, req)
                if urlString.starts(with: "https://api.ebird.org/v2") {
                    print("📗Success: \(urlString)")
                }
            }
        }
        return nil
    }
    
    func clearCacheFor(request: URLRequest?) {
        if let request = request {
            URLCache.shared.removeCachedResponse(for: request)
        }
    }
    
    func clearAllCache() {
        URLCache.shared.removeAllCachedResponses()
    }
}
