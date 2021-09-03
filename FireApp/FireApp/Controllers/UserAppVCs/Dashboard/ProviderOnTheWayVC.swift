//
//  ProviderOnTheWayVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 27/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Cosmos

class ProviderOnTheWayVC: UIViewController,  MKMapViewDelegate, CLLocationManagerDelegate {

    @IBOutlet weak var viewBackgroundStatusColor: UIView!
    @IBOutlet weak var lblProviderStatus: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblAmountRate: UILabel!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var lblETA: UILabel!
    @IBOutlet var cosmosView: CosmosView!
    
    
    @IBOutlet var profileDetailView: UIView!
    
    var previousAngle : Float = 100.0
    var pointOfDriver : MyAnnotation!
    var tempPolyline : MKPolyline!
    var mapManager = MapManager()
    var pointOfOrigin = MKPointAnnotation.init()
    var pointOfDestination = MKPointAnnotation.init()
    var jobPoint : JobPointVO!
    var jobStatus : JobStatus!
    
    let locationManager = CLLocationManager()
    var region = MKCoordinateRegion()
    //var jobDetail : RequestJobDetailVO!
    
    var orangeColor = UIColor(red: 245/255, green: 162/255, blue: 25/255, alpha: 1)
    var blueColor = UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1)
    
    //var jobInfo = JobVO()
    var jobInfo = JobHistoryVO()
    var jobID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        //self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = false
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.locationManager.startUpdatingLocation()
        
        let tapViewProfile = UITapGestureRecognizer(target: self, action: #selector(ProfileDetail))
        profileDetailView.addGestureRecognizer(tapViewProfile)
        self.mapView.reloadInputViews()
        self.setupReportButton()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.callApijobDetail()
        self.addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        self.callApiRoomLeave()
        
        NotificationCenter.default.removeObserver(self, name: .KLeaveRoom, object: nil)
        NotificationCenter.default.removeObserver(self, name: .KJoinRoom, object: nil)
        NotificationCenter.default.removeObserver(self, name: .KCurrentLocation, object: nil)
        NotificationCenter.default.removeObserver(self, name: .kSocketConnected, object: nil)
        NotificationCenter.default.removeObserver(self, name: .kSocketDisconnected, object: nil)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func addObservers()
    {
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveSocketConectionResponse(notification:)), name: .kSocketConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.viewInitializerNotification(_:)), name: NSNotification.Name(rawValue: "providerOnTheWay"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveSocketDisconectResponse(notification:)), name: .kSocketDisconnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveJoinRoomResponse(notification:)), name: NSNotification.Name.KJoinRoom, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.didReceiveLeaveRoomResponse(notification:)), name: NSNotification.Name.KLeaveRoom, object: nil)
    }
    
    @objc func ProfileDetail() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.providerID   = self.jobInfo.providerID
        vc.jobID        = jobID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func viewInitializer() {
        
        if jobInfo.status == JobStatus.onway.rawValue
        {
            self.viewBackgroundStatusColor.backgroundColor = orangeColor
            
            self.lblProviderStatus.text = "Provider is on his way"
            
            URLConfiguration.delay(2, closure: {
                self.callApiRoomJoin()
            })
        }
        else if jobInfo.status == JobStatus.arrived.rawValue
        {
            self.viewBackgroundStatusColor.backgroundColor = blueColor
            print("Arrived")
            self.lblProviderStatus.text = "Provider Arrived"
            
            URLConfiguration.delay(2, closure: {
                self.callApiRoomJoin()
            })
        }
        else if jobInfo.status == JobStatus.started.rawValue
        {
            self.viewBackgroundStatusColor.backgroundColor = .systemGreen
            print("Started")
            self.lblProviderStatus.text = "Job Started"
            
            URLConfiguration.delay(2, closure: {
                self.callApiRoomLeave()
            })
        }
        else if jobInfo.status == JobStatus.completed.rawValue
        {
            print("Completed")
            
            URLConfiguration.delay(2, closure: {
                self.callApiRoomLeave()
            })
        }
        
        if self.jobInfo.type == "fixed"
        {
            self.lblAmountRate.text = self.jobInfo.currency + " " + (Int(self.jobInfo.budget as String)?.withCommas())!
            // + (Currency.currencyCode)
        }
        else
        {
            self.lblAmountRate.text = self.jobInfo.currency + " " + (Int(self.jobInfo.budget as String)?.withCommas())! + "/hr"
        }
        
        self.cosmosView.rating = self.jobInfo.providerRating
        self.lblTitle.text = self.jobInfo.displayName
        self.lblDescription.text = self.jobInfo.categoryName
        self.lblETA.text = "ETA"
        
        let data = setImageWithUrl(url: self.jobInfo.profileImageURL)
        
        DispatchQueue.main.async {
            self.imgView.layer.cornerRadius = self.imgView.frame.height/2
            self.imgView.image = UIImage(data: data!)
        }
        
        //setMapCentred(aroundLocation: CLLocation(latitude: self.jobInfo.latitude!, longitude: self.jobInfo.longitude!))
        
        if (self.jobInfo) != nil
        {
            self.drawRouteLine()
        }
    }
    
    func setupReportButton(){
        let reportButton = UIButton()
        reportButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        reportButton.setImage(UIImage(named: "report"), for: .normal)
        reportButton.addTarget(self, action: #selector(self.reportThis), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: reportButton)
    }
    
    @objc func reportThis(){
        
        let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReportVC_ID") as! ReportVC
        vc.jobInfo      = self.jobInfo
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc func viewInitializerNotification (_ notification : NSNotification) {
        
        if let jobID = notification.userInfo?["jobInfoID"] as? String {
            
            self.jobID = jobID
            self.callApijobDetail()
        }
    }
    
    func callApiRoomJoin() {
        
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = ["room" : self.jobInfo.providerID] as [String : Any]
        SocketManager.shared.sendSocketRequest(name: SocketEvent.JoinRoom, params: params)
    }
    
    func callApiRoomLeave() {
        
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = ["room" : self.jobInfo.providerID] as [String : Any]
        SocketManager.shared.sendSocketRequest(name: SocketEvent.leaveRoom, params: params)
    }
    
    func callApijobDetail() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        
        Api.jobHistoryApi.jobHistoryWith(jobID: self.jobID, completion: { (success : Bool, message : String, jobDetail : JobHistoryVO?) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                if jobDetail != nil
                {
                    self.jobInfo = jobDetail!
                    self.viewInitializer()
                }
                else
                {
                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnMessageAction(_ sender: Any) {
        
        var selectedJobID = String()
        
        if jobInfo != nil
        {
            selectedJobID = self.jobInfo._id
        }
        
//        let chatView = ChatViewController()
//        chatView.messages = makeNormalConversation()
//        chatView.jobID = selectedJobID
//        let chatNavigationController = UINavigationController(rootViewController: chatView)
//        present(chatNavigationController, animated: true, completion: nil)
        
//        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
//        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
//        vc.messages = []
//        vc.jobID = selectedJobID
//        self.navigationController?.pushViewController(vc, animated: true)
        
        
        let storyBoard = UIStoryboard(name: "UserChat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
        vc.jobID            = jobID
        vc.providerID       = self.jobInfo.providerID
        vc.providerName     = self.jobInfo.displayName
        vc.providerCategory = self.jobInfo.categoryName
        vc.providerImageURL = self.jobInfo.profileImageURL
        self.navigationController?.pushViewController(vc, animated: true)
        
//        let phone = self.jobInfo.providerPhone
//        guard let number = URL(string: "sms://" + phone!) else { return }
//
//        if phone == ""
//        {
//            showInfoAlertWith(title: "Missing Information", message: "No registered number found for this member")
//        }
//        else
//        {
//
//
//            //UIApplication.shared.openURL(number)
//        }
    }
    
    @IBAction func btnCallAction(_ sender: Any) {
        
        //let user = AppUser.getUser()
        let phone = self.jobInfo.providerPhone
        
        guard let number = URL(string: "tel://" + phone!) else { return }
        
        if phone == ""
        {
            showInfoAlertWith(title: "Missing Information", message: "No registered number found for this member")
        }
        else
        {
            let alertController = UIAlertController(title: "Alert", message: "Are you Sure want to Call? Call Charges will be applied", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "Yes", style: .default) { (action) in
                UIApplication.shared.openURL(number)
            }
            let NoAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            alertController.addAction(NoAction)
            present(alertController, animated: true, completion: nil)
        }
    }

    var counter = 0
    
    // This gets called periodically
    @objc func providerLocationUpdated(notification : Notification)
    {
        let userInfo = notification.userInfo
        
        if let info = (userInfo as NSDictionary?)
        {
            if let location = info["location"] as? NSDictionary
            {
                let lat = location["latitude"] as? Double
                let long = location["longitude"] as? Double
                
                let locationToSend = CLLocation(latitude: lat!, longitude: long!)
                
                print("\(lat!) : \(long!) : \(counter)")
                counter += 1
                moveDriverOnMap(driverLocation: locationToSend)
            }
        }
    }
    
    func moveDriverOnMap(driverLocation : CLLocation)
    {
        //  Code here to show driver position on map
        
        if pointOfDriver == nil
        {
            pointOfDriver  = MyAnnotation()
            pointOfDriver.setCoordinate(driverLocation.coordinate)
            pointOfDriver.previousCoordinate = driverLocation.coordinate
            
            pointOfDriver.idVal = AppUser.getUser()?._id
            
            
//            let location = CLLocation(latitude: driverLocation.coordinate.latitude, longitude: driverLocation.coordinate.longitude)
//
//            pointOfDriver.setCoordinate(location.coordinate)
//
//            pointOfDriver.previousCoordinate = CLLocationCoordinate2D.init(latitude: driverLocation.coordinate.latitude, longitude: driverLocation.coordinate.longitude)
            
            
//            if let user = AppUser.getUser() {
//                pointOfDriver.idVal = user._id
//            }
            
            pointOfDriver.carType = "placeholder"
            
            
            
            //            pointOfDriver.bearing = driverLocation.bearing;
            
            
            
            DispatchQueue.main.async {
                
                self.mapView.addAnnotation(self.pointOfDriver)
                self.setMapCentred(aroundLocation: driverLocation)
            }
            
        }
        
        UIView.animate(withDuration: 1.2, animations: {
            
            self.pointOfDriver.setCoordinate(driverLocation.coordinate)
            
        }, completion: { (success:Bool) in
            
            self.setMapCentred(aroundLocation: driverLocation)
            
        })
        
        //Because vehicle is hidden and default location icon is shown now during the job
        
        if (self.mapView.view(for: pointOfDriver) != nil)
        {
            let annotationView: MKAnnotationView = self.mapView.view(for: pointOfDriver)!
            
            let getAngle = Float(self.getBearingBetweenTwoPoints1(point1: pointOfDriver.previousCoordinate, point2: pointOfDriver.coordinate))
            
            let willTransform = isSufficientDifferenceBetween(current: getAngle, previous: previousAngle)
            //                        print("Angle Between 2 Points \(getAngle) : \(willTransform)")
            
            if(willTransform == true)
            {
                //                print("Transformed Angle --------------------------")
                UIView.animate(withDuration: 0.75, animations: {
                    annotationView.transform = CGAffineTransform(rotationAngle: CGFloat(getAngle))
                })
                previousAngle = getAngle
            }
        }
        
        pointOfDriver.previousCoordinate = pointOfDriver.coordinate
    }
    
    func isSufficientDifferenceBetween(current : Float, previous : Float) -> Bool
    {
        var result = false
        var difference = current - previous
        if (difference < 0)
        {
            difference = difference * -1
        }
        
        if difference > 0.25
        {
            result = true
        }
        else
        {
            result = false
        }
        
        return result
        
    }
    
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    func radiansToDegrees(radians: Double) -> Double { return radians * 180.0 / M_PI }
    
    func getBearingBetweenTwoPoints1(point1 : CLLocationCoordinate2D, point2 : CLLocationCoordinate2D) -> Double {
        
        let lat1 = degreesToRadians(degrees: point1.latitude)
        let lon1 = degreesToRadians(degrees: point1.longitude)
        
        let lat2 = degreesToRadians(degrees: point2.latitude)
        let lon2 = degreesToRadians(degrees: point2.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        return radiansBearing
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            print("location:: (\(location))")
            print(location.coordinate)
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured \(error.localizedDescription)")
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let coordinate = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
        print(center)
        print(coordinate)
        
    }
    
    func setMapCentred(aroundLocation location : CLLocation)
    {
        let latDelta:CLLocationDegrees = 0.005
        let longDelta:CLLocationDegrees = 0.005
        
        let coordinate = CLLocationCoordinate2D(latitude:location.coordinate.latitude, longitude: location.coordinate.longitude )
        
        let theSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: theSpan)
        self.mapView.setRegion(region, animated: true)
    }
    
    func drawRouteLine()
    {
        var origin : NSString!
        var destination : NSString!
        
        if (self.tempPolyline != nil)
        {
            mapView.removeOverlay(self.tempPolyline)
        }
        
        if let lastSavedLocation = DashboardVC.lastSavedLocation
        {
            origin = String(format:"%f,%f",self.jobInfo.providerLatitude!,self.jobInfo.providerLongitude!)  as NSString?
            destination = String(format:"%f,%f",self.jobInfo.latitude!,self.jobInfo.longitude!) as NSString?
            
            mapManager.directionsUsingGoogle(from: origin!, to: destination!) { (route,directionInformation, boundingRegion, error) -> () in
                
                if(error != nil)
                {
                    print(error)
                }
                else
                {
                    if (self.pointOfDriver != nil)
                    {
                        self.mapView.removeAnnotation(self.pointOfDriver)
                        self.pointOfDriver = nil
                    }
                    
                    self.pointOfOrigin = MKPointAnnotation()
                    self.pointOfOrigin.accessibilityHint = "Source"
                    self.pointOfOrigin.coordinate = route!.coordinate
                    self.pointOfOrigin.title = directionInformation?.object(forKey: "start_address") as! NSString as String
                    self.pointOfOrigin.subtitle = directionInformation?.object(forKey: "duration") as! NSString as String
                    
                    self.pointOfDestination = MKPointAnnotation()
                    self.pointOfDestination.accessibilityHint = "Destination"
                    self.pointOfDestination.coordinate = route!.coordinate
                    self.pointOfDestination.title = directionInformation?.object(forKey: "end_address") as! NSString as String
                    self.pointOfDestination.subtitle = directionInformation?.object(forKey: "distance") as! NSString as String
                    
                    let start_location = directionInformation?.object(forKey: "start_location") as! NSDictionary
                    let originLat = start_location.object(forKey: "lat") as! Double
                    let originLng = start_location.object(forKey: "lng") as! Double
                    
                    let end_location = directionInformation?.object(forKey: "end_location") as! NSDictionary
                    let destLat = end_location.object(forKey: "lat") as! Double
                    let destLng = end_location.object(forKey: "lng") as! Double
                    
                    let coordOrigin = CLLocationCoordinate2D(latitude: originLat, longitude: originLng)
                    let coordDesitination = CLLocationCoordinate2D(latitude: destLat, longitude: destLng)
                    
                    self.pointOfOrigin.coordinate = coordOrigin
                    
                    self.pointOfDestination.coordinate = coordDesitination
                    
                    if let map = self.mapView
                    {
                        DispatchQueue.main.async {
                            
                            self.removeAllPlacemarkFromMap(shouldRemoveUserLocation: true)
                            self.tempPolyline = route
                            map.addOverlay(route!)
                            map.addAnnotation(self.pointOfOrigin)
                            map.addAnnotation(self.pointOfDestination)
                            map.setVisibleMapRect(boundingRegion!, edgePadding: UIEdgeInsets(top: 30, left: 30, bottom: 30, right: 30), animated: true)
                        }
                    }
                }
            }
        }
        
        
    }
    
    func removeAllPlacemarkFromMap(shouldRemoveUserLocation:Bool){
        if let mapView = self.mapView {
            for annotation in mapView.annotations{
                if shouldRemoveUserLocation {
                    if annotation as? MKUserLocation !=  mapView.userLocation {
                        mapView.removeAnnotation(annotation as MKAnnotation)
                    }
                }
            }
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView?
    {
        if (annotation is MKUserLocation)
        {
            //            return nil
        }
        else
        {
            if let annot : MyAnnotation = annotation as? MyAnnotation
            {
                let annView : MKAnnotationView = annot.annotaionView()
                annView.image = nil;
                annView.image = UIImage(named: "black")
                return annView;
            }
            else if let pointAnnotation = annotation as? MKPointAnnotation
            {
                let identifier = "locationPoint"
                let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                
                if(pointAnnotation.accessibilityHint == "Source")
                {
                    annotationView.image = UIImage(named:"placeholder")
                }
                else if (pointAnnotation.accessibilityHint == "Destination")
                {
                    annotationView.image = UIImage(named:"placeholder")
                }
                
                return annotationView;
            }
        }
        
        return nil
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer
    {
        let renderer = YMPolyLineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor(red: 40/255, green: 40/255, blue: 40/255, alpha: 1.0)
        renderer.lineWidth = 4.0
        
        return renderer
    }
    
    @objc func didReceiveSocketDisconectResponse(notification : Notification)
    {
        hideProgressHud(viewController: self)
    }
    
    @objc func didReceiveSocketConectionResponse(notification : Notification)
    {
        hideProgressHud(viewController: self)
    }
    
    @objc func didReceiveJoinRoomResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            let suc = userInfo.value(forKey: "isSuccess") as! Bool
            let msg = userInfo.value(forKey: "message") as! String
            
            if suc
            {
                NotificationCenter.default.addObserver(self, selector: #selector(ProviderOnTheWayVC.providerLocationUpdated(notification:)), name: NSNotification.Name.KCurrentLocation, object: nil)
            }
            else
            {
                
            }
        }
    }
    
    @objc func didReceiveLeaveRoomResponse(notification : Notification)
    {
        if let userInfo = notification.userInfo as? NSDictionary
        {
            let suc = userInfo.value(forKey: "isSuccess") as! Bool
            let msg = userInfo.value(forKey: "message") as! String
            if suc
            {
                NotificationCenter.default.removeObserver(self, name: .KCurrentLocation, object: nil)
            }
            else
            {
                
            }
        }
    }
    
 


}



