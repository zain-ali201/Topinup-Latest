//
//  NewJobRequestVC.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 09/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit

enum PaymentEnum : String {
    
    case none = "none"
    case cash = "cash"
    case creditCard = "credit"
    
}

class NewJobRequestVC: UIViewController, SetLocationViewControllerDelegate, SetDateProtocol, SetJobDetailProtocol, SetPriceProtocol {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var viewBackgroundPickupLocation: UIView!
    @IBOutlet weak var viewBackgroundWhen: UIView!
    @IBOutlet weak var viewBackgroundJobDetail: UIView!
    @IBOutlet weak var viewBackgroundPrice: UIView!

    @IBOutlet weak var txtWhere: UITextField!
    @IBOutlet weak var txtWhen: UITextField!
    @IBOutlet weak var txtJobDetail: UITextField!
    @IBOutlet weak var txtPrice: UITextField!
    
    var selectedCategory = String()
    var selectedLocation : LocationVO?
    var selectedAddress = String()
    var selectedLatitude = Double()
    var selectedLongitude = Double()
    var selectedDate = Date()
    var selectedWhenEnum : WhenEnum!
    var selectedJobDetail = String()
    var selectedImagesArray = [UIImage]()
    var images = [String]()
    var selectedType = String()
    var selectedBudget = String()
    
    var params = NSMutableDictionary()
    var paymentEnum : PaymentEnum!
    
