//
//  ReceiptVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 21/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import Cosmos

class ReceiptVC: UIViewController {

    @IBOutlet weak var lblJobID: UILabel!
    @IBOutlet weak var lblJobType: UILabel!
    @IBOutlet weak var lblJobStatus: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var btnBackToHome: UIButton!
    
    @IBOutlet var remarksTV: UITextView!
    
    
    @IBOutlet var jobType: UILabel!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPerson: UIImageView!
    
    @IBOutlet weak var ratingView: CosmosView!
    
    var jobInfoo = JobHistoryVO()
    var jobID = String()
    
    var rating : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnBackToHome.layer.cornerRadius = self.btnBackToHome.frame.height/2
        ratingView.didFinishTouchingCosmos =  didReceiveRating
        
        self.remarksTV.layer.cornerRadius = 5.0
        self.remarksTV.layer.borderWidth = 1.0
        self.remarksTV.layer.borderColor = UIColor.lightGray.cgColor
        
        callApijobDetail()
    }
    
    func didReceiveRating(rating : Double)
    {
        print("Rating received is \(rating)")
        self.rating = rating
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    func viewInitializer()
    {
        
        
        
        if jobInfoo.status == JobStatus.completed.rawValue {
            
            self.cosmosView.settings.fillMode = .precise
            self.cosmosView.rating = self.jobInfoo.providerRating
            self.jobType.text = self.jobInfoo.type.capitalized
            self.lblJobType.text = self.jobInfoo.categoryName.capitalized
            self.lblJobStatus.text = self.jobInfoo.status.capitalized
            self.lblAddress.text = self.jobInfoo.wheree
            self.lblTotalAmount.text = (Currency.currencyCode) + String(describing: self.jobInfoo.budget!)
            self.lblDate.text = DateUtil.getDateWithMonthAndDay(self.jobInfoo.when.dateFromISO8601!)
            self.lblName.text = self.jobInfoo.displayName.capitalized
            
            //let data = setImageWithUrl(url: self.jobInfoo.providerImageURL!)
            
            print(self.jobInfoo.providerImageURL as Any)
           
            
            let timeDuration = DateUtil.getTimeFromDates(self.jobInfoo.orderEndedTime.dateFromISO8601!, endTime: self.jobInfoo.orderStartedTime.dateFromISO8601!)
            
            print("Duration: \(timeDuration)")
            
            DispatchQueue.main.async {
                self.imgPerson.layer.cornerRadius = self.imgPerson.frame.height/2
               // self.imgPerson.image = UIImage(data: data!)
                
                var newStr = (self.jobInfoo.providerImageURL)! as String
                newStr.remove(at: (newStr.startIndex))
                let imageUrl = URLConfiguration.ServerUrl + newStr
                if let url = URL(string: imageUrl) {
                    //self.userImageView.kf.setImage(with: url)
                    
                    self.imgPerson.kf.setImage(with: url, placeholder: UIImage(named: "imagePlaceholder"), options: nil, progressBlock: nil) { (image, error, cacheTyle, uurl) in
                        //                    self.userBtn.setImage(image, for: .normal)
                    }
                    
                }
                
                
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnBackToHomeAction(_ sender: Any) {
        
        if rating == 0.0
        {
            showInfoAlertWith(title: "Information Required!", message: "Please rate your experience")
        }
        else
        {
            self.callApiForFeedback()
        }
    }
    
    func callApijobDetail() {
        
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        Api.jobHistoryApi.jobHistoryWith(jobID: self.jobID, completion: { (success : Bool, message : String, jobDetail : JobHistoryVO?) in
            hideProgressHud(viewController: self)
            if success {
                if jobDetail != nil {
                    
                    self.jobInfoo = jobDetail!
                    self.viewInitializer()
                    
                } else {
                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                }
            } else {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func callApiForFeedback()
    {
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = ["rating": self.rating, "details": remarksTV.text ?? "", "userId": AppUser.getUser()?._id ?? "", "jobId": self.jobID ] as [String:Any]
        
        showProgressHud(viewController: self)
        Api.jobHistoryApi.jobFeedback(jobID: self.jobID, params: params, completion: { (success : Bool, message : String) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                
                
                
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                      switch action.style{
                      case .default:
                                            self.dismiss(animated: true) {
                                                NotificationCenter.default.post(name: .gotoDashboardNotification, object: nil)
                                            }

                      case .cancel:
                            print("cancel")

                      case .destructive:
                            print("destructive")


                }}))
                self.present(alert, animated: true, completion: nil)
                

            }
            else
            {
                self.showInfoAlertWith(title: "Alert", message: message)
            }
        })
    }
    
    

}
