//
//  Pixabay.swift
//  collView
//
//  Created by Jack Sp@rroW on 11/04/2019.
//  Copyright © 2019 Jack Sp@rroW. All rights reserved.
//

import Foundation

struct PixabayJson: Codable {
    let totalHits: Int
    let hits: [ImageInfo]
    let total: Int
}

struct ImageInfo: Codable {
    let largeImageURL: String
    let webformatHeight: Int
    let webformatWidth: Int
    let likes: Int
    let imageWidth: Int
    let id: Int
    let user_id: Int
    let views: Int
    let comments: Int
    let pageURL: String
    let imageHeight: Int
    let webformatURL:String
    let type: String
    let previewHeight: Int
    let tags: String
    let downloads: Int
    let user: String
    let favorites: Int
    let imageSize: Int
    let previewWidth: Int
    let userImageURL: String
    let previewURL: String
}


//class ImageInfoParser: IParser {
//    typealias Model = [ImageInfo]
//    func parse(data: Data) -> [ImageInfo]? {
//        let json = try JSONDecoder().decode(Model.self, from: data)
//    }
//    var imagesInfo: [ImageInfo] = []
//    // как-то парсим
//    return imagesInfo
//}

protocol IParser {
    associatedtype Model
    func parse(data: Data) -> Model?
}

protocol IRequest {
        var urlRequest: URLRequest? { get }
}
