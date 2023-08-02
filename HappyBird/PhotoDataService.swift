//
//  PhotoDataService.swift
//  HappyBird
//
//  Created by Utshaho Gupta on 12/22/20.
//

import Foundation
import UIKit

struct Photos: Codable, Equatable {
    let photos: Page
    let stat: String
}

struct Page: Codable, Equatable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: Int
    let photo: [Photo]
}

struct Photo: Codable, Equatable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
}

class PhotoDataService {
    let apiKey = "90fc5f3b016731f7d4ca50c1ac4bfb0a"

//    let dontUse = [
//        "https://live.staticflickr.com/65535/50721161696_90533b9eed.png",
//        "https://live.staticflickr.com/65535/50718272257_3dd0d084ef.png",
//        "https://live.staticflickr.com/65535/50720467976_37c20ff44b.png",
//        "https://live.staticflickr.com/65535/50432066741_a334bb7dc6.png",
//        "https://live.staticflickr.com/65535/50329244796_132136cdd8.png",
//        "https://live.staticflickr.com/8075/8316147109_7f3c65d8a8.png",
//        "https://live.staticflickr.com/4576/38442715702_3c5776fcf3.png",
//        "https://live.staticflickr.com/4180/33664971934_c1c0c50285.png",
//        "https://live.staticflickr.com/4089/4970856358_d3078a00d4.png",
//        "https://live.staticflickr.com/3093/3197863478_48c71d57d5.png",
//        "https://live.staticflickr.com/1837/43024390874_86e2b12416.png",
//        "https://live.staticflickr.com/3048/2879813032_ecee45d7e4.png",
//        "https://live.staticflickr.com/846/27781006578_e015b4b1ec.png",
//        "https://live.staticflickr.com/7201/13197683534_cd2a408ece.png",
//        "https://live.staticflickr.com/1747/28690683118_1e956a36b2.png",
//        "https://live.staticflickr.com/7221/6978500262_e2c3ca7284.png",
//        "https://live.staticflickr.com/65535/48997941677_97d4119bbb.png",
//        "https://live.staticflickr.com/3875/15045956301_234d20a533.png",
//        "https://live.staticflickr.com/1933/44822783174_85734e6dea.png",
//        "https://live.staticflickr.com/7533/15560751814_bbe1af125c.png",
//        "https://live.staticflickr.com/813/27097884338_5337834a94.png",
//        "https://live.staticflickr.com/6120/6286405706_1d132a68be.png",
//        "https://live.staticflickr.com/4643/25297389038_f1800f753c.png",
//        "https://live.staticflickr.com/65535/46741264285_1df2fb724d.png",
//        "https://live.staticflickr.com/1868/43827620635_3a9e5e62d7.png",
//        "https://live.staticflickr.com/4517/38143729011_34d0f8c9d0.png",
//        "https://live.staticflickr.com/4127/4963440246_243e491313.png",
//        "https://live.staticflickr.com/1838/43886683551_507e37d1b8.png",
//        "https://live.staticflickr.com/4133/4963440410_9723de63ba.png",
//        "https://live.staticflickr.com/928/43190350774_e3f741c953.png",
//        "https://live.staticflickr.com/4343/36558817204_3879587e0d.png",
//        "https://live.staticflickr.com/4052/4427167819_26a5526a7f.png",
//        "https://live.staticflickr.com/3749/19499880325_6a91e6f920.png",
//        "https://live.staticflickr.com/8402/8623122757_2fa8f9d8e6.png",
//        "https://live.staticflickr.com/3213/3787028824_cb046c16cf.png",
//        "https://live.staticflickr.com/5204/5222341224_296b132fd7.png",
//        "https://live.staticflickr.com/3447/3786219629_ac40d760db.png",
//        "https://live.staticflickr.com/3716/11886430106_b758c2c927.png",
//        "https://live.staticflickr.com/2532/3787030498_8547c1b6d2.png",
//        "https://live.staticflickr.com/8104/8655737267_301cdd0261.png",
//        "https://live.staticflickr.com/65535/49988767087_1ff3a7ee57.png",
//        "https://live.staticflickr.com/8731/16803296500_3c11b3ffd3.png",
//        "https://live.staticflickr.com/7895/46393101915_7e86d1d5ab.png",
//        "https://live.staticflickr.com/65535/50762320207_fa1d48847c.png",
//        "https://live.staticflickr.com/65535/50218283041_d9e476b003.png",
//        "https://live.staticflickr.com/7524/27543713075_f491583271.png",
//        "https://live.staticflickr.com/951/41335816884_f7f9b54b82.png",
//        "https://live.staticflickr.com/7597/16990712425_cc96a84f2b.png",
//        "https://live.staticflickr.com/2086/2090041382_83535253e3.png",
//        "https://live.staticflickr.com/4336/36663835402_1343238afb.png", // Birds-of-paradise
//    ]
//
//    let searchBySciNamesIfTaxonOrderInThisList = [
//        16721,
//    ]
//
//    let urlsForSpecies = [
//        25332: "https://live.staticflickr.com/1724/42161959544_89a48639f3.png",
//        16721: "https://live.staticflickr.com/65535/49444692571_006b82b523.png",
//    ]
    
