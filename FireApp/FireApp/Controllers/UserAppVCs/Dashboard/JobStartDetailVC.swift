//
//  JobStartDetailVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class JobStartDetailVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

    @IBOutlet weak var btnBarRight: UIButton!
    @IBOutlet weak var imgClient: UIImageView!
    @IBOutlet weak var lblClientName: UILabel!
    @IBOutlet weak var lblClientAddress: UILabel!
    @IBOutlet weak var viewCallMessage: UIView!
    @IBOutlet weak var widthConstraintsViewCallMessge: NSLayoutConstraint!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblScheduled: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var viewPrimaryStartWork: UIView!
    @IBOutlet weak var btnPrimaryStartWork: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var innerScrollView: UIView!
    @IBOutlet weak var viewRate: UIView!
    @IBOutlet weak var lblRate: UILabel!
    @IBOutlet weak var viewBackgroundTextView: UIView!
    @IBOutlet weak var txtViewDescription: UITextView!
    
    @IBOutlet weak var lblJobType: UILabel!
    
    
    let locationManager = CLLocationManager()
    var region = MKCoordinateRegion()
    
    var jobDetail : JobHistoryVO!
    
    var jobID : String!
    var imagesCells = [String]()
//
//    var isTripStarted = false
//
//    var isFromProposed = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        mapViewInitializer()
        viewInitializer()
    }
    
    func viewInitializer() {
        
        self.btnPrimaryStartWork.layer.cornerRadius = self.btnPrimaryStartWork.frame.height/2
        self.viewPrimaryStartWork.isHidden = false
        self.viewCallMessage.isHidden = true
        self.widthConstraintsViewCallMessge.constant = 0
        
        self.reloadViewJobDetails()
        self.view.layoutIfNeeded()
    }
    
    func reloadViewJobDetails() {
        
        self.lblClientName.text = self.jobDetail.displayName
        self.lblClientAddress.text = self.jobDetail.wheree
        
        self.lblRate.text = (Currency.currencyCode) + String(describing: self.jobDetail.budget!)
        self.lblScheduled.text = DateUtil.getSimpleDateAndTime(self.jobDetail.when.dateFromISO8601!)
        self.lblJobType.text = self.jobDetail.type.capitalized
        
        if self.jobDetail.details == ""
        {
            self.txtViewDescription.text = "No Details"
        }
        else
        {
            self.txtViewDescription.text = self.jobDetail.details
        }
        
        let data = setImageWithUrl(url: self.jobDetail.profileImageURL)

        DispatchQueue.main.async {
            self.imgClient.layer.cornerRadius = self.imgClient.frame.height/2
            self.imgClient.image = UIImage(data: data!)
        }

        self.imagesCells.removeAll()

        for i in self.jobDetail.images {
            self.imagesCells.append(i)
        }
        
        self.setMapCentred(aroundLocation: CLLocationCoordinate2D(latitude: self.jobDetail.latitude!, longitude: self.jobDetail.longitude!))
        
        delayWithSeconds(1.2) {
            self.collectionView.reloadData()
        }
        
        self.mapView.reloadInputViews()
        
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBarRightAction(_ sender: Any) {
    }
    
    @IBAction func btnCallAction(_ sender: Any) {
    }
    
    @IBAction func btnMessageAction(_ sender: Any) {
    }
    
    @IBAction func btnPrimaryStartWorkAction(_ sender: Any) {
        
        let _ = self.navigationController?.popViewController(animated: true)
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
    
    func mapViewInitializer() {
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.locationManager.startUpdatingLocation()
        //self.mapView.showsUserLocation = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.locationManager.startUpdatingLocation()
        self.mapView.reloadInputViews()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
//        if let location = locations.first {
//            print("location:: (\(location))")
//            print(location.coordinate)
//            let span = MKCoordinateSpanMake(0.01, 0.01)
//            let region = MKCoordinateRegion(center: location.coordinate, span: span)
//            mapView.setRegion(region, animated: true)
//            //self.locationManager.stopUpdatingLocation()
//        }
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
        //self.locationManager.stopUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured \(error.localizedDescription)")
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }

}
