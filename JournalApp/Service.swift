//
//  Service.swift
//  JournalApp
//
//  Created by Milos Petrusic on 10.6.21..
//

import Foundation

class Service: NSObject {
    static let shared = Service()
    
    let baseUrl = "http://localhost:1440"
    
    func fetchPosts(completion: @escaping (Result<[Post], Error>) -> ()) {
        guard let url = URL(string: "\(baseUrl)/home") else { return }
        
        var fetchPostRequest = URLRequest(url: url)
        fetchPostRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                print("Unable to fetch data", error)
                return
            }
            
            guard let data = data else { return }
            
            //            print(String(data: data, encoding: .utf8) ?? "")
            
            do {
                let posts = try JSONDecoder().decode([Post].self, from: data)
                completion(.success(posts))
            } catch {
                completion(.failure(error))
            }
            
        }).resume()
    }
    
    func createPost(title: String, body: String, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "\(baseUrl)/post") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        
        let params = ["title": title, "body": body]
        do {
            let data = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            urlRequest.httpBody = data
            urlRequest.setValue("application/json", forHTTPHeaderField: "content-type")
            
            URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
                if let error = error {
                    completion(error)
                    return
                }
                
                completion(nil)
            }).resume()
        } catch {
            completion(error)
        }
    }
    
    func deletePost(id: Int, completion: @escaping (Error?) -> ()) {
        guard let url = URL(string: "\(baseUrl)/post/\(id)") else { return }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: urlRequest, completionHandler: { data, response, error in
            if let error = error {
                completion(error)
                return
            }
            
            if let response = response as? HTTPURLResponse, response.statusCode != 200 {
                let errorString = String(data: data ?? Data(), encoding: .utf8) ?? ""
                completion(NSError(domain: "",
                                   code: response.statusCode,
                                   userInfo: [NSLocalizedDescriptionKey: errorString]))
            }
            
//            guard let data = data else { return }
            completion(nil)
        }).resume()
    }
}