    static let shared = PhotoDataService()

    func getPhotoURLs(birds: [Bird], size: String? = nil, format: String = "png", completion: @escaping (_ urlStrings: [String], _ titles: [String]) -> Void) {
        searchImages(birds) { photos in
            guard var photos = photos else { return completion([], []) }
//            photos = photos.filter {
//                !self.dontUse.contains("https://live.staticflickr.com/\($0.server)/\($0.id)_\($0.secret).png")
//            }
            completion(photos.map {
                "https://live.staticflickr.com/\($0.server)/\($0.id)_\($0.secret)\(size != nil ? "_\(size!)" : "").\(format)"
            }, photos.map { $0.title })
        }
    }

    func getPhotoURL(birds: [Bird], size: String? = nil, format: String = "png", customDontUse: [String] = [], completionHandler: @escaping (_ urlString: String?) -> Void) {
//        if birds.count > 0, let url = urlsForSpecies[birds[0].taxonOrder] {
//            completionHandler(url)
//        }
        searchImages(birds) { photos in
            var URLString: String
            var photo: Photo? = nil
            if let photos = photos, photos.count > 0 {
                for i in Array(0..<photos.count) {
                    let urlString = "https://live.staticflickr.com/\(photos[i].server)/\(photos[i].id)_\(photos[i].secret).png"
                    if /* !self.dontUse.contains(urlString) && */ !customDontUse.contains(urlString) {
                        photo = photos[i]
                        break
                    }
                }
                if photo == nil {
                    return completionHandler(nil)
                }
            }
            else {
                return completionHandler(nil)
            }
            if size == nil {
                URLString = "https://live.staticflickr.com/\(photo!.server)/\(photo!.id)_\(photo!.secret).\(format)"
            }
            else {
                URLString = "https://live.staticflickr.com/\(photo!.server)/\(photo!.id)_\(photo!.secret)_\(size!).\(format)"
            }
            completionHandler(URLString)
        }
    }

