//
//  UserDetailsVC.swift
//  NewAssignmentMindbowser
//
//  Created by Affixus-Mac-5 on 24/08/18.
//  Copyright © 2018 Lovina. All rights reserved.
//

import UIKit
import SDWebImage
import TwitterKit
import TwitterCore

class UserDetailsVC: UIViewController {
    
    
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbScreenName: UILabel!
    @IBOutlet weak var btFollowing: UIButton!
    @IBOutlet weak var btFollower: UIButton!
    
    var userId:String?
    var userScreenname:String?
    var userName:String?
    var image_url:String?
    
    static let tCol =  UIColor(red: 0, green:172/255, blue:237/255, alpha: 1)

    @IBAction func btFollwingAction(_ sender: Any) {
        let followerVC =  self.storyboard?.instantiateViewController(withIdentifier: "ListFriend") as! ListOfFriendsViewController
        followerVC.userId = userId
        followerVC.userScreenname = userScreenname
        navigationController?.pushViewController(followerVC, animated: true)
    }
    
    @IBAction func btFollowerAction(_ sender: Any) {
        
        let followerVC =  self.storyboard?.instantiateViewController(withIdentifier: "ListFriend") as! ListOfFriendsViewController
        followerVC.isFollower = true
        followerVC.userId = userId
        followerVC.userScreenname = userScreenname
        navigationController?.pushViewController(followerVC, animated: true)
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Home"
        self.lbName.text = userName
        self.lbScreenName.text = "@" + userScreenname!
        self.userImgView.sd_setImage(with: URL(string: self.image_url!))
        let bordercolor = UIColor(red: 31.0/255.0, green: 137.0/255.0, blue: 183.0/255.0, alpha: 1.0)
        self.userImgView.layer.borderColor = bordercolor.cgColor
        self.userImgView.layer.borderWidth = 0.5
        self.userImgView.layer.cornerRadius = self.userImgView.layer.frame.width / 2
        self.userImgView.layer.masksToBounds = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        callForFollowerList()
        callForFollowingList()
    }
}

extension UserDetailsVC {
    
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
                    self.btFollower.setTitle(String(followerList.count)+" followers", for: .normal)
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
                    self.btFollowing.setTitle(String(followerList.count)+" followings", for: .normal)
                }
            } catch let jsonError as NSError {
                print("json error: \(jsonError.localizedDescription)")
            }
        }
    }
}
