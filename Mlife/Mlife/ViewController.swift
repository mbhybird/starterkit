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
	
	let proximityUUID = NSUUID(UUIDString: "23A01AF0-232A-4518-9C0E-323FB773F5EF")
	var region = CLBeaconRegion()
	let manager = CLLocationManager()
	
	override func viewDidLoad() {
		super.viewDidLoad()
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
		
		self.wk = WKWebView(frame: self.view.frame)
		self.wk.loadRequest(NSURLRequest(URL: NSURL(string: "https://mlife.mo")!))
		self.view.addSubview(self.wk)
		
		wk.UIDelegate = self
		wk.navigationDelegate = self
		
		testNSThread()
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
					let routeUrl = "https://mlife.mo/#wineanddine;Id=4"
					self.wk.loadRequest(NSURLRequest(URL: NSURL(string: routeUrl)!))
				}
				else if (self.openning && wk.URL?.absoluteString == "https://mlife.mo/#") {
					self.openning = false
				}
			}
		}
	}
}