    func getPhoto(bird: Bird, size: String?, format: String?, weak imageView: UIImageView!) {
        var URLString: String
        var imageFormat = "png"
        let photos = search(bird.sciName)
        var photo: Photo
        if let photos = photos {
            photo = photos[0]
        }
        else {
            return
        }
        
        if format != nil {
            imageFormat = format!
        }
        
        if size == nil {
            URLString = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).\(imageFormat)"
        }
        else {
            URLString = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size!).\(imageFormat)"
        }
        
        let url = URL(string: URLString)
        
        if let data = try? Data(contentsOf: url!) {
            if let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView?.image = img
                }
            }
        }
    }
    
    func getPhoto(comName: String, size: String?, format: String?, weak imageView: UIImageView!) {
        var URLString: String
        var imageFormat = "png"
        let photos = search(comName)
        var photo: Photo
        if let photos = photos {
            photo = photos[0]
        }
        else {
            return
        }
        
        if format != nil {
            imageFormat = format!
        }
        
        if size == nil {
            URLString = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret).\(imageFormat)"
        }
        else {
            URLString = "https://live.staticflickr.com/\(photo.server)/\(photo.id)_\(photo.secret)_\(size!).\(imageFormat)"
        }
        
        let url = URL(string: URLString)
        
        if let data = try? Data(contentsOf: url!) {
            if let img = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView?.image = img
                }
            }
        }
    }
    
    func searchWithOption(_ urlString: String, searchOptions: [String], withOptionIndex index: Int = 0, completion: @escaping (_ photos: [Photo]?) -> Void, onFailure: @escaping () -> Void) {
        let url = urlString
            .replacingOccurrences(of: "text=", with: searchOptions[index])
            .replacingOccurrences(of: " ", with: "%20")
        DataService.shared.request(url) { data, request in
            if let data = data {
                do {
                    let photos = try JSONDecoder().decode(Photos.self, from: data)
                    if photos.photos.photo.count > 0 {
                        return completion(photos.photos.photo)
                    }
                }
                catch let error {
                    print(error)
                    DataService.shared.clearCacheFor(request: request)
                    return completion(nil)
                }
//                if let photos = try? JSONDecoder().decode(Photos.self, from: data) {
//                    if photos.photos.photo.count > 0 {
//                        return completion(photos.photos.photo)
//                    }
//                }
//                else {
//                    DataService.shared.clearCacheFor(request: request)
//                }
            }
            if index < searchOptions.count - 1 {
                return self.searchWithOption(urlString, searchOptions: searchOptions, withOptionIndex: index + 1, completion: completion, onFailure: onFailure)
            }
            onFailure()
        }
    }
 
    func searchImages(_ birds: [Bird], withIndex index: Int = 0, completion: @escaping (_ photos: [Photo]?) -> Void) {
        guard birds.count > index else {
            return completion(nil)
        }
        let text = birds[index].sciName
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .folding(options: .diacriticInsensitive, locale: .current)
        // if searchBySciNamesIfTaxonOrderInThisList.contains(birds[index].taxonOrder) {
        //     text = birds[index].sciName
        // }
        // text = text.replacingOccurrences(of: "(", with: "")
        //     .replacingOccurrences(of: ")", with: "")
        //     .folding(options: .diacriticInsensitive, locale: .current)
        // if let index = text.firstIndex(of: "(") {
        //     let firstPart = text.prefix(upTo: index)
        //     text = String(firstPart)
        // }
        let searchOptions = [
            "text=\(text) bird photo&tags=birdshare,telephoto,closeup,bird,wildlife,nature",
            "text=\(text) bird photo"
        ]
        let urlString = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(self.apiKey)&text=&sort=relevance&privacy_filter=1&content_type=1&media=photos&safe_search=1&content_type=1&format=json&nojsoncallback=1"
        self.searchWithOption(urlString, searchOptions: searchOptions, completion: completion) {
            self.searchImages(birds, withIndex: index + 1, completion: completion)
        }
    }

    func search(_ searchTerm: String) -> [Photo]? {
        let search = searchTerm.replacingOccurrences(of: " ", with: "%20")
        
        do {
            let data = try Data(contentsOf: URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(self.apiKey)&text=\(search)&safe_search=1&content_type=1&license=1,2,3,4,5,6,7,9,10&format=json&nojsoncallback=1")!)
            
            let photos = try JSONDecoder().decode(Photos.self, from: data)
            
            // print("https://live.staticflickr.com/\(photos.photos.photo[0].server)/\(photos.photos.photo[0].id)_\(photos.photos.photo[0].secret).png")
            
            return photos.photos.photo
        }
        catch let error {
            print("photo search", searchTerm, error)
        }
        
        return nil
    }
}