    var jobInfo : JobHistoryVO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedWhenEnum = WhenEnum.none
        loadJobHistory()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        viewInitializer()
    }
    
    @IBAction func btnBackAction(_ sender: Any)
    {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func loadJobHistory()
    {
         if jobInfo != nil
        {
            self.images = self.jobInfo.images;
            showProgressHud(viewController: self)
            self.selectedImagesArray.removeAll()
            for relativePath in self.images
            {
                var newStr = relativePath
                newStr.remove(at: (newStr.startIndex))
                let imageURl = URLConfiguration.ServerUrl + newStr
    
                DispatchQueue.global().async
                {
                    if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
                    {
                        DispatchQueue.main.async
                        {
                            let image = UIImage(data: data)!
                            self.selectedImagesArray.append(image)
                            hideProgressHud(viewController: self)

                            self.selectedAddress      = self.jobInfo.wheree
                            self.selectedLatitude     = self.jobInfo.latitude
                            self.selectedLongitude    = self.jobInfo.longitude
                            self.txtWhere.text        = self.jobInfo.wheree

                            self.setDate(date: self.jobInfo.when.dateFromISO8601!, mode: self.selectedWhenEnum)
                            self.setNewJobDetail(detail: self.jobInfo.details, images: self.selectedImagesArray)
                            self.setPrice(type: self.jobInfo.type, budget: self.jobInfo.budget)
                            self.selectedCategory = self.jobInfo.categoryID
                            
                        }
                    }
                }
            }
        }
    }
    
    func viewInitializer()
    {
        paymentEnum = PaymentEnum(rawValue: PaymentEnum.none.rawValue)
        
        let tapWhen = UITapGestureRecognizer(target: self, action: #selector(NewJobRequestVC.tappedWhen))
        self.viewBackgroundWhen.addGestureRecognizer(tapWhen)
        
        let tapWhere = UITapGestureRecognizer(target: self, action: #selector(NewJobRequestVC.tappedWhere))
        self.viewBackgroundPickupLocation.addGestureRecognizer(tapWhere)
        
        let tapJobDetail = UITapGestureRecognizer(target: self, action: #selector(NewJobRequestVC.tappedJobDetail))
        self.viewBackgroundJobDetail.addGestureRecognizer(tapJobDetail)
        
        let tapPrice = UITapGestureRecognizer(target: self, action: #selector(NewJobRequestVC.tappedPrice))
        self.viewBackgroundPrice.addGestureRecognizer(tapPrice)
    }
    
    func locationSelected(location : LocationVO)
    {
        self.selectedLocation = location
        self.selectedAddress = location.address
        self.selectedLatitude = location.latitude
        self.selectedLongitude = location.longitude
        self.txtWhere.text = location.address
    }
    
    func setDate(date: Date, mode: WhenEnum)
    {
        self.selectedDate = date
        self.selectedWhenEnum = mode
        self.txtWhen.text = DateUtil.getSimpleDateAndTime(self.selectedDate)
    }
    
    func setNewJobDetail(detail: String, images: [UIImage])
    {
        self.selectedJobDetail = detail
        self.selectedImagesArray = images
        self.txtJobDetail.text = self.selectedJobDetail
    }
    
    func setPrice(type: String, budget: String)
    {
        self.selectedBudget = budget
        self.selectedType = type
        self.txtPrice.text = (Currency.currencyCode) + " \(self.selectedBudget)"
    }
    
    @IBAction func btnCashAction(_ sender: Any)
    {
        paymentEnum = PaymentEnum(rawValue: PaymentEnum.cash.rawValue)
    }
    
    @IBAction func btnCreditCardAction(_ sender: Any)
    {
        paymentEnum = PaymentEnum(rawValue: PaymentEnum.creditCard.rawValue)
    }
    
    @IBAction func btnPostJobAction(_ sender: Any)
    {
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            if !Connection.isInternetAvailable()
            {
                Connection.showNetworkErrorView()
                return;
            }
            
            showProgressHud(viewController: self)
            Api.jobApi.createQuotationWith(with: self.params , detailImages: self.selectedImagesArray, completion: { (successful, msg) in
                hideProgressHud(viewController: self)
                
                if successful
                {
                    let alertController = UIAlertController(title: "Alert", message: msg, preferredStyle: .alert)
                    
                    let defaultAction = UIAlertAction(title: "Ok", style: .default) { (action) in
                        let _ = self.navigationController?.popToRootViewController(animated: true)
                    }
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                else
                {
                    self.showInfoAlertWith(title: "Oooppppsss", message: msg)
                }
            })
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
    }
    
    @objc func tappedWhere()
    {
        self.performSegue(withIdentifier: "setLocationSegue", sender: nil)
    }
    
    @objc func tappedWhen()
    {
        self.performSegue(withIdentifier: "whenSegue", sender: nil)
    }
    
    @objc func tappedJobDetail()
    {
        self.performSegue(withIdentifier: "getJobDetailSegue", sender: nil)
    }
    
    @objc func tappedPrice()
    {
        self.performSegue(withIdentifier: "priceSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? SetLocationVC
        {
            controller.delegate = self
            
            if selectedLocation != nil
            {
                controller.selectedNewJobLocation = selectedLocation!
            }
        }
        else if let whenController = segue.destination as? WhenVC
        {
            whenController.delegate = self
            whenController.selectedWhen = selectedWhenEnum
            whenController.selectedDate = selectedDate
        }
        else if let detailController = segue.destination as? GetJobDetailVC
        {
            detailController.delegate = self
            detailController.selectedJobDetail = selectedJobDetail
            detailController.selectedImagesArray = selectedImagesArray
        }
        else if let priceController = segue.destination as? PriceVC
        {
            priceController.delegate = self
            priceController.selectedPriceType = selectedType
            priceController.selectedBudget = selectedBudget
        }
    }
    
    func validateFields() -> String
    {
        var result = kResultIsValid
        
        let address = self.txtWhere.text?.trimmed()
        let when = self.txtWhen.text?.trimmed()
        let jobDetail = self.txtJobDetail.text?.trimmed()
        let price = self.selectedBudget.trimmed()
        
        if (address?.length())! < 1
        {
            result = "Please enter your Address"
            return result
        }
        else if (when?.length())! < 3
        {
            result = "Please choose schedule"
            return result
        }
        else if (jobDetail?.length())! < 1
        {
            result = "Please enter some job detail"
            return result
        }
//        else if (price.length()) < 1
//        {
//            result = "Please enter your price"
//            return result
//        }
        
        self.params = [
            "where" : self.selectedAddress,
            "when" : self.selectedDate.iso8601,
            "details" : self.selectedJobDetail,
            "type": self.selectedType,
            "budget": self.selectedBudget,
            "latitude": self.selectedLatitude.roundedStringValue(),
            "longitude": self.selectedLongitude.roundedStringValue(),
            "category": self.selectedCategory
            ] as NSMutableDictionary
        
        return result
        
    }
        

    func roundedStringValue () -> String
    {
        return String(format: "%.4f", self)
    }

}
