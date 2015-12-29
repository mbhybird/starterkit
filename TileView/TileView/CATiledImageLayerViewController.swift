//
//  CATiledImageLayerViewController.swift
//  LayerPlayer
//
//  Created by Scott Gardner on 11/19/14.
//  Copyright (c) 2014 Scott Gardner. All rights reserved.
//

import UIKit

class CATiledImageLayerViewController: UIViewController {
    
    @IBOutlet weak var autoButton: UIButton!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tilingView: TilingViewForImage!
    var threadStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let screenRect = UIScreen.mainScreen().bounds
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: screenRect.width, height: 80))
        let barBtnItem = UIBarButtonItem(title: "Move", style: UIBarButtonItemStyle.Plain, target: nil, action: "doneButtonTapped:")
       
        let navBarItem =  UINavigationItem(title: "CATiledLayer (image)")
        navBarItem.leftBarButtonItem =  barBtnItem
        
        navBar.items?.append(navBarItem)
        self.view.addSubview(navBar)
        scrollView.contentSize = CGSize(width: 5120, height: 3200)

        
    }
    
    @IBAction func doneButtonTapped(sender: UIBarButtonItem) {
        threadStart = !threadStart
        moveGCDThread()
    }
    
    func moveGCDThread()
    {
        if(threadStart){
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                //print("这里写需要大量时间的代码")
                let rndOffectX = Int(arc4random_uniform(8))
                let rndOffectY = Int(arc4random_uniform(5))
                //print("X:\(rndOffectX),Y:\(rndOffectY)")
                sleep(3)
                dispatch_async(dispatch_get_main_queue(), {
                    //print("这里返回主线程，写需要主线程执行的代码")
                    self.scrollView.contentOffset.x = CGFloat(rndOffectX*Int(sideLength))
                    self.scrollView.contentOffset.y = CGFloat(rndOffectY*Int(sideLength))
                    self.moveGCDThread()
                })
        })
        }
    }
    
}
