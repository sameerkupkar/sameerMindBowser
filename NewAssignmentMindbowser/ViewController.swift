//
//  ViewController.swift
//  NewAssignmentMindbowser
//
//  Created by Lovina on 17/08/18.
//  Copyright © 2018 Lovina. All rights reserved.
//

import UIKit
import TwitterKit
import TwitterCore


class ViewController: UIViewController {
    
    
    
    var activityIndicator = UIActivityIndicatorView()
    let effectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    var strLabel = UILabel()
    
    @IBOutlet weak var MainImage: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        //  activityIndicator("Pleas Wait......")
        
        self.MainImage.layer.borderWidth = 0.5
        self.MainImage.layer.cornerRadius = self.MainImage.layer.frame.width / 2
        self.MainImage.layer.masksToBounds = true
        
        
        let logInButton = TWTRLogInButton(logInCompletion: { session, error in
            if (session != nil) {
                print("signed in as \(String(describing: session?.userName))");
                
                let twitterClient = TWTRAPIClient(userID: session?.userID)
                twitterClient.loadUser(withID: (session?.userID)!, completion: { (user, error) in

                    if error == nil {
                        
                        (UIApplication.shared.delegate as! AppDelegate).openUserDetailVC(userName: user!.name, image_url: user!.profileImageLargeURL, userScreenname: user!.screenName, userId: user!.userID)

                    }
                })
                
                
                
            } else {
                print("error: \(String(describing: error?.localizedDescription))");
                self.activityIndicator.stopAnimating()
                let alert = UIAlertController(title: "", message: "Please Check Twitter App is Install OR Try again please", preferredStyle: UIAlertControllerStyle.alert)
                self.present(alert, animated: true, completion: nil)
                let when = DispatchTime.now() + 3
                DispatchQueue.main.asyncAfter(deadline: when){
                    alert.dismiss(animated: true, completion: nil)
                }
                
            }
        })
        logInButton.center = self.view.center
        self.view.addSubview(logInButton)
        
        
        
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func activityIndicator(_ title: String) {
        
        strLabel.removeFromSuperview()
        activityIndicator.removeFromSuperview()
        effectView.removeFromSuperview()
        
        strLabel = UILabel(frame: CGRect(x: 50, y: 0, width: 160, height: 46))
        strLabel.text = title
        strLabel.font = .systemFont(ofSize: 14, weight: .medium)
        strLabel.textColor = UIColor(white: 0.9, alpha: 0.7)
        
        effectView.frame = CGRect(x: view.frame.midX - strLabel.frame.width/2, y: view.frame.midY - strLabel.frame.height/2 , width: 160, height: 46)
        effectView.layer.cornerRadius = 15
        effectView.layer.masksToBounds = true
        
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 46, height: 46)
        activityIndicator.startAnimating()
        
        effectView.contentView.addSubview(activityIndicator)
        effectView.contentView.addSubview(strLabel)
        view.addSubview(effectView)
    }
}

class User:Hashable {
    
    var hashValue: Int{
        return (id_str!.hashValue)
    }
    
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id_str == rhs.id_str
    }
    
    var name:String?
    var image_url:String?
    var screen_name:String?
    var description:String?
    var id_str:String?
    
    init(name:String?,image_url:String?,screen_name:String?) {
        self.name = name
        self.image_url = image_url
        self.screen_name = "@"+screen_name!
        
    }
}

