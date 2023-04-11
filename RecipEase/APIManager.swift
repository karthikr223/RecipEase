//
//  APIManager.swift
//  Fetch iOS Coding Challenge
//
//  Created by Karthik Rajagopalan on 4/9/23.
//

import Foundation
import UIKit

let OPEN_AI_API_KEY = "ENTER_OPEN_AI_API_KEY_HERE"

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
    
    ///Sends a request via OpenAI's ChatGPT API, using the input prompt.
    func requestChatGPT(prompt: String, completionHandler: @escaping (String) -> Void){
        //The API call is a POST request that takes the prompt and other parameters in the body.
        guard let openAIURL = URL(string: "https://api.openai.com/v1/chat/completions") else {return }
        let parameters: [String: Any] = [
            "model": "gpt-3.5-turbo",
            "messages": [
                ["role": "user",
                 "content": prompt],
            ],
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
        request.timeoutInterval = 30
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    //Parse the response JSON
                    if let dictionary = json as? [String: Any] {
                        for (key,_) in dictionary{
                            if key=="choices" {
                                guard let choices = dictionary[key] as? Array<Any> else {continue}
                                guard let firstChoice = choices[0] as? [String: Any] else {continue}
                                guard let message = firstChoice["message"] as? [String: Any] else {continue}
                                guard let content = message["content"] as? String else {continue}
                                
                                //Final output is a single string
                                let returnString = content.replacingOccurrences(of: "^\\s*", with: "", options: .regularExpression)
                                //Return the received generation
                                DispatchQueue.main.async {
                                    completionHandler(returnString)
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
