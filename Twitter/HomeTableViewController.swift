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
//        self.tableView.rowHeight = UITableView.automaticDimension
//        self.tableView.estimatedRowHeight = 150
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        pullTweets()
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
            print("Could not retrieve tweets in pullTweets() :\(Error)")
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
            print("Could not retrieve tweets in pullMoreTweets() :\(Error)")
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
        
        cell.tweetId = tweet["id"] as! Int
        cell.setFavourited(tweet["favorited"] as! Bool)
        cell.setRetweeted(tweet["retweeted"] as! Bool)
        
        let date = tweetArray[indexPath.row]["created_at"] as? String
        cell.tweetDate.text = getDate(dateString: date!)!.timeAgoSinceDate()
        
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
    
    func getDate(dateString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E MMM d HH:mm:ss Z yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: dateString) // replace Date String
    }
    
}

extension Date {
    func timeAgoSinceDate() -> String {
        // From Time
        let fromDate = self
        // To Time
        let toDate = Date()
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "y ago" : "\(interval)" + " " + "y ago"
        }
        // Month
        if let interval = Calendar.current.dateComponents([.month], from: fromDate, to: toDate).month, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "m ago" : "\(interval)" + " " + "m ago"
        }
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "d ago" : "\(interval)" + " " + "d ago"
        }
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "h ago" : "\(interval)" + " " + "h ago"
        }
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            return interval == 1 ? "\(interval)" + " " + "min ago" : "\(interval)" + " " + "min ago"
        }
        return "a moment ago"
    }
}
