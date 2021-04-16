//
//  RequestJobDetailVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 21/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit
import Cosmos

class RequestJobDetailVC: UIViewController {

    @IBOutlet weak var viewInProgress: UIView!
    @IBOutlet weak var btnQuote: UIButton!
    @IBOutlet weak var btnPrimary: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollInnerView: UIView!
    
    @IBOutlet weak var heightConstraintsInnerScrollView: NSLayoutConstraint!
    @IBOutlet weak var viewBackgroundProposal: UIView!
    
    @IBOutlet var profileDetailView: UIView!
    @IBOutlet weak var imgViewPerson: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblCategoryName: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblQuoteType: UILabel!
    @IBOutlet weak var txtProposal: UITextView!
    
    @IBOutlet weak var viewAlphaPopup: UIView!
    @IBOutlet weak var viewBackgroundPopup: UIView!
    @IBOutlet weak var viewPopupHeader: UIView!
    @IBOutlet weak var btnCall: UIButton!
    @IBOutlet weak var btnMessage: UIButton!
    @IBOutlet weak var btnPopupOK: UIButton!
    @IBOutlet weak var cosmosView: CosmosView!
    @IBOutlet weak var lblProposalHeader: UILabel!
    @IBOutlet var jobStatus: UILabel!
    
    var jobID = String()
    var providerID: String = ""
    var requestID = String()
    
