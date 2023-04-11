//
//  ImageCache.swift
//  Fetch iOS Coding Challenge
//
//  Created by Karthik Rajagopalan on 4/9/23.
//

import Foundation
import UIKit

///A class that manages the cache of download imags.
class ImageCache {
    static let shared = ImageCache()

    private let cache = NSCache<NSURL, UIImage>()

    ///This function first checks the cache to check if the image is already present and returns it if it is. If not, it
    ///downloads the image from the url, returns it and caches it.
    func getImage(url: URL, completionHandler: @escaping (UIImage?) -> Void) {
        
        //Check cache
        if let cachedImage = self.cache.object(forKey: url as NSURL)  {
            DispatchQueue.main.async {
                completionHandler(cachedImage)
            }
            return
        }
        
        //Call fetch image API.
        APIManager.shared.getDessertImage(url: url) { (image) in
            guard let img = image else {
                return
            }
            DispatchQueue.main.async {
                completionHandler(img)
            }
            self.cache.setObject(img, forKey: url as NSURL)
        }
    }
}

