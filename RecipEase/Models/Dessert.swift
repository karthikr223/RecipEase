//
//  Dessert.swift
//  Fetch iOS Coding Challenge
//
//  Created by Karthik Rajagopalan on 4/9/23.
//

import Foundation
import UIKit


///A class to store the data for each dessert to be displayed in the home screen table view.
class Dessert: Decodable {
    
    var name = ""
    var thumbnailURL = ""
    var image: UIImage?
    var details: DessertDetails?
    var description: String?
    var id = ""
    
    enum CodingKeys: String, CodingKey {
        case name = "strMeal"
        case thumbnailURL = "strMealThumb"
        case id = "idMeal"
    }
    
    ///Uses the dessert details endpoint to get the ingredients, measures and instructions.
    func getDetails(completionHandler: @escaping (DessertDetails?) -> Void) {
        if details != nil {
            DispatchQueue.main.async {
                completionHandler(self.details)
            }
        }
        else {
            APIManager.shared.getDessertDetails(id: self.id) {(fetchedDetails) in
                self.details = fetchedDetails
                DispatchQueue.main.async {
                    completionHandler(fetchedDetails)
                }
            }
        }
    }
    
    ///Uses the ChatGPT endpoint to get a quick description for the dessert.
    func getGPTDescription(completionHandler: @escaping (String?) -> Void) {
        if description != nil {
            DispatchQueue.main.async {
                completionHandler(self.description)
            }
        }
        else {
            APIManager.shared.generateDessertDescription(dessert: self) {(fetchedDescription) in
                self.description = fetchedDescription
                DispatchQueue.main.async {
                    completionHandler(fetchedDescription)
                }
            }
        }
    }
}

///A struct to capture the JSON response array.
struct DessertList: Decodable {
    var results: [Dessert]
    
    enum CodingKeys: String, CodingKey {
        case results = "meals"
    }
}