    var jobInfo : JobHistoryVO!
    var jobDetail : RequestJobDetailVO!
    var selectedJobStatus : JobStatus!
    let helpDesk = HelpdeskVC()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let tapViewProfile = UITapGestureRecognizer(target: self, action: #selector(ProfileDetail))
        profileDetailView.addGestureRecognizer(tapViewProfile)
        
        
        
        self.viewInitializer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if jobInfo != nil
        {
            if jobInfo.status == JobStatus.accepted.rawValue
            {
                self.jobAcceptedInitializer()
            }else if jobInfo.status == JobStatus.cancelled.rawValue
            {
                self.jobCanceledInitializer()
            }
        }
        else
        {
            self.callApijobDetail()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnOKAction(_ sender: Any) {
        popupHide()
    }
    
    @objc func ProfileDetail() {
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        vc.providerID   = providerID
        vc.jobID        = jobID
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func viewInitializer() {
        
        self.btnCancel.layer.cornerRadius = self.btnCancel.frame.height/2
        self.btnPrimary.layer.cornerRadius = self.btnPrimary.frame.height/2
        self.viewBackgroundProposal.layer.cornerRadius = 10
        self.viewBackgroundProposal.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        
        self.popupInitializer()
        self.view.layoutIfNeeded()
    }
    
    
    func callApijobDetail() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        Api.jobDetailApi.jobDetailWith(jobID: self.requestID, completion: { (success : Bool, message : String, jobDetail : RequestJobDetailVO?) in
            hideProgressHud(viewController: self)
            if success
            {
                if jobDetail != nil
                {
                    self.jobDetail = jobDetail
                    self.reloadButtonActions()
                    self.detailViewInitializer()
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
    
    func detailViewInitializer() {
        
        if self.jobDetail != nil
        {
            
            
            
            self.cosmosView.settings.fillMode = .precise
            self.cosmosView.rating = self.jobDetail.providerRating!
            
            self.lblName.text = self.jobDetail.providerName
            self.lblAddress.text = self.jobDetail.wheree
            self.lblQuoteType.text = self.jobDetail.type.capitalized
            self.lblCategoryName.text = self.jobDetail.category
            
            self.lblProposalHeader.text = "Proposal"
            
            if self.jobDetail.type == "hourly"
            {
                self.lblPrice.text = (Currency.currencyCode) + String(describing: self.jobDetail.requestRate!) + "/hr"
            }
            else if self.jobDetail.type == "fixed"
            {
                self.lblPrice.text = (Currency.currencyCode) + String(describing: self.jobDetail.requestRate!)
            }
            
            if self.jobDetail.requestProposal == ""
            {
                self.txtProposal.text = "No Proposal"
            }
            else
            {
                self.txtProposal.text = self.jobDetail.requestProposal
            }
            DispatchQueue.global().async {
                if let data = setImageWithUrl(url: self.jobDetail.providerProfileImage!)
                {
                
                    DispatchQueue.main.async {
                        self.imgViewPerson.layer.cornerRadius = self.imgViewPerson.frame.height/2
                        self.imgViewPerson.image = UIImage(data: data)
                    }
                
                }
            }
            
            //self.imagesCells = self.jobDetail.images
            self.view.layoutIfNeeded()
        }
    }
    
    func jobAcceptedInitializer() {

        if self.jobInfo != nil
        {
            self.cosmosView.settings.fillMode = .precise
            self.cosmosView.rating = self.jobInfo.providerRating ?? 0.0
            //        self.cosmosView.text = "0.0"

            self.lblName.text = self.jobInfo.displayName
            self.lblAddress.text = self.jobInfo.wheree
            self.jobStatus.text = self.jobInfo.status

            
            
            if self.jobInfo.type == "hourly"
            {
                self.lblPrice.text = (self.jobInfo.currency) + " " + (Int(self.jobInfo.budget as String)?.withCommas())! + "/hr"
            }
            else if self.jobInfo.type == "fixed"
            {
                self.lblPrice.text = (self.jobInfo.currency) + " " + (Int(self.jobInfo.budget as String)?.withCommas())!
            }

            self.lblQuoteType.text = self.jobInfo.type.capitalized

            self.lblProposalHeader.text = "Job Details"
            self.txtProposal.text = self.jobInfo.details

            //        self.txtProposal.text = "Provider have accepted your job."
            self.lblCategoryName.text = self.jobInfo.categoryName

            DispatchQueue.global().async {
                if let data = setImageWithUrl(url: self.jobInfo.providerImageURL ?? "")
                {
                
                    DispatchQueue.main.async {
                        self.imgViewPerson.layer.cornerRadius = self.imgViewPerson.frame.height/2
                        self.imgViewPerson.image = UIImage(data: data)
                    }
                
                }
            }

            //self.imagesCells = self.jobDetail.images
            
            self.reloadButtonActions()
            self.view.layoutIfNeeded()

        }
    }
    
    func jobCanceledInitializer() {

        if self.jobInfo != nil
        {
            self.cosmosView.settings.fillMode = .precise
            self.cosmosView.rating = self.jobInfo.providerRating ?? 0.0
            //        self.cosmosView.text = "0.0"

            self.lblName.text = self.jobInfo.displayName
            self.lblAddress.text = self.jobInfo.wheree
            self.jobStatus.text = self.jobInfo.status

            
            
            if self.jobInfo.type == "hourly"
            {
                self.lblPrice.text = (Currency.currencyCode) + String(describing: self.jobInfo.budget!) + "/hr"
            }
            else if self.jobInfo.type == "fixed"
            {
                self.lblPrice.text = (Currency.currencyCode) + String(describing: self.jobInfo.budget!)
            }

            self.lblQuoteType.text = self.jobInfo.type.capitalized

            self.lblProposalHeader.text = "Job Details"
            self.txtProposal.text = self.jobInfo.details

            //        self.txtProposal.text = "Provider have accepted your job."
            self.lblCategoryName.text = self.jobInfo.categoryName

            DispatchQueue.global().async {
                if let data = setImageWithUrl(url: self.jobInfo.providerImageURL ?? "")
                {
                
                    DispatchQueue.main.async {
                        self.imgViewPerson.layer.cornerRadius = self.imgViewPerson.frame.height/2
                        self.imgViewPerson.image = UIImage(data: data)
                    }
                
                }
            }
            //self.imagesCells = self.jobDetail.images
            
            self.reloadButtonActions()
            self.view.layoutIfNeeded()

        }
    }
    
    func reloadButtonActions()
    {
        if jobInfo != nil
        {
            
            if jobInfo.status == JobStatus.cancelled.rawValue
            {
                self.btnPrimary.setTitle("RE-POST", for: .normal)
                self.btnCancel.setTitle("CANCEL", for: .normal)
            }else{
                self.btnPrimary.setTitle("CONTACT", for: .normal)
                self.btnCancel.setTitle("CANCEL", for: .normal)
            }
            
            
            
            self.viewInProgress.isHidden = false
            //self.btnQuote.isHidden = false
        }
        else
        {
            if self.jobDetail.requestStatus == JobStatus.quoted.rawValue
            {
                self.btnPrimary.setTitle("ACCEPT", for: .normal)
                self.btnCancel.setTitle("REJECT", for: .normal)
                
                self.viewInProgress.isHidden = true
                //self.btnQuote.isHidden = true
            }
        }
    }
    
    @IBAction func btnQuoteAction(_ sender: Any) {
        
    }
    
    @IBAction func btnPrimaryAction(_ sender: Any) {
        
        if jobInfo != nil
        {
            if self.jobInfo.status == JobStatus.accepted.rawValue
            {
                self.popupShow()
                
               
                
                
            }else if jobInfo.status == JobStatus.cancelled.rawValue{
                
                
                
                let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "NewJobRequestVC_ID") as! NewJobRequestVC
                vc.jobInfo              =   self.jobInfo;
                
                self.navigationController?.pushViewController(vc, animated: true)
                
                
            }
        }
        else
        {
            if self.jobDetail.requestStatus == JobStatus.quoted.rawValue
            {
                self.selectedJobStatus = JobStatus.accepted
                self.jobStatusUpdate()
            }else if jobInfo.status == JobStatus.cancelled.rawValue{
                
            }
        }
    }
    
    @IBAction func btnCancelAction(_ sender: Any) {
        
        if jobInfo != nil
        {
            if self.jobInfo.status == JobStatus.accepted.rawValue || self.jobInfo.status == JobStatus.quoted.rawValue
            {
                self.selectedJobStatus = JobStatus.cancelled
                self.jobStatusUpdate()
            }
            else
            {
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            if self.jobDetail.jobStatus == JobStatus.accepted.rawValue || self.jobDetail.jobStatus == JobStatus.quoted.rawValue
            {
                self.selectedJobStatus = JobStatus.cancelled
                self.jobStatusUpdate()
            }else if self.jobDetail.requestStatus == JobStatus.quoted.rawValue
            {
                self.jobquoteRejecte()
                
            }else
            {
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func btnCallAction(_ sender: Any) {
        
        popupHide()
        
        var callNumber = String()
        
        if jobDetail != nil
        {
            callNumber = self.jobDetail.providerPhoneNumber!
        }
        else if jobInfo != nil
        {
            callNumber = self.jobInfo.providerPhone
        }
        
        let number = URL(string: "tel://" + callNumber)
        let alertController = UIAlertController(title: "Alert", message: "Are you Sure want to Call? Call Charges will be applied", preferredStyle: .alert)
        
        let defaultAction = UIAlertAction(title: "Yes", style: .default) { (action) in
            UIApplication.shared.openURL(number!)
        }
        let NoAction = UIAlertAction(title: "No", style: .cancel, handler: nil)
        alertController.addAction(defaultAction)
        alertController.addAction(NoAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func btnMessageAction(_ sender: Any) {
        
        
        let storyBoard = UIStoryboard(name: "Chat", bundle: nil)
        let vc = storyBoard.instantiateViewController(withIdentifier: "ChatDetailViewController") as! ChatDetailViewController
        
        
        
        if jobDetail != nil
        {
            vc.jobID = self.jobDetail._id
            vc.providerID = self.jobDetail.providerID ?? ""
            vc.clientID = self.jobDetail.clientID ?? ""
            vc.providerName = self.jobDetail.displayName ?? ""
            vc.providerCategory = self.jobDetail.category ?? ""
            vc.providerImageURL = self.jobDetail.profileImageURL ?? ""
        }
        else if jobInfo != nil
        {
            vc.jobID = self.jobInfo._id
            vc.providerID = self.jobInfo.providerID ?? ""
            vc.clientID     = self.jobInfo.clientID ?? ""
            vc.providerName = self.jobInfo.displayName ?? ""
            vc.providerCategory = self.jobInfo.categoryName ?? ""
            vc.providerImageURL = self.jobInfo.providerImageURL ?? ""
        }
        
        
        
        self.navigationController?.pushViewController(vc, animated: true)
        
        
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
        
        
        
        
        
        popupHide()
    }
    
    func jobStatusUpdate() {
        
        print(self.jobID)
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = [
            
            "status" : selectedJobStatus.rawValue,
            "provider" : self.providerID
            ] as [String: Any]
        
        showProgressHud(viewController: self)
        
        Api.jobApi.jobStatusUpdate(id: self.jobID, params: params, completion: { (success:Bool, message : String, jobDetail : RequestJobDetailVO?) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                self.showInfoAlert(title: "Alert", message: message, handler: {
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                })
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func jobquoteRejecte() {
        
        print(self.jobID)
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        let params = [
            "userType" : "client"
            ] as [String: Any]
        
        showProgressHud(viewController: self)
        
        Api.jobApi.jobQuoteReject(id: self.jobDetail._id, params: params, completion: { (success:Bool, message : String, jobDetail : RequestJobDetailVO?) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                self.showInfoAlert(title: "Alert", message: message, handler: {
                    let _ = self.navigationController?.popToRootViewController(animated: true)
                })
            }
            else
            {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
    
    func popupInitializer() {
        
        self.btnPopupOK.layer.cornerRadius = self.btnPopupOK.frame.height/2
        self.viewPopupHeader.layer.cornerRadius = 15
        self.viewBackgroundPopup.layer.cornerRadius = 15
    }
    
    func popupHide() {
        
        self.viewAlphaPopup.isHidden = true
        self.viewBackgroundPopup.isHidden = true
    }
    
    func popupShow() {
        
        self.viewAlphaPopup.isHidden = false
        self.viewBackgroundPopup.isHidden = false
    }
    
    func heightForView(text:String, font:UIFont, width:CGFloat) -> CGFloat
    {
        let label:UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.text = text
        label.sizeToFit()
        
        return label.frame.height
    }
    
}
