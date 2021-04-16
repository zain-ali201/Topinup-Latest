//
//  MyJobsVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 20/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import FSCalendar

class MyJobsVC: BaseViewController, UITableViewDataSource, UITableViewDelegate, FSCalendarDelegate {

    
    @IBOutlet weak var btnComplete: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var viewBarComplete: UIView!
    @IBOutlet weak var viewBarCancel: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var heightConstraintCalendar: NSLayoutConstraint!
    @IBOutlet weak var lblNoJobs: UILabel!
    
    var lightColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    enum JobCategory {
        case cancel, completed
    }
    
    var selectedJobCategory: JobCategory = .completed
    
    var allJobHistory = [JobHistoryVO]()
    var dataSource = [JobHistoryVO]()
    var allDataSource = [JobHistoryVO]()
    var selectiveJobID : String!
    var params : [String:Any]! = nil
    var selectedIndexPath = -1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendar.scope = .week
        self.viewInitializer()
        self.updateBottomBarView()
        
        let startOfDay = Calendar.current.startOfDay(for: Date()).iso8601
        self.callingCurrentJobsApi(date: startOfDay)
        self.setupSideMenu()
        self.calendar.select(Date())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    func viewInitializer() {
        
        self.tableView.register(UINib(nibName: "JobHistoryList", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.reloadData()
        
        
    }
    
    func updateJobCategoryViews(){
        
        dataSource = []
        for job in allDataSource {
            if selectedJobCategory == .completed && job.status == JobStatus.completed.rawValue {
               dataSource.append(job)
            } else if selectedJobCategory == .cancel && job.status == JobStatus.cancelled.rawValue {
                dataSource.append(job)
            }
        }
        if allDataSource.count == 0 {
            lblNoJobs.isHidden = false
            lblNoJobs.text = "You have no Jobs for this date"
        } else if allDataSource.count != 0 && dataSource.count == 0{
            lblNoJobs.text = "You have no \(selectedJobCategory == .cancel ? "cancelled":"completed") Jobs for this date"
            lblNoJobs.isHidden = false
        } else {
            lblNoJobs.isHidden = true
            
        }
        
        
        self.tableView.reloadData()
        self.updateBottomBarView()
        
        
    }
    
    func updateBottomBarView(){
        if selectedJobCategory == .completed {
            self.btnComplete.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.btnCancel.setTitleColor(lightColor, for: UIControl.State.normal)
            self.viewBarComplete.backgroundColor = UIColor.white
            self.viewBarCancel.backgroundColor = UIColor.clear
        
        } else {
            self.btnCancel.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.btnComplete.setTitleColor(lightColor, for: UIControl.State.normal)
            self.viewBarCancel.backgroundColor = UIColor.white
            self.viewBarComplete.backgroundColor = UIColor.clear
            
        }
    }
    
    
    func callingCurrentJobsApi(date : String) {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        
        self.params = ["created" : date] as [String:Any]
        
        
        
        
        showProgressHud(viewController: self)
        
        Api.jobHistoryApi.jobHistory(params: self.params, completion: { (success:Bool, message : String, jobHistory : [JobHistoryVO?]) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                if jobHistory != nil
                {
                    self.allJobHistory.removeAll()
                    self.dataSource.removeAll()
                    
                    
                    self.allJobHistory = jobHistory as! [JobHistoryVO]
                    self.dataSource = jobHistory as! [JobHistoryVO]
                    self.allDataSource = self.dataSource
                    self.updateJobCategoryViews()
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! JobHistoryListTVC
        cell.imgPerson.layer.cornerRadius = cell.imgPerson.frame.height/2
        cell.selectionStyle = .none
        let currentIndex = self.dataSource[indexPath.row]

//        var newStr = currentIndex.categoryImageURL!
//        //newStr.remove(at: (newStr.startIndex))
//        let imageURl = URLConfiguration.ServerUrl + "/" + newStr
//
//        print(imageURl)
//
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
//            {
//                DispatchQueue.main.async {
//                    cell.imgPerson.image = UIImage(data: data)
//                }
//            }
//        }

        var newStr = currentIndex.categoryImageURL! as String
        
        if newStr.first == "." {
            newStr.remove(at: (newStr.startIndex))
        }
        
        //        newStr.remove(at: (newStr.startIndex))
        //let imageUrl = URLConfiguration.ServerUrl + newStr
        let imageUrl = newStr
        
        cell.imgPerson.setImage(resource: imageUrl, placeholder: UIImage(named: "addphoto"))
        
       
        cell.imgPerson.layer.cornerRadius = cell.imgPerson.frame.height/2
        
        
        cell.lblName.text = currentIndex.categoryName
        cell.lblScheduleTime.text = DateUtil.getSimpleDateAndTime(currentIndex.when.dateFromISO8601!)
        cell.lblAddress.text = currentIndex.wheree
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        selectiveJobID = self.dataSource[indexPath.row]._id
//        selectedIndexPath = indexPath.row
//
//        self.performSegue(withIdentifier: "currentTojobStartDetailSegue", sender: nil)
        if selectedJobCategory == .completed && self.dataSource[indexPath.row].status == JobStatus.completed.rawValue {
            
            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
            vc.jobID = self.dataSource[indexPath.row]._id
            self.navigationController?.pushViewController(vc, animated: true)
        }else if selectedJobCategory == .cancel && self.dataSource[indexPath.row].status == JobStatus.cancelled.rawValue{
            
            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "RequestJobDetailVC_ID") as! RequestJobDetailVC
            vc.jobID = self.dataSource[indexPath.row]._id
            vc.jobInfo = self.dataSource[indexPath.row]
            vc.providerID = self.dataSource[indexPath.row].providerID ?? ""
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
       
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        
        heightConstraintCalendar.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {

        
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
//        let dateInString = String(describing: calendar.currentPage.iso8601)
        self.callingCurrentJobsApi(date: date.iso8601)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? JobStartDetailVC {
            controller.jobID = selectiveJobID
            controller.jobDetail = self.dataSource[selectedIndexPath]
        }
    }
    
    
    @IBAction func btnCanceledJobs(_ sender: Any) {
        selectedJobCategory = .cancel
        updateJobCategoryViews()
    }
    @IBAction func btnCompletedJobs(_ sender: Any) {
        selectedJobCategory = .completed
        updateJobCategoryViews()
    }
    
    

}
