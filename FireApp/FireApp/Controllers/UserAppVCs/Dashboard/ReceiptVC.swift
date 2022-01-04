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
    var providerID = String()
    
    var rating : Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ratingView.didFinishTouchingCosmos =  didReceiveRating
        
        self.remarksTV.layer.cornerRadius = 5.0
        self.remarksTV.layer.borderWidth = 1.0
        self.remarksTV.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    func didReceiveRating(rating : Double)
    {
        print("Rating received is \(rating)")
        self.rating = rating
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func submitBtnAction(_ sender: Any) {
        
        if rating == 0.0
        {
            showInfoAlertWith(title: "Information Required!", message: "Please rate your experience")
        }
        else
        {
            self.callApiForFeedback()
        }
    }
    
    func callApiForFeedback()
    {
        if !Connection.isInternetAvailable()
        {
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = ["rating": self.rating, "details": remarksTV.text ?? "", "userId": AppUser.getUser()?._id ?? "", "raterId": self.providerID ] as [String:Any]
        
        showProgressHud(viewController: self)
        Api.jobHistoryApi.jobFeedback(jobID: self.jobID, params: params, completion: { (success : Bool, message : String) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                      switch action.style{
                      case .default:
                        self.navigationController?.popViewController(animated: true)
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
