//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by admin on 9/17/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit
import AlamofireImage

class HomeTableViewController: UITableViewController {

    var tweetArray = [NSDictionary]()
    var numberOfTweets: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pullTweets()
        
        myRefreshControl.addTarget(self, action: #selector(pullTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    @objc func pullTweets() {
        
        numberOfTweets = 20
        let resourceUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let resourceUrlParams = ["count": numberOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: resourceUrl, parameters: resourceUrlParams as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("Could not retrieve tweets in pullTweets()")
        })
    }
    
    func pullMoreTweets() {
        numberOfTweets = numberOfTweets + 20
        
        let resourceUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let resourceUrlParams = ["count": numberOfTweets]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: resourceUrl, parameters: resourceUrlParams as [String : Any], success: { (tweets: [NSDictionary]) in
            
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            self.tableView.reloadData()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets in pullMoreTweets()")
        })
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            pullMoreTweets()
        }
    }

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        
        let tweet = tweetArray[indexPath.row]
        
        let user = tweet["user"] as! NSDictionary
        cell.userName.text = user["name"] as? String ?? ""
        cell.userId.text = "@\(user["screen_name"] as? String ?? "")"
        cell.tweetText.text = tweet["text"] as? String ?? ""
        cell.retweetCount.text = String(tweet["retweet_count"] as! Int)
        cell.favCount.text = String(tweet["favorite_count"] as! Int)
        
        if let profilePhotoUrlString = user["profile_image_url_https"] as? String {
            let profilePhotoUrl = URL(string: profilePhotoUrlString)!
            cell.profilePhoto.af_setImage(withURL: profilePhotoUrl)
            cell.profilePhoto.layer.cornerRadius = cell.profilePhoto.frame.size.width / 2
        }
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweetArray.count
    }
}
