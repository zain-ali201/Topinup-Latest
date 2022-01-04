//
//  ProviderListVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 17/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit
import Kingfisher
enum StatusEnum
{
    case invite
    case invited
    case inProgress
    case started
}

enum AssignJobStatus : String {
    
    case none = "none"
    case accepted = "accepted"
    case offered = "offered"
    case cancelled = "cancelled"
}

class ProviderListVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewAlpha: UIView!
    @IBOutlet weak var viewBackgroundPopup: UIView!
    @IBOutlet weak var viewBackgroundBlue: UIView!
    @IBOutlet weak var btnQuote: UIButton!
    @IBOutlet weak var btnHire: UIButton!
    @IBOutlet weak var viewBackgroundOr: UIView!
    @IBOutlet weak var btnOK: UIButton!
    
    @IBOutlet weak var nearbyBtn: UIButton!
    @IBOutlet weak var cityBtn: UIButton!
    @IBOutlet weak var nearbyLine: UIView!
    @IBOutlet weak var cityLine: UIView!
    
    var statusEnum : StatusEnum?
    
    var location:CLLocation?
    var latitude = Double()
    var longitude = Double()
    var jobID = String()
    var allNearbyProvidersList = [NearbyProviderVO]()
    
    var isQuoteSelected = false
    var isHireSelected = false
    
    var selectedProviderIndex = -1
    var selectedType = String()
    var selectedProviderID = String()
    var selectedProviderIDForStatus = String()
    var selectedRequestID = String()
    
    var selectedID = String()
    
    var type = "nearby"

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if location != nil
        {
            getAddress(location: location!)
        }
        
        self.tableView.isHidden = true
        self.popupInitializer()
        self.callApiNearybyProviderList()
        self.btnQuoteUnSelected()
        self.btnHireUnSelected()
        
        var assignJobStatus : AssignJobStatus!
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderListVC.didReceiveSocketConectionResponse(notification:)), name: .kSocketConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(ProviderListVC.didReceiveSocketDisconectResponse(notification:)), name: .kSocketDisconnected, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func typeAction(button: UIButton)
    {
        if button.tag == 1001
        {
            type = "near"
            nearbyBtn.setTitleColor(.black, for: .normal)
            cityBtn.setTitleColor(.gray, for: .normal)
            nearbyLine.isHidden = false
            cityLine.isHidden = true
            self.allNearbyProvidersList.removeAll()
            self.callApiNearybyProviderList()
        }
        else
        {
            type = "city"
            cityBtn.setTitleColor(.black, for: .normal)
            nearbyBtn.setTitleColor(.gray, for: .normal)
            nearbyLine.isHidden = true
            cityLine.isHidden = false
            self.allNearbyProvidersList.removeAll()
            callApiCityProviderList()
        }
    }
    
    @IBAction func btnPopupCrossAction(_ sender: Any)
    {
        self.popupHide()
    }
    
    func popupInitializer()
    {
        self.btnQuote.layer.cornerRadius = self.btnQuote.frame.height/2
        self.btnOK.layer.cornerRadius = self.btnOK.frame.height/2
        self.btnHire.layer.cornerRadius = self.btnHire.frame.height/2
        self.viewBackgroundOr.layer.cornerRadius = self.viewBackgroundOr.frame.height/2
//        self.viewBackgroundBlue.layer.cornerRadius = 15
        self.viewBackgroundPopup.layer.cornerRadius = 15
    }
    
    func popupHide()
    {
        self.viewAlpha.isHidden = true
        self.viewBackgroundPopup.isHidden = true
    }
    
    func popupShow()
    {
        self.viewAlpha.isHidden = false
        self.viewBackgroundPopup.isHidden = false
        
        if self.allNearbyProvidersList[selectedProviderIndex].request != "none"
        {
            if self.allNearbyProvidersList[selectedProviderIndex].type == "quote"
            {
                self.btnQuote.setTitle("Invited", for: .normal)
            }
            else
            {
                self.btnQuote.setTitle("Request Quotation", for: .normal)
            }
            
            if self.allNearbyProvidersList[selectedProviderIndex].type == "hire"
            {
                self.btnHire.setTitle("Hired", for: .normal)
            }
            else
            {
                self.btnHire.setTitle("Want to Hire", for: .normal)
            }
        }
        else
        {
            self.btnQuote.setTitle("Request Quotation", for: .normal)
            self.btnHire.setTitle("Want to Hire", for: .normal)
        }
    }
    
    func btnQuoteSelected()
    {
        self.btnQuote.backgroundColor = UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1)
    }
    
    func btnQuoteUnSelected()
    {
        self.btnQuote.backgroundColor = UIColor.white
        self.btnQuote.layer.borderWidth = 1
        self.btnQuote.layer.borderColor = UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1).cgColor
    }
    
    func btnHireSelected()
    {
        self.btnHire.backgroundColor = UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1)
    }
    
    func btnHireUnSelected() {
        
        self.btnHire.backgroundColor = UIColor.white
        self.btnHire.layer.borderWidth = 1
        self.btnHire.layer.borderColor = UIColor(red: 19/255, green: 151/255, blue: 245/255, alpha: 1).cgColor
    }
    
    func callApiNearybyProviderList() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = [
        
            "latitude" : self.latitude,
            "longitude" : self.longitude
        ] as [String: Any]
        
        showProgressHud(viewController: self)
        
        Api.nearbyProviderApi.getNearbyProviderList(id: self.jobID, params: params, completion: { (success:Bool, message : String, nearybyProviders : [NearbyProviderVO]?) in
            
            hideProgressHud(viewController: self)
            
            if success {
                
                if nearybyProviders != nil
                {
                    self.tableView.isHidden = false
                    self.allNearbyProvidersList = nearybyProviders!
                    self.tableView.reloadData()
                }
                else
                {
                    self.showInfoAlertWith(title: "Internal Error", message: message)
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func callApiCityProviderList() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        let city = UserDefaults.standard.string(forKey: "UserCity")
        
        Api.nearbyProviderApi.getCityProviderList(id: self.jobID, city: city ?? "", completion: { (success:Bool, message : String, nearybyProviders : [NearbyProviderVO]?) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                if nearybyProviders != nil
                {
                    self.tableView.isHidden = false
                    self.allNearbyProvidersList = nearybyProviders!
                    self.tableView.reloadData()
                }
                else
                {
                    self.showInfoAlertWith(title: "Internal Error", message: message)
                }
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    @IBAction func btnQuoteAction(_ sender: Any)
    {
        if isQuoteSelected
        {
            isQuoteSelected = false
            self.btnQuoteUnSelected()
        }
        else
        {
            isQuoteSelected = true
            isHireSelected = false
            self.btnQuoteSelected()
            self.btnHireUnSelected()
        }
    }
    
    @IBAction func btnHireAction(_ sender: Any)
    {
        if isHireSelected
        {
            isHireSelected = false
            self.btnHireUnSelected()
        }
        else
        {
            isHireSelected = true
            isQuoteSelected = false
            self.btnHireSelected()
            self.btnQuoteUnSelected()
        }
    }
    
    @IBAction func btnOKAction(_ sender: Any)
    {
        self.popupHide()
        if isQuoteSelected
        {
            self.selectedType = "quote"
            self.selectedProviderID = allNearbyProvidersList[selectedProviderIndex]._id
            apiCallRequestInvitation()
        }
        else if isHireSelected
        {
            self.selectedType = "hire"
            self.selectedProviderID = allNearbyProvidersList[selectedProviderIndex]._id
            apiCallRequestInvitation()
        }
        else if self.allNearbyProvidersList[selectedProviderIndex].status == "invite" ||
            self.allNearbyProvidersList[selectedProviderIndex].status == "hire" {
            showInfoAlertWith(title: "Alert", message: "You must select an option")
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allNearbyProvidersList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! NearbyProviderTVC
        cell.selectionStyle = .none
        
        let currentIndex = self.allNearbyProvidersList[indexPath.row]
        
        cell.lblName.text = currentIndex.displayName
        cell.lblDetail.text = currentIndex.categories
        
//        if currentIndex.status == JobStatus.quoted.rawValue
//        {
//            cell.lblPrice.text = (Currency.currencyCode) + String(describing: currentIndex.rate!)
//        }
//        else
//        {
//            cell.lblPrice.text =  (Currency.currencyCode) + "\(currentIndex.hourlyRate!)"
//        }
        var newStr = currentIndex.profileImageURL! as String
        
        if newStr.first == "." {
            newStr.remove(at: (newStr.startIndex))
        }

        let imageUrl = URLConfiguration.ServerUrl + newStr
        if let url = URL(string: imageUrl) {
            //cell.imgView.kf.setImage(with: url, placeholder: UIImage(named: "addphoto"), options: nil, progressBlock: nil, completionHandler: nil)
            
            cell.imgView.kf.setImage(
                with: url,
                placeholder: UIImage(named: "addphoto"),
                options: nil)
            {
                result in
                switch result {
                case .success(let value):
                    print("Task done for: \(value.source.url?.absoluteString ?? "")")
                case .failure(let error):
                    print("Job failed: \(error.localizedDescription)")
                }
            }
            
        }
        cell.imgView.layer.cornerRadius = cell.imgView.frame.height/2
        
        if currentIndex.status == JobStatus.invited.rawValue || currentIndex.status == JobStatus.hired.rawValue || currentIndex.status == JobStatus.quoted.rawValue
        {
            cell.btnQuote.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
            cell.btnQuote.setTitleColor(UIColor.black, for: UIControl.State.normal)
        }
        else
        {
            cell.btnQuote.backgroundColor = UIColor(red: 0/255, green: 170/255, blue: 247/255, alpha: 1)
            cell.btnQuote.setTitleColor(UIColor.white, for: UIControl.State.normal)
        }
        
        cell.btnQuote.setTitle(currentIndex.status, for: .normal)
        cell.btnQuote.layer.cornerRadius = cell.btnQuote.frame.height/2
        cell.btnQuote.tag = indexPath.row
        cell.btnQuote.addTarget(self, action: #selector(ProviderListVC.btnQuoteActionCell), for: UIControl.Event.touchUpInside)
        
        cell.cosmosView.settings.fillMode = .precise
        cell.cosmosView.rating = currentIndex.rating ?? 0.0
        
        
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 105
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.providerID = allNearbyProvidersList[indexPath.row]._id
        vc.jobID = jobID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ())
    {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds)
        {
            completion()
        }
    }
    
    @objc func btnQuoteActionCell(sender:UIButton)
    {
        self.selectedProviderIndex = sender.tag
        if allNearbyProvidersList[self.selectedProviderIndex].status == JobStatus.quoted.rawValue
        {
            self.selectedProviderIDForStatus = allNearbyProvidersList[self.selectedProviderIndex].providerID
            self.selectedRequestID = allNearbyProvidersList[self.selectedProviderIndex].requestID
            self.performSegue(withIdentifier: "RequestJobDetailSegue", sender: nil)
        }
        else if allNearbyProvidersList[self.selectedProviderIndex].status == JobStatus.invited.rawValue
        {
        }
        else
        {
            self.popupShow()
        }
    }
    
    func apiCallRequestInvitation()
    {
        print(self.jobID)
        print(self.selectedType)
        print(self.selectedProviderID)
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = [
            
            "type" : self.selectedType,
            "provider" : self.selectedProviderID
            ] as [String: Any]
        
        showProgressHud(viewController: self)
        Api.nearbyProviderApi.requestInvitation(id: self.jobID, params: params, completion: { (success:Bool, message : String) in
            hideProgressHud(viewController: self)
            if success {
                
                let alertController = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                
                let defaultAction = UIAlertAction(title: "OK", style: .default){(action)
                    in
                    //let _ = self.navigationController?.popViewController(animated: true)
                    if self.type == "near"
                    {
                        self.callApiNearybyProviderList()
                    }
                    else
                    {
                        self.callApiCityProviderList()
                    }
                }
                
                alertController.addAction(defaultAction)
                
                self.present(alertController, animated: true, completion: nil)
                
            } else {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    @objc func didReceiveSocketDisconectResponse(notification : Notification)
    {
    }
    
    @objc func didReceiveSocketConectionResponse(notification : Notification)
    {
        hideProgressHud(viewController: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? RequestJobDetailVC
        {
            controller.jobID = self.jobID
            controller.jobInfo = nil
            controller.providerID = self.selectedProviderIDForStatus
            controller.requestID = self.selectedRequestID
        }
    }
}

func getAddress(location: CLLocation) {
        let geoCoder: CLGeocoder = CLGeocoder()

    geoCoder.reverseGeocodeLocation(location, completionHandler:
    {(placemarks, error) in
        if (error != nil)
        {
            print("reverse geodcode fail: \(error!.localizedDescription)")
        }
        let pm = placemarks! as [CLPlacemark]

        if pm.count > 0 {
            let pm = placemarks![0]
            
            if pm.locality != nil {
                UserDefaults.standard.set(pm.locality, forKey: "UserCity")
            }
            if pm.country != nil {
                UserDefaults.standard.set(pm.locality, forKey: "UserCountry")
            }
        }
    })
}
