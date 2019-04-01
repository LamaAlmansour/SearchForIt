//
//  Photo.swift
//  SearchForIt
//
//  Created by Lama on 23/01/2019.
//  Copyright © 2019 Lama. All rights reserved.
//

import Foundation

struct Photo {
    let id: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    
    var photoSquareUrl: URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_q.jpg")!
    }
    var photoLargeUrl: URL {
        return URL(string: "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret)_b.jpg")!
    }
    
}

extension Photo {
    init(json: [String: Any]) throws {

        guard let id = json["id"] as? String else {
            throw SerializationError.missing("id")
        }
        
        guard let secret = json["secret"] as? String else {
            throw SerializationError.missing("secret")
        }
        
        guard let server = json["server"] as? String else {
            throw SerializationError.missing("server")
        }
        
        guard let farm = json["farm"] as? Int else {
            throw SerializationError.missing("farm")
        }
        
        guard let title = json["title"] as? String else {
            throw SerializationError.missing("title")
        }
        
        self.id = id
        self.secret = secret
        self.server = server
        self.farm = farm
        self.title = title
    }
}

struct FlickrFail {
    let stat: String
    let code: Int
    let message: String
}

enum SerializationError: Error {
    case missing(String)
    case invalid(String, Any)
}

extension FlickrFail {
    init(json: [String: Any]) throws {

        guard let stat = json["stat"] as? String else {
            throw SerializationError.missing("stat")
        }
        
        guard let code = json["code"] as? Int else {
            throw SerializationError.missing("code")
        }
        
        guard let message = json["message"] as? String else {
            throw SerializationError.missing("message")
        }
        
        self.stat = stat
        self.code = code
        self.message = message
    }
}
