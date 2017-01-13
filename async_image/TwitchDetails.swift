//
//  TwitchDetails.swift
//  async_image
//
//  Created by Robert Elfström on 2016-12-31.
//  Copyright © 2016 Robert Elfström. All rights reserved.
//

import UIKit
import WebKit

class TwitchDetails: UIViewController {
    
    var _videoID: String!
        
    @IBOutlet weak var videoWebView: WKWebView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        let url = NSURL(string: _videoID)
        let request = NSURLRequest(url:url! as URL)
        videoWebView.load(request as URLRequest)
        
        
    }
    
}
