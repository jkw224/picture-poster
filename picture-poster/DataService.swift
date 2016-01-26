//
//  DataService.swift
//  picture-poster
//
//  Created by Jonathan Wood on 10/1/15.
//  Copyright © 2015 Jonathan Wood. All rights reserved.
//

import Foundation
import Firebase

let URL_BASE = "https://picture-poster.firebaseio.com"

class DataService {
    static let ds = DataService()
    
    private var _REF_BASE = Firebase(url: "\(URL_BASE)")
    private var _REF_USERS = Firebase(url: "\(URL_BASE)/users")
    private var _REF_POSTS = Firebase(url: "\(URL_BASE)/posts")
    private var _REF_LIKES = Firebase(url: "\(URL_BASE)/likes")
    
    
    
    var REF_BASE: Firebase {
        return _REF_BASE
    }
    
    var REF_USERS: Firebase {
        return _REF_USERS
    }
    
    var REF_POSTS: Firebase {
        return _REF_POSTS
    }
    
    var REF_LIKES: Firebase {
        return _REF_LIKES
    }
    
    var REF_USER_CURRENT: Firebase {
        let uid = NSUserDefaults.standardUserDefaults().valueForKey(KEY_UID) as? String
        let user = Firebase(url: "\(URL_BASE)").childByAppendingPath("users").childByAppendingPath(uid)
        return user!
    }
    
    func createFirebaseUser(uid: String, user: Dictionary<String, String>) {
        REF_USERS.childByAppendingPath(uid).setValue(user)
    }
}