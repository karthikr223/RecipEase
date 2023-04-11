//
//  APIManager.swift
//  Fetch iOS Coding Challenge
//
//  Created by Karthik Rajagopalan on 4/9/23.
//

import Foundation
import UIKit

let OPEN_AI_API_KEY = "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"

class APIManager {
    static let shared = APIManager()
    
    ///Fetches the list of desserts.
    func getDessertList(completionHandler: @escaping ([Dessert]) -> Void){
        guard let dessertListURL = URL(string: "https://themealdb.com/api/json/v1/1/filter.php?c=Dessert") else {return }
        
        let task = URLSession.shared.dataTask(with: dessertListURL, completionHandler: { (data, response, error) in
            
            if error != nil {
              print("Error accessing dessert list")
              return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                
                if let dessertList = try? decoder.decode(DessertList.self, from: data) {
                    completionHandler(dessertList.results)
                }
            }
        })

        task.resume()
        
    }
    
    ///Fetches the details for a particular dessert, given its id. Returns an object containing the instructions and ingredients/measures.
    func getDessertDetails(id: String, completionHandler: @escaping (DessertDetails) -> Void){
        guard let url = URL(string: "https://themealdb.com/api/json/v1/1/lookup.php?i=" + id) else {return }
        
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
              print("Error accessing dessert details")
              return
            }
            
            if let data = data {
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(DessertDetailsResponse.self, from: data) {
                    if(response.results.count == 1){
                        completionHandler(response.results[0])
                    }
                }
            }
        })

        task.resume()
        
    }
    
    ///Fetches the thumbnail image for a particular dessert given its thumbnail URL.
    func getDessertImage(url: URL, completionHandler: @escaping (UIImage?) -> Void){
        let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
            
            if error != nil {
                //TODO: show alert on error
              print("Error accessing dessert list")
              return
            }
            
            if let data = data {
                let image = UIImage(data: data)
                completionHandler(image)
            }
        })
        
        task.resume()
    }
    
    ///Generates a short description using OpenAI's ChatGPT API, using a preconstructed prompt filled with the appropriate dessert name.
    func generateDessertDescription(dessert: Dessert, completionHandler: @escaping (String) -> Void){
        let prompt = "Write me two-line appealing descriptions of the following food items. The descriptions must be short as they will be used as a preview for the food item in a recipe app. Here are the food items:\n\nLemon Coconut Cake: Enjoy a flavor fusion of zesty lemon curd and sweet cream cheese, all sandwiched between layers of deliciously moist coconut cake - an irresistible treat for any special occasion!\n\nStrawberry Rhubarb Upside Down Cake: Enjoy the sweet and tart combination of succulent strawberries and tangy rhubarb atop a deliciously moist cake, all finished off with a luxurious caramel sauce!\n\nKaiserschmarrn: This classic Austrian dish of torn pancakes is made extra special with plump raisins soaked in rum, and your choice of delicious fruits as a topping - irresistible for breakfast, lunch or dinner.\n\n\(dessert.name):"

        guard let openAIURL = URL(string: "https://api.openai.com/v1/completions") else {return }
        let parameters: [String: Any] = [
          "model": "text-davinci-003",
          "prompt": prompt,
          "max_tokens": 50,
          "temperature": 0.9,
          "top_p": 1,
          "n": 1,
          "frequency_penalty": 0.65,
          "presence_penalty": 0,
          "stream": false,
        ]
        var request = URLRequest(url: openAIURL)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer " + OPEN_AI_API_KEY, forHTTPHeaderField: "Authorization")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else {
            return
        }
        request.httpBody = httpBody
        request.timeoutInterval = 20
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let dictionary = json as? [String: Any] {
                        for (key,_) in dictionary{
                            if key=="choices" {
                                if let choices = dictionary[key] as? Array<Any>{
                                    if let firstChoice = choices[0] as? [String: Any]{
                                        if let textCompletion = firstChoice["text"] as? String{
                                            let returnString = textCompletion.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
                                            DispatchQueue.main.async {
                                                completionHandler(returnString)
                                            }
    
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch {
                    print(error)
                    completionHandler("")
                    return
                }
            }
        }
        task.resume()
    }
}
