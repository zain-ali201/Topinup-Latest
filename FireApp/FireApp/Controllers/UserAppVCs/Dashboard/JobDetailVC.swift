//
//  JobDetailVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 19/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class JobDetailVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var imgClient: UIImageView!
    @IBOutlet weak var lblClientName: UILabel!
    @IBOutlet weak var lblClientAddress: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblBudget: UILabel!
    @IBOutlet weak var lblScheduled: UILabel!
    @IBOutlet weak var lblDescription: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var btnQuote: UIButton!
    
    let locationManager = CLLocationManager()
    var region = MKCoordinateRegion()
    
    var jobID : String!
    var jobDetail : JobDetailVO!
    
    var latitude : Double!
    var longitude : Double!
    
    var imagesCells = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapViewInitializer()
        viewInitializer()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        self.callApijobDetail()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer() {
        self.btnQuote.layer.cornerRadius = self.btnQuote.frame.height/2
    }
    
    func mapViewInitializer() {
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.startUpdatingLocation()
        self.mapView.showsUserLocation = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.locationManager.startUpdatingLocation()
        self.mapView.reloadInputViews()
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
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let coordinate = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
        print(center)
        print(coordinate)
    }
    
    func setMapCentred(aroundLocation location : CLLocationCoordinate2D) {
        
        self.locationManager.startUpdatingLocation()
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured \(error.localizedDescription)")
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func callApijobDetail() {
        
//        showProgressHud(viewController: self)
//        Api.jobDetailApi.jobDetailWith(jobID: self.jobID, completion: { (success:Bool, message : String, jobDetail : JobDetailVO?) in
//            hideProgressHud(viewController: self)
//            if success {
//                if jobDetail != nil {
//
//                    self.jobDetail = jobDetail
//                    self.reloadViewDetails()
//                    
//                } else {
//                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
//                }
//            } else {
//                self.showInfoAlertWith(title: "Error", message: message)
//            }
//        })
    }
    
    func reloadViewDetails() {
        
        self.lblClientName.text = self.jobDetail.jobDetailObject.displayName
        self.lblClientAddress.text = self.jobDetail.jobDetailObject.address
        self.latitude = self.jobDetail.jobDetailObject.latitude
        self.longitude = self.jobDetail.jobDetailObject.longitude
        
        self.lblBudget.text = (Currency.currencyCode) + String(describing: self.jobDetail.fixedRate!)
        
        self.lblScheduled.text = self.jobDetail.jobDetailObject.scheduleTime
        
        self.lblDescription.text = self.jobDetail.descriptionn
        
//        let data = setImageWithUrl(url: self.jobDetail.jobDetailObject.profileImageURL)
//
//        DispatchQueue.main.async {
//            self.imgClient.layer.cornerRadius = self.imgClient.frame.height/2
//            self.imgClient.image = UIImage(data: data!)
//        }
        
        //self.imagesCells = self.jobDetail.images
        self.collectionView.reloadData()
    }
    
    @IBAction func flagJobAction(_ sender: Any) {
    }
    
    @IBAction func btnQouteAction(_ sender: Any) {
        self.performSegue(withIdentifier: "quoteToCreateQuoteSegue", sender: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesCells.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! JobDetailCVC
        let data = setImageWithUrl(url: self.jobDetail.images[indexPath.row])
        
        DispatchQueue.main.async {
            cell.imgDetails.layer.cornerRadius = cell.imgDetails.frame.height/2
            cell.imgDetails.image = UIImage(data: data!)
        }
        return cell
    }
}
