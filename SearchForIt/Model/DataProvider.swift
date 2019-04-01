//
//  DataProvider.swift
//  SearchForIt
//
//  Created by Lama on 23/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import Foundation

enum DataProviderError: Error {
    case serialization(String)
    case network(String)
    case fetching(FlickrFail)
}

class DataProvider {
    
    typealias FlickrResponse = (DataProviderError?, [Photo]?) -> Void
    
    class func fetchPhotos(searchText: String, section page: Int, onCompletion: @escaping FlickrResponse) {

        let replacement = searchText.replacingOccurrences(of: " ", with: "+")
        let escapedSearchText: String = replacement.addingPercentEncoding(withAllowedCharacters:.urlHostAllowed)!
        let urlString: String = "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(FlickrApiKeys.flickrKey)&tags=\(escapedSearchText)&per_page=25&page=\(page)&format=json&nojsoncallback=1"
        print("\(urlString)")
        let url: URL = URL(string: urlString)!
        
        let searchTask = URLSession.shared.dataTask(with: url) {data, response, error in
            
            if error != nil {
                print("Error fetching photos: \(error!.localizedDescription)")
                onCompletion(DataProviderError.network(error!.localizedDescription), nil)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any]
                guard let results = json else { return }
                
                if let stat = results["stat"] as? String {
                    switch stat {
                    case "ok":
                        var flickrPhotos2: [Photo] = []
                        
                        guard let photosContainerJSON = results["photos"] as? [String: Any] else { print("photosjson faild"); return }
                        
                        if let photosContainer2 = photosContainerJSON["photo"] as? [Any]
                        {
                            for case let photo in photosContainer2 {
                                if let flickrPhoto = try Photo(json: (photo as? [String : Any])!) as Photo?
                                {
                                    flickrPhotos2.append(flickrPhoto)
                                }
                            }
                            onCompletion(nil, flickrPhotos2)
                            
                        }
                        
                    default:
                        print("search fail")
                        let flickrError = try FlickrFail(json: json!)
                        onCompletion(DataProviderError.fetching(flickrError), nil)
                        return
                    }
                }
                
            } catch let error as NSError {
                print("Error parsing JSON: \(error)")
                onCompletion(DataProviderError.network("unkown error"), nil)
                return
            }
            
        }
        searchTask.resume()
    }
    
}
