//
//  ViewController.swift
//  JournalApp
//
//  Created by Milos Petrusic on 8.6.21..
//

import UIKit

struct Post: Decodable {
    let id: Int
    let title: String
    let body: String
}

class ViewController: UITableViewController {
    
    var posts = [Post]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchPosts()
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Posts"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create Post", style: .plain, target: self, action: #selector(handleCreatePost))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(handleLogin))
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let post = posts[indexPath.row]
        cell.textLabel?.text = post.title
        cell.detailTextLabel?.text = post.body
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            print("Deleting post")
            let post = self.posts[indexPath.row]
            Service.shared.deletePost(id: post.id, completion: { error in
                if let error = error {
                    print("Failed to delete: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    print("Successfully deleted post from server.")
                    self.posts.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }
            })
        }
    }
    
    fileprivate func fetchPosts() {
        Service.shared.fetchPosts { result in
            switch result {
            case .failure(let error):
                print("error fetching posts: \(error) ")
            case .success(let posts):
                self.posts = posts
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    @objc fileprivate func handleCreatePost() {
        
        print("Creating new post...")
        Service.shared.createPost(title: "IOS TITLE", body: "IOS POST BODY", completion: { error in
            if let error = error {
                print("Failed to create post: \(error)")
                return
            }
            
            print("Finished creating post!")
            self.fetchPosts()
        })
        
    }
    
    fileprivate func attemptLogin(email: String, password: String) {
        print("Started logging in")
        
        guard let url = URL(string: "http://localhost:1440/api/v1/entrance/login") else { return }
        
        var loginRequest = URLRequest(url: url)
        loginRequest.httpMethod = "PUT"
        
        do {
            let params = ["emailAddress": email, "password": password]
            loginRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: .init())
            
            URLSession.shared.dataTask(with: loginRequest, completionHandler: { [weak self] data, response, error in
                if let error = error {
                    print("Failed to login: \(error)")
                    return
                }
                
                print("Logged in successfully")
                self?.fetchPosts()
            }).resume()
        } catch {
            print("Failed to serialize data: \(error)")
        }
    }
    
    @objc fileprivate func handleLogin() {
        let ac = UIAlertController(title: "Login", message: nil, preferredStyle: .alert)
        ac.addTextField(configurationHandler: nil)
        ac.addTextField(configurationHandler: nil)
        
        ac.addAction(UIAlertAction(title: "Login", style: .default, handler: { [weak self] _ in
            let email = ac.textFields![0].text!
            let password = ac.textFields![1].text!
            self?.attemptLogin(email: email, password: password)
            print(email)
            print(password)
        }))

        present(ac, animated: true)
        
    }


}

