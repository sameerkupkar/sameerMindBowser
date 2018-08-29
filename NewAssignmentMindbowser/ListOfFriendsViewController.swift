//
//  ListOfFriendsViewController.swift
//  NewAssignmentMindbowser
//
//  Created by Lovina on 22/08/18.
//  Copyright © 2018 Lovina. All rights reserved.
//

import UIKit
import SDWebImage
import TwitterKit
import TwitterCore

class ListOfFriendsViewController: UIViewController{
    
    var userId : String?
    var userScreenname:String?
    var userList = [User]()
    var isFollower:Bool = false
    
    @IBOutlet weak var friendTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        friendTable.dataSource = self
        friendTable.delegate = self
        friendTable.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isFollower {
            self.title = "Followers"
            callForFollowerList()
        }else {
            self.title = "Followings"
            callForFollowingList()
        }
        
    }
    
    @IBAction func BackBTN(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
        
    }
}

extension ListOfFriendsViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = userList[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let userImageView:UIImageView = cell.viewWithTag(101) as! UIImageView
        let lbName = cell.viewWithTag(102) as! UILabel
        let lbScreen_name = cell.viewWithTag(103) as! UILabel
        let lbStatus = cell.viewWithTag(104) as! UILabel
        
        
        
        lbName.text = data.name
        lbScreen_name.text = data.screen_name
        lbStatus.text = data.description
        //let Item = selectedImageArray[indexPath.row] as! String
        
        let newString = data.image_url?.replacingOccurrences(of: "_normal", with: "")
        
        userImageView.sd_setImage(with: URL(string: newString!) , placeholderImage: UIImage(named: "userdefult"))
        
        userImageView.layer.cornerRadius = 5
        
        let bordercolor = UIColor(red: 31.0/255.0, green: 137.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        userImageView.layer.borderColor = bordercolor.cgColor
        userImageView.layer.borderWidth = 0.5
        userImageView.layer.cornerRadius = userImageView.layer.frame.width / 2
        userImageView.layer.masksToBounds = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 93
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let needToFetchNewData = indexPath.row + 5 == userList.count
        
        if needToFetchNewData {
            if isFollower {
                callForFollowerList()
            }else {
                callForFollowingList()
            }
        }
        
    }
}

extension ListOfFriendsViewController {
    
    func callForFollowerList(){
        
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/followers/list.json"
        let params = [
            "user_id": userId,
            "screen_name": userScreenname, "cursor": "-1", "count": "20", "skip_status": "false", "include_user_entities": "true"
        ]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError ?? "" as! Error)")
            }
            
            do {
                
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let followerList = json["users"] as? [[String: Any]] {
                    let tempSet = Set<User>(self.userList)
                    for i in followerList {
                        let user = User(name:i["name"] as? String, image_url: i["profile_image_url_https"] as? String, screen_name: i["screen_name"] as? String)
                        user.description = i["description"] as? String
                        user.id_str = i["id_str"] as? String
                        
                        if tempSet.contains(user) {
                            return
                        }
                        self.userList.append(user)
                    }

                    DispatchQueue.main.async {
                        self.friendTable.reloadData()
                    }
                }
                
                
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
        
        
    }
    
    func callForFollowingList()  {
        
        
        let client = TWTRAPIClient()
        let statusesShowEndpoint = "https://api.twitter.com/1.1/friends/list.json"
        let params = [
            "user_id": userId,
            "screen_name": userScreenname, "cursor": "-1", "count": "20", "skip_status": "false", "include_user_entities": "true"
        ]
        var clientError : NSError?
        
        let request = client.urlRequest(withMethod: "GET", urlString: statusesShowEndpoint, parameters: params, error: &clientError)
        
        client.sendTwitterRequest(request) { (response, data, connectionError) -> Void in
            if connectionError != nil {
                print("Error: \(connectionError ?? "" as! Error)")
            }
            
            do {
                if let data = data,
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                    let followerList = json["users"] as? [[String: Any]] {
                    let tempSet = Set<User>(self.userList)
                    for i in followerList {
                        let user = User(name:i["name"] as? String, image_url: i["profile_image_url_https"] as? String, screen_name: i["screen_name"] as? String)
                        user.description = i["description"] as? String
                        user.id_str = i["id_str"] as? String
                        
                        if tempSet.contains(user) {
                            return
                        }
                        
                        self.userList.append(user)
                    }
                    DispatchQueue.main.async {
                        self.friendTable.reloadData()
                    }
                    
                }
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
            
            
            
        }
    }
}
