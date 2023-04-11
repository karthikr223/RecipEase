//
//  DessertDetails.swift
//  Fetch iOS Coding Challenge
//
//  Created by Karthik Rajagopalan on 4/9/23.
//

import Foundation

///A struct to hold the relevant details for a particular dessert (all the data that is displayed in the details view).
struct DessertDetails: Decodable {
    var name = ""
    var instructions = ""
    var ingredients: [IngredientListItem] = []
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.instructions = try container.decode(String.self, forKey: .instructions)
        self.ingredients = []
        
        //the API returns 20 fields each of ingredients and measures (which may be empty or null as well). This function parses the JSON and saves the non-null values to an array.
        for i in 1...21 {
            guard let ingredientKey = CodingKeys(stringValue: "strIngredient" + String(i)) else {
                return
            }
            guard let measureKey = CodingKeys(stringValue: "strMeasure" + String(i)) else {
                return
            }
            
            guard let currentIngredient = try container.decode(String?.self, forKey: ingredientKey)
            else {
                continue
            }
            guard let currentMeasure = try container.decode(String?.self, forKey: measureKey) else {
                continue
            }
            
            if(currentIngredient == "" || currentMeasure == ""){
                continue
            }
            
            self.ingredients.append(IngredientListItem(ingredient: currentIngredient, measure: currentMeasure))
        }
    }
    
    ///Creates a string of all the ingredients that can also be used as a description in the home screen UITableView. Can be used
    ///instead of calling the ChatGPT API for better performance.
    func getIngredientsDisplayString() -> String {
        let displayString = ingredients.map({$0.ingredient.lowercased()}).joined(separator: ", ")
        return displayString
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "idMeal"
        case instructions = "strInstructions"
        
        case strIngredient1, strIngredient2, strIngredient3, strIngredient4, strIngredient5, strIngredient6, strIngredient7, strIngredient8, strIngredient9, strIngredient10, strIngredient11, strIngredient12, strIngredient13, strIngredient14, strIngredient15, strIngredient16, strIngredient17, strIngredient18, strIngredient19, strIngredient20
        
        case strMeasure1, strMeasure2, strMeasure3, strMeasure4, strMeasure5, strMeasure6, strMeasure7, strMeasure8, strMeasure9, strMeasure10, strMeasure11, strMeasure12, strMeasure13, strMeasure14, strMeasure15, strMeasure16, strMeasure17, strMeasure18, strMeasure19, strMeasure20
    }
}

///A struct to hold the JSON response from the dessert details API.
struct DessertDetailsResponse: Decodable {
    var results: [DessertDetails]
    
    enum CodingKeys: String, CodingKey {
        case results = "meals"
    }
}

///A struct to hold each ingredient in a recipe and its respective measure.
struct IngredientListItem {
    var ingredient = ""
    var measure = ""
}
