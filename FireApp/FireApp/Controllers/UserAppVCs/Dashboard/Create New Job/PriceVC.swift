//
//  PriceVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 11/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

protocol SetPriceProtocol {
    func setPrice(type: String , budget : String)
}

class PriceVC: UIViewController
{
    @IBOutlet weak var imgHourlyActive: UIImageView!
    @IBOutlet weak var txtFixedPrice: UITextField!
    @IBOutlet weak var viewBackgroundOr: UIView!
    @IBOutlet weak var viewBackgroundHourlyActive: UIView!
    @IBOutlet weak var lblFixedOrHourly: UILabel!
    
    var isHourly = false
    var delegate : SetPriceProtocol!
    
    var selectedPriceType = String()
    var selectedBudget = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFixedPrice.placeholder = (Currency.currencyCode) + " 0.00"
        
        self.viewInitializer()
        self.viewInitializerForSavedParams()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func viewInitializer()
    {
        IQKeyboardManager.shared.enable = true
        self.viewBackgroundOr.layer.cornerRadius = self.viewBackgroundOr.frame.height/2
        
        let tapFirst = UITapGestureRecognizer(target: self, action: #selector(PriceVC.tappedHourlyActive))
        self.viewBackgroundHourlyActive.addGestureRecognizer(tapFirst)
        self.lblFixedOrHourly.text = "What's your budget (Fixed)"
    }
    
    func viewInitializerForSavedParams()
    {
        if selectedPriceType != "" && selectedBudget != ""
        {
            if selectedPriceType == "hourly"
            {
                isHourly = true
                self.lblFixedOrHourly.text = "What's your budget (Hourly)"
                self.imgHourlyActive.image = UIImage(named: "blueButton")
            }
            else if selectedPriceType == "fixed"
            {
                isHourly = false
                self.lblFixedOrHourly.text = "What's your budget (Fixed)"
                self.imgHourlyActive.image = UIImage(named: "selectbutton")
            }
            
            txtFixedPrice.text = selectedBudget
        }
    }
    
    @objc func tappedHourlyActive() {
        
        if isHourly
        {
            isHourly = false
            self.lblFixedOrHourly.text = "What's your budget (Fixed)"
            self.imgHourlyActive.image = UIImage(named: "selectbutton")
            
            //unselected//selectbutton
            // selected // blueButton
            
        }
        else
        {
            isHourly = true
            self.lblFixedOrHourly.text = "What's your budget (Hourly)"
            
            self.imgHourlyActive.image = UIImage(named: "blueButton")
        }
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        
        let validationResult = validateFields()
        if (validationResult == kResultIsValid)
        {
            if let delegate = delegate
            {
                if isHourly
                {
                    delegate.setPrice(type: "hourly", budget: self.txtFixedPrice.text!)
                }
                else
                {
                    delegate.setPrice(type: "fixed", budget: self.txtFixedPrice.text!)
                }
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            self.showInfoAlertWith(title: "Info Required", message: validationResult)
        }
    }
    
    func validateFields() -> String {
        
        var result = kResultIsValid
        
        let proposall = self.txtFixedPrice.text?.trimmed()
        
        if (proposall?.length())! < 1
        {
            result = "Please enter your price"
            return result
        }
        
        return result
        
    }

}
