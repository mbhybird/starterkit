//
//  FlickrLoader.swift
//  AlbumMotion
//
//  Created by ZhongTingliang on 12/25/15.
//  Copyright © 2015 Buzz. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import PySwiftyRegex
import SwiftyJSON

class FlickrLoader{
    
    
    func loadImage(imgView:UIImageView) {
        
        //let random = Int(arc4random_uniform(UInt32(100))) as Int
        
        let dataUrl = "https://api.flickr.com/services/feeds/photos_public.gne?format=json&nojsoncallback=1"
        
        Alamofire.request(.GET, dataUrl).validate().responseJSON(){
            
            response in
            
            //print(response.request)  // original URL request
            //print(response.response) // URL response
            //print(response.data)     // server data
            //print(response.result)   // result of response serialization
            
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    
                    /*
                    let regex =  re.compile("[(](.+)[)]",flags:[NSRegularExpressionOptions.DotMatchesLineSeparators])
                    let filter =  regex.search(value)
                    let formatJson = filter!.group(1)
                    
                    print("FormatJSON: \(formatJson)")*/
                    
                    let json = JSON(value)
                    print("JSON: \(json)")
                    
                    
                    if let array = json["items"].array{
                        if let d = array[0].dictionary{
                            print(d["title"])
                            if let url = d["media"]!.dictionary{
                                print(url["m"]?.string)
                                let imgUrl = (url["m"]?.string)!
                                
                                print(imgUrl)
                                
                                Alamofire.request(.GET, imgUrl).validate().responseData(){
                                    response in
                                    imgView.image = UIImage(data: response.data!, scale:1)!
                                }
                                
                            }
                        }
                    }
                    
                }
            case .Failure(let error):
                print(error)
            }
            
        }
    }
}