//
//  SetLocationViewController.swift
//  Neighbourhoods
//
//  Created by Zain ul Abideen on 28/09/2017.
//  Copyright © 2017 Hanan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import GoogleMaps
import GooglePlaces

public typealias LocationUpdateSuccess = ((CLLocationCoordinate2D, String) -> Void)

protocol SetLocationViewControllerDelegate
{
    func locationSelected(location : LocationVO)
}

class SetLocationVC: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    
    var delegate : SetLocationViewControllerDelegate?
    
    let locationManager = CLLocationManager()
    var region = MKCoordinateRegion()

    var nearbyPlacesList = [(id : String, name : String, lat : Double, long : Double)]()
    var selectedCoordinates = CLLocationCoordinate2D()
    var selectedAddress = String()
    var placesClient = GMSPlacesClient()
    var counter = 0
    static var isFromSource = false
    static var isFromRequest = false
    static var isFromNeighbourCabView = false
    static var isFromHomeLocation = false
    
    static var sourceLocation : LocationVO?
    static var destinationLocation : LocationVO?
    
    var selectedNewJobLocation : LocationVO?
    
    var isAutomaticLocationPickup : Bool!
    
    var params : [String:Any] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SetLocationVC.dismissKeyboard))
        self.mapView.addGestureRecognizer(tap)
        
        self.mapView.reloadInputViews()
        self.tableView.alpha = 0
        self.tableView.layer.cornerRadius = 10
        
        isAutomaticLocationPickup = true
        
        if self.selectedNewJobLocation != nil
        {
            setMapCentred(aroundLocation: (selectedNewJobLocation?.coordinate)!)
            process(foundLocation: (selectedNewJobLocation?.coordinate)!)
        }
        else
        {
            self.locationManager.delegate = self
            self.mapView.delegate = self
            self.locationManager.startUpdatingLocation()
            self.mapView.showsUserLocation = true
            self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
            self.locationManager.requestWhenInUseAuthorization()
            self.locationManager.requestLocation()
            self.locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnDonePressed(_ sender: Any) {
        
        if selectedAddress != "" {
            
            let selectedLocation = LocationVO(lat: selectedCoordinates.latitude, long: selectedCoordinates.longitude, addr: selectedAddress)
            
            if let delegate = delegate
            {
                delegate.locationSelected(location: selectedLocation)
                self.navigationController?.popViewController(animated: true)
                return;
            }
  
        } else {
            self.showAlert(title: "Input Required", message: "Please select a location first")
        }
    }
    
    @IBOutlet weak var btnCurrentLocation: UIButton!
    
    @IBAction func btnCurrentLocation(_ sender: Any) {
        locationManager.startUpdatingLocation()
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
//        self.counter += 1
//
//        if self.counter > 2 {
//            process(foundLocation: coordinate)
//        }
        process(foundLocation: coordinate)
        
    }
    
    func process(foundLocation : CLLocationCoordinate2D)
    {
        //setMapCentred(aroundLocation: foundLocation)
        
        reverseGeocodeCoordinate(coordinate: foundLocation) { (location : CLLocationCoordinate2D, address : String) in
            
            print(address)
            print(foundLocation.latitude)
            print(foundLocation.longitude)
        }
    }
    
    func setMapCentred(aroundLocation location : CLLocationCoordinate2D) {

        self.locationManager.startUpdatingLocation()
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
        self.locationManager.stopUpdatingLocation()
        
    }
    
    func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D, onSuccess : @escaping LocationUpdateSuccess) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            if let address = response?.firstResult() {
                if let lines = address.lines! as? [String] {
                    let title = lines.joined(separator: " ")
                    if (title.count) > 3 {
                        print("/////////////////////////////////////////////////////////////\n////////////////////////////////////////////////////////////")
                        print(title)
                        // To keep the search bar empty from first automatic location pick up
                        if (self.isAutomaticLocationPickup == true)
                        {
                            self.isAutomaticLocationPickup = false
                        }
                        else
                        {
                            self.searchBar.text = title
                        }

                        
                        let coordinate = CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        
                        self.selectedCoordinates = coordinate
                        self.selectedAddress = title
                        
                        //self.searchNearbyPlaces(searchText: self.searchBar.text!)
                        onSuccess(coordinate, title)
                    }
                }
            }
        }
    }
    
//    func autoCompleteQuery(searchText: String) {
//
//        if searchText.characters.count != 0 {
//            self.tableView.alpha = 1
//
////            let countryFilter = GMSAutocompleteFilter()
////            countryFilter.country = "US"
//
//
//            var areaBounds : GMSCoordinateBounds? = nil
//            if let lastSavedLocation = DashboardVC.lastSavedLocation
//            {
//                let lat = lastSavedLocation.coordinate.latitude
//                let long = lastSavedLocation.coordinate.longitude
//
//                let offset = 200.0 / 1000.0;
//                let latMax = lat + offset;
//                let latMin = lat - offset;
//                let lngOffset = offset * cos(lat * M_PI / 200.0);
//                let lngMax = long + lngOffset;
//                let lngMin = long - lngOffset;
//                let initialLocation = CLLocationCoordinate2D(latitude: latMax, longitude: lngMax)
//                let otherLocation = CLLocationCoordinate2D(latitude: latMin, longitude: lngMin)
//                areaBounds = GMSCoordinateBounds(coordinate: initialLocation, coordinate: otherLocation)
//            }
//
//            placesClient.autocompleteQuery(searchText, bounds: areaBounds, filter: nil, callback: { (result, error) -> Void in
//
//                self.nearbyPlacesList.removeAll()
//
//                if result == nil
//                {
//                    return;
//                }
//
//                for result in result!
//                {
//                    if let result = result as? GMSAutocompletePrediction {
//                        self.nearbyPlacesList.append((id: result.placeID, name: result.attributedFullText.string))
//                        self.tableView.reloadData()
//                    }
//                }
//            })
//        }
//        else
//        {
//            self.tableView.alpha = 0
//        }
//    }
    
    func autoCompleteQuery(searchText: String) {
        
        if searchText.count != 0 {
            self.tableView.alpha = 1
            
            if !Connection.isInternetAvailable()
            {
                print("FIXXXXXXXX Internet not connected")
                Connection.showNetworkErrorView()
                return;
            }
            
            
            
            showProgressHud(viewController: self)
            
            self.params = [
                "text" :  searchText
                ] as! [String: Any]
            
            
            Api.placesApi.autoComplete(params: self.params, completion: { (success:Bool, message : String, placesName : [PlacesVO?]) in
                
                hideProgressHud(viewController: self)
                
                if success
                {
                    if placesName != nil
                    {
                        self.nearbyPlacesList.removeAll()
                        for result in placesName
                                        {
                                            self.nearbyPlacesList.append((id: result!._id, name: result!.place_name, lat: result!.latitude!, long: result!.longitude!))
                                        }
                        self.tableView.reloadData()
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
        else
        {
            self.tableView.alpha = 0
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured \(error.localizedDescription)")
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.autoCompleteQuery(searchText: searchText)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyPlacesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = UIColor.white
        cell.selectionStyle = .none

        if (indexPath.row >= nearbyPlacesList.count)
        {
            return cell
        }
        self.tableViewHeightConstraint.constant = CGFloat(55 * self.nearbyPlacesList.count)
        self.tableView.layoutIfNeeded()
        cell.textLabel?.text = self.nearbyPlacesList[indexPath.row].name
        cell.textLabel?.textColor = UIColor.darkGray
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.searchBar.text = self.nearbyPlacesList[indexPath.row].name
        self.tableView.alpha = 0
        
        self.selectPlace(lat: self.nearbyPlacesList[indexPath.row].lat, long: self.nearbyPlacesList[indexPath.row].long, name: self.nearbyPlacesList[indexPath.row].name)
        
        
        
    }
    
    func selectPlace(lat: Double, long: Double, name: String) {
        
        let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        self.selectedCoordinates = coordinate
        self.selectedAddress = name ?? ""
        self.setMapCentred(aroundLocation: coordinate)
        self.tableView.alpha = 0
        
        
        
//        placesClient.lookUpPlaceID(id, callback: { (places, error) -> Void in
//            if error != nil {
//                print("lookup place id query error: \(error!.localizedDescription)")
//                return
//            }
        
//            if let place = places {
//                let coordinate = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
//                self.selectedCoordinates = coordinate
//                self.selectedAddress = place.name ?? ""
//                self.setMapCentred(aroundLocation: coordinate)
//                self.tableView.alpha = 0
//            } else {
//                print("No place details for \(places?.placeID)")
//            }
//        })
    }
    
    func showAlert (title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(defaultAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard()
    {
        self.view.endEditing(true)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    

}
 
