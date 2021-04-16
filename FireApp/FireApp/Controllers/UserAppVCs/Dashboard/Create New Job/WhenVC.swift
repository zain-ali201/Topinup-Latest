//
//  WhenVC.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 09/01/2018.
//  Copyright © 2018 yamsol. All rights reserved.
//

import UIKit

enum WhenEnum {
    case none
    case now
    case later
}

protocol SetDateProtocol {
    func setDate(date : Date, mode : WhenEnum)
}

class WhenVC: UIViewController {

    @IBOutlet weak var viewBackgroundNow: UIView!
    @IBOutlet weak var viewBackgroundOr: UIView!
    @IBOutlet weak var viewBackgroundSchedule: UIView!
    @IBOutlet weak var viewBackgroundPickerView: UIView!
    @IBOutlet weak var imgNow: UIImageView!
    @IBOutlet weak var imgSchedule: UIImageView!
    @IBOutlet weak var lblLaterScheduleDate: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var pickerView: UIDatePicker!
    @IBOutlet weak var btnDone: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewBackgroundAlpha: UIView!
    
    var selectedWhen : WhenEnum!
    var selectedDate = Date()
    var delegate : SetDateProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewInitializer()
        self.viewInitializerForSelectedMode()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func viewInitializer()
    {
        self.viewBackgroundPickerView.isHidden = true
        self.viewBackgroundAlpha.isHidden = true
        self.viewBackgroundOr.layer.cornerRadius = self.viewBackgroundOr.frame.height/2
        
        let tapWhen = UITapGestureRecognizer(target: self, action: #selector(WhenVC.tappedNow))
        self.viewBackgroundNow.addGestureRecognizer(tapWhen)
        
        let tapLater = UITapGestureRecognizer(target: self, action: #selector(WhenVC.tappedLater))
        self.viewBackgroundSchedule.addGestureRecognizer(tapLater)
    }
    
    func viewInitializerForSelectedMode()
    {
        if selectedWhen != WhenEnum.none
        {
            if selectedWhen == WhenEnum.now
            {
                self.imgNow.image = UIImage(named: "blueButton")
            }
            else if selectedWhen == WhenEnum.later
            {
                self.imgNow.image = UIImage(named: "selectbutton")
            }
            
            self.lblLaterScheduleDate.text = DateUtil.getSimpleDateAndTime(self.selectedDate)
        }
    }
    
    @objc func tappedNow() {
        
        selectedDate = Date()
        selectedWhen = WhenEnum.now
        self.imgNow.image = UIImage(named: "blueButton")
    }
    
    @objc func tappedLater() {
        
        self.imgNow.image = UIImage(named: "selectbutton")
        selectedWhen = WhenEnum.later
        self.viewBackgroundPickerView.isHidden = false
        self.viewBackgroundAlpha.isHidden = false
        self.viewBackgroundAlpha.alpha = 0.4
    }
    
    @IBAction func btnSaveAction(_ sender: Any) {
        
        if selectedWhen != WhenEnum.none
        {
            if let delegate = delegate
            {
                delegate.setDate(date: selectedDate, mode : selectedWhen)
                let _ = self.navigationController?.popViewController(animated: true)
            }
        }
        else
        {
            showInfoAlertWith(title: "Alert", message: "You must select schedule")
        }
    }
    
    @IBAction func btnDone(_ sender: Any) {
        
        self.pickerView.minimumDate = Date()
        self.selectedDate = pickerView.date
        self.lblLaterScheduleDate.text = DateUtil.getSimpleDateAndTime(self.selectedDate)
        self.viewBackgroundPickerView.isHidden = true
        self.viewBackgroundAlpha.isHidden = true
    }
    
    
    @IBAction func btnCancelAction(_ sender: Any) {
        self.viewBackgroundPickerView.isHidden = true
        self.viewBackgroundAlpha.isHidden = true
    }


}
