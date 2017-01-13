//
//  ViewController.swift
//  async_image
//
//  Created by Robert Elfström on 2016-12-23.
//  Copyright © 2016 Robert Elfström. All rights reserved.
//

import UIKit



class ViewController: UITableViewController {
    
    var refreshCtrl: UIRefreshControl!
    var tableData:[AnyObject]!
    var task: URLSessionDownloadTask!
    var session: URLSession!
    var cache:NSCache<AnyObject, AnyObject>!
    
    var valueToPass: String!
    

    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        session = URLSession.shared
        task = URLSessionDownloadTask()
        
        self.navigationItem.title = "KompisKlanens Twitch videos"
        
        self.refreshCtrl = UIRefreshControl()
        self.refreshCtrl.addTarget(self, action: #selector(ViewController.refreshTableView), for: .valueChanged)
        self.refreshControl = self.refreshCtrl
        
        
        self.tableData = []
        self.cache = NSCache()
        
        refreshTableView()
        downloadVideos()

    
    }
    
    
    func downloadVideos() {
        
        let url:URL! = URL(string:"https://api.twitch.tv/kraken/channels/KompisKlanen/videos?limit=100&client_id=ojzh3cc1s83vj46jrdgp3hkxj3honeu")
        task = session.downloadTask(with: url, completionHandler: { (location: URL?, response: URLResponse?, error: Error?) -> Void in
            
            if location != nil {
                let data:Data! = try? Data(contentsOf: location!)
                do{
                    let dic = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as AnyObject
                    self.tableData = dic.value(forKey: "videos") as? [AnyObject]
                    
                    
                    DispatchQueue.main.async(execute: { () -> Void in
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    })
                }catch{
                    print("ingen data kom hem")
                }
            }
        })
        task.resume()

        
        
    }
    
 
    
    func refreshTableView(){
        
        downloadVideos()
    }
    
    

    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tableData.count
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
    print("You selected cell #\(indexPath.row)!")
    
    // Get Cell Label
    let indexPath = tableView.indexPathForSelectedRow!
    let currentCell = tableView.cellForRow(at: indexPath)! as UITableViewCell
    
    valueToPass = currentCell.detailTextLabel?.text
    performSegue(withIdentifier: "twitchVids", sender: self)
    }
    
     func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?){
        
        if (segue.identifier == "twitchVids") {
            // initialize new view controller and cast it as your view controller
            let viewController = segue.destination as! TwitchDetails
            // your new view controller should have property that will store passed value
            viewController._videoID = valueToPass
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier:"tblCell", for: indexPath)
        let dictionary = self.tableData[(indexPath as NSIndexPath).row] as! [String:AnyObject]
        
        let videoID = dictionary["url"] as? String
        print(videoID!)
        
        cell.textLabel!.text = dictionary["title"] as? String
        cell.detailTextLabel!.text = dictionary["url"] as? String
        
        
        
        if (self.cache.object(forKey: (indexPath as IndexPath).row as AnyObject) != nil) {
            print("cached image used, no need to download it")
            cell.imageView?.image = self.cache.object(forKey: (indexPath as NSIndexPath).row as AnyObject) as? UIImage
        }else {
            let videoImage = dictionary["preview"] as! String
            let url:URL! = URL(string: videoImage)
            task = session.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                if let data = try? Data(contentsOf: url) {
                    DispatchQueue.main.async(execute: { () -> Void in
                        
                        if let updateCell = tableView.cellForRow(at: indexPath) {
                            let img:UIImage! = UIImage(data: data)
                            updateCell.imageView?.image = img
                            self.cache.setObject(img, forKey: (indexPath as NSIndexPath).row as AnyObject)
                        }
                })
        }
            })
            task.resume()
        }
        
        return cell
    }
    
   
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

