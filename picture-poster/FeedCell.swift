//
//  FeedCell.swift
//  picture-poster
//
//  Created by Jonathan Wood on 10/4/15.
//  Copyright © 2015 Jonathan Wood. All rights reserved.
//

import UIKit
import Alamofire

class FeedCell: UITableViewCell {

    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var showcaseImg: UIImageView!
    @IBOutlet weak var descriptionText: UITextView!
    @IBOutlet weak var likesLbl: UILabel!
    
    var post: Post!
    var request: Request?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func drawRect(rect: CGRect) {
        profileImg.layer.cornerRadius = profileImg.frame.size.width / 2
        profileImg.clipsToBounds = true
        
        showcaseImg.clipsToBounds = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configureCell(post: Post, img: UIImage?) {
        self.post = post
        
        self.descriptionText.text = post.postDescription
        self.likesLbl.text = "\(post.likes)"
        
        if post.imageUrl != nil {
            
            // An image is already cached in memory, hence img != nil
            if img != nil {
                self.showcaseImg.image = img
            } else {
                // Request image URL from Firebase
                request = Alamofire.request(.GET, post.imageUrl!).validate(contentType: ["image/*"]).response(completionHandler: { request, response, data, err in
                    print("Alamofire \"data\" returned from Firebase:\n\n \(data)")
                    
                    // If there are no errors in the request
                    if err == nil {
                        
                        print("\n\n img (after Alamofire call) = \(img)")
                        
                        // If img != nil (after Alamofire request)
                        if img != nil {
                            // Alamofire "data" returns just a bunch of numbers (in bytes)
                            let img = UIImage(data: data!)!
                            self.showcaseImg.image = img
                            FeedVC.imageCache.setObject(img, forKey: self.post.imageUrl!)
                        } else {
                            print("Could not get image from Alamofire request: img = nil.")
                        }
                        
                        
                    } else {
                        print(err.debugDescription)
                    }
                    
                })
            }
            
        } else {
            self.showcaseImg.hidden = true
        }
        
    }
}
