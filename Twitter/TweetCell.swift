//
//  TweetCell.swift
//  Twitter
//
//  Created by admin on 9/17/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class TweetCell: UITableViewCell {

    @IBOutlet weak var profilePhoto: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userId: UILabel!
    @IBOutlet weak var tweetText: UILabel!
    @IBOutlet weak var tweetDate: UILabel!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCount: UILabel!
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet weak var favCount: UILabel!
    @IBOutlet weak var elapsedTime: UILabel!
    
    var tweetId:Int = -1
    var favourited:Bool = false
    var retweeted:Bool = false
    
    func setFavourited(_ isFavourited:Bool) {
        favourited = isFavourited
        if (favourited) {
            favButton.setImage(UIImage(named: "favor-icon-red"), for: UIControl.State.normal)
        } else {
            favButton.setImage(UIImage(named: "favor-icon"), for: UIControl.State.normal)
        }
    }
    
    func setRetweeted(_ isRetweeted:Bool) {
        retweeted = isRetweeted
        if (retweeted) {
            retweetButton.setImage(UIImage(named: "retweet-icon-green"), for: UIControl.State.normal)
        } else {
            retweetButton.setImage(UIImage(named: "retweet-icon"), for: UIControl.State.normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func retweet(_ sender: Any) {
        let toBeRetweeted = !retweeted
        if (toBeRetweeted) {
            TwitterAPICaller.client?.reTweet(tweetId: tweetId, success: {
                self.setRetweeted(true)
            }, failure: { (error) in
                print("Retweet unsuccessful: \(error)")
            })
        } else {
            TwitterAPICaller.client?.unreTweet(tweetId: tweetId, success: {
                self.setRetweeted(false)
            }, failure: { (error) in
                print("Unretweet unsuccessful: \(error)")
            })
        }
    }
    
    @IBAction func favourite(_ sender: Any) {
        let toBeFavourited = !favourited
        if (toBeFavourited) {
            TwitterAPICaller.client?.favTweet(tweetId: tweetId, success: {
                self.setFavourited(true)
            }, failure: { (error) in
                print("Favourite did not succeed: \(error)")
            })
        } else {
            TwitterAPICaller.client?.unfavTweet(tweetId: tweetId, success: {
                self.setFavourited(false)
            }, failure: { (error) in
                print("UnFavourite did not succeed: \(error)")
            })
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
