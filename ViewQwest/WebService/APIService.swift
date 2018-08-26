//
//  APIService.swift
//  ViewQuestTask
//
//  Created by Satham Hussain on 8/24/18.
//  Copyright © 2018 Satham Hussain. All rights reserved.
//

import UIKit
typealias APICompletionHandler = (VQuestModel, Error?) -> Void

class APIService: NSObject {
    
    func getUserInfo(url : String,  completionBlock : @escaping APICompletionHandler) -> Void {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                // check for fundamental networking error
                print("error=\(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(String(describing: response))")
            }else{
                do {
                let jsonResult = try? JSONDecoder().decode(VQuestModel.self, from: data)
                completionBlock(jsonResult!, error)
                 } catch let jsonError{
                    print("some error \(jsonError)")
                    completionBlock(nil!, error)
                }
            }
        }
        task.resume()
    }

}
