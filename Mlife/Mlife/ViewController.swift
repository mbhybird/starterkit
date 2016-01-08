//
//  ViewController.swift
//  Mlife
//
//  Created by ZhongTingliang on 1/4/16.
//  Copyright © 2016 Buzz. All rights reserved.
//

import UIKit
import WebKit
import CoreLocation
import AVFoundation

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, CLLocationManagerDelegate {
	
	var status : String = ""
	var uuid : String = ""
	var major : String = ""
	var minor : String = ""
	var accuracy : String = ""
	var rssi : String = ""
	var distance : String = ""
	var doOpen : Bool = false
	var openning : Bool = false
	
	var wk: WKWebView!
	var progressView = UIProgressView()
	
	let proximityUUID = NSUUID(UUIDString: "23A01AF0-232A-4518-9C0E-323FB773F5EF")
	var region = CLBeaconRegion()
	let manager = CLLocationManager()
	
	var audioPlayer = AVAudioPlayer()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// d4.mp3,d7.mp3
		let path = NSBundle.mainBundle().pathForResource("d4", ofType: "mp3")
		print("path:\(path)")
		do {
			audioPlayer = try AVAudioPlayer(contentsOfURL: NSURL(fileURLWithPath: path!))
			let session = AVAudioSession.sharedInstance()
			do {
				try session.setCategory(AVAudioSessionCategoryPlayback)
			}
			audioPlayer.play()
		} catch {
			
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		
		region = CLBeaconRegion(proximityUUID: proximityUUID!, identifier: "")
		manager.delegate = self
		
		switch CLLocationManager.authorizationStatus() {
		case .Authorized, .AuthorizedWhenInUse:
			print("Starting Monitor")
			self.manager.startRangingBeaconsInRegion(self.region)
		case .NotDetermined:
			print("Starting Monitor")
			let s = UIDevice.currentDevice().systemVersion
			let index = s.startIndex.advancedBy(1)
			print(s.substringToIndex(index))
			if (Int(s.substringToIndex(index)) >= 8) {
				self.manager.requestAlwaysAuthorization()
				self.manager.startRangingBeaconsInRegion(self.region)
			} else {
				self.manager.startRangingBeaconsInRegion(self.region)
			}
		case .Restricted, .Denied:
			let alertController = UIAlertController(
				title: "Background Location Access Disabled",
				message: "In order to be notified about adorable kittens near you, please open this app's settings and set location access to 'Always'.",
				preferredStyle: .Alert)
			
			let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
			alertController.addAction(cancelAction)
			let openAction = UIAlertAction(title: "Open Settings", style: .Default) {(action) in
				if let url = NSURL(string: UIApplicationOpenSettingsURLString) {
					UIApplication.sharedApplication().openURL(url)
				}
			}
			alertController.addAction(openAction)
			self.presentViewController(alertController, animated: true, completion: {
					self.manager.startRangingBeaconsInRegion(self.region)
				})
		}
		
		// self.wk = WKWebView(frame: self.view.frame)
		let navItem = UINavigationItem()
		navItem.leftBarButtonItem = UIBarButtonItem(title: "Prev", style: .Done, target: self, action: "previousPage")
		navItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "nextPage")
		let navBar = UINavigationBar(frame: CGRectMake(0, 20, self.view.frame.width, 40))
		navBar.items?.append(navItem)
		self.view.addSubview(navBar)
		self.wk = WKWebView(frame: CGRectMake(0, 60, self.view.frame.width, self.view.frame.height))
		self.wk.loadRequest(NSURLRequest(URL: NSURL(string: "https://mlife.mo")!))
		self.view.addSubview(self.wk)
		
		self.progressView = UIProgressView(progressViewStyle: .Default)
		self.progressView.frame.size.width = self.view.frame.size.width
		self.progressView.backgroundColor = UIColor.redColor()
		self.view.addSubview(self.progressView)
		
		// self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Prev", style: .Done, target: self, action: "previousPage")
		// self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .Done, target: self, action: "nextPage")
		
		// 监听支持KVO的属性
		self.wk.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
		self.wk.addObserver(self, forKeyPath: "title", options: .New, context: nil)
		self.wk.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
		
		wk.UIDelegate = self
		wk.navigationDelegate = self
		
		testNSThread()
	}
	
	// MARK: - KVO
	override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
		if keyPath == "loading" {
			print("loading")
		} else if keyPath == "title" {
			self.title = self.wk.title
		} else if keyPath == "estimatedProgress" {
			print(wk.estimatedProgress)
			self.progressView.setProgress(Float(wk.estimatedProgress), animated: true)
		}
		
		// 已经完成加载时，我们就可以做我们的事了
		if !wk.loading {
			UIView.animateWithDuration(0.55, animations: {() -> Void in
					self.progressView.alpha = 0.0;
				})
		}
	}
	
	func previousPage() {
		if self.wk.canGoBack {
			self.wk.goBack()
		}
	}
	
	func nextPage() {
		if self.wk.canGoForward {
			self.wk.goForward()
		}
	}
	
	func webView(webView: WKWebView,
		createWebViewWithConfiguration configuration: WKWebViewConfiguration,
		forNavigationAction navigationAction: WKNavigationAction,
		windowFeatures: WKWindowFeatures) -> WKWebView? {
		if navigationAction.targetFrame == nil {
			let url = navigationAction.request.URL!
			print(url.absoluteString)
			// webView.loadRequest(NSURLRequest(URL: url))
			let desc = url.description.lowercaseString
			if (desc.rangeOfString("http://") != nil
				|| desc.rangeOfString("https://") != nil
				|| desc.rangeOfString("mailto:") != nil
				|| desc.rangeOfString("tel:") != nil) {
				
				print(__FILE__)
				print(__FUNCTION__)
				print(__LINE__)
				print(__COLUMN__)
				
				UIApplication.sharedApplication().openURL(url)
			}
		}
		
		return nil
		
	}
	
	func locationManager(manager: CLLocationManager, didStartMonitoringForRegion region: CLRegion) {
		manager.requestStateForRegion(region)
		print("Scanning...")
	}
	
	func locationManager(manager: CLLocationManager, didDetermineState state: CLRegionState, forRegion inRegion: CLRegion) {
		if (state == .Inside) {
			manager.startRangingBeaconsInRegion(region)
		}
	}
	
	func locationManager(manager: CLLocationManager, monitoringDidFailForRegion region: CLRegion?, withError error: NSError) {
		print("monitoringDidFailForRegion \(error)")
	}
	
	func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
		print("didFailWithError \(error)")
	}
	
	func locationManager(manager: CLLocationManager, didEnterRegion region: CLRegion) {
		manager.startRangingBeaconsInRegion(region as! CLBeaconRegion)
		print("Possible Match")
	}
	
	func locationManager(manager: CLLocationManager, didExitRegion region: CLRegion) {
		manager.stopRangingBeaconsInRegion(region as! CLBeaconRegion)
		reset()
	}
	
	func locationManager(manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], inRegion region: CLBeaconRegion) {
		// print(beacons)
		
		if (beacons.count == 0) {return}
		
		for b in beacons {
			let uniqueId = "\(b.major)-\(b.minor)"
			if (uniqueId == "2397-4") {
				if (b.proximity == CLProximity.Immediate) {
					self.doOpen = true
					print("doOpen:\(self.doOpen)")
					break
				}
				else {
					self.doOpen = false
					print("doOpen:\(self.doOpen)")
					break
				}
			}
		}
		
		let beacon = beacons[0]
		
		if (beacon.proximity == CLProximity.Unknown) {
			self.distance = "Unknown Proximity"
			reset()
			return
		} else if (beacon.proximity == CLProximity.Immediate) {
			self.distance = "Immediate"
		} else if (beacon.proximity == CLProximity.Near) {
			self.distance = "Near"
		} else if (beacon.proximity == CLProximity.Far) {
			self.distance = "Far"
		}
		self.status = "OK"
		self.uuid = beacon.proximityUUID.UUIDString
		self.major = "\(beacon.major)"
		self.minor = "\(beacon.minor)"
		self.accuracy = "\(beacon.accuracy)"
		self.rssi = "\(beacon.rssi)"
	}
	
	func reset() {
		self.status = ""
		self.uuid = ""
		self.major = ""
		self.minor = ""
		self.accuracy = ""
		self.rssi = ""
	}
	
	func testNSThread() {
		// 方式二
		let myThread = NSThread(target: self, selector: "threadInMainMethod:", object: nil)
		myThread.start()
	}
	
	func threadInMainMethod(sender : AnyObject) {
		while (true) {
			if (self.doOpen) {
				sleep(1)
				print("openning:\(self.openning)")
				if (!self.openning) {
					self.openning = true
					// let routeUrl = "https://mlife.mo/#wineanddine;Id=4"
					let routeUrl = "http://storypixel.com/lab/blinkwang/"
					self.wk.loadRequest(NSURLRequest(URL: NSURL(string: routeUrl)!))
				}
				else if (self.openning && wk.URL?.absoluteString == "https://mlife.mo/#") {
					self.openning = false
				}
			}
		}
	}
}



