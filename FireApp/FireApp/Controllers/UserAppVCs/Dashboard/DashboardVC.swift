//
//  DashboardVC.swift
//  Neighboorhood-iOS-Services
//
//  Created by Zain ul Abideen on 18/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import FSCalendar
import SideMenu

extension Notification.Name {
    static let reloadDashboardJobs = Notification.Name("reloadDashboardJobs")
    static let loadHelpDeskPop = Notification.Name("loadHelpDeskPop")
}

class DashboardVC: BaseViewController, MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, FSCalendarDelegate {

    static let KEY_UNREAD_MESSAGES : String = "unreadMessages"
    
    
    @IBOutlet weak var btnMap: UIButton!
    @IBOutlet weak var btnList: UIButton!
    @IBOutlet weak var viewBarMap: UIView!
    @IBOutlet weak var viewBarList: UIView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewBackgroundMap: UIView!
    @IBOutlet weak var viewBackgroundListView: UIView!
    @IBOutlet weak var btnCreateNewJob: UIButton!
    @IBOutlet weak var FSCalendar: FSCalendar!
    @IBOutlet weak var heightConstraintsCalendar: NSLayoutConstraint!
    @IBOutlet weak var lblNoJobs: UILabel!
    @IBOutlet weak var viewBottomActive: UIView!
    @IBOutlet weak var viewBottomCompleted: UIView!
    
    enum JobCategory {
        case active, completed
    }
    
    
    var selectedJobCategory: JobCategory = .active
    
    var isMapActive = false
    var lightColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1)
    
    let locationManager = CLLocationManager()
    var region = MKCoordinateRegion()
    let user = AppUser.getUser()
    
    var allJobHistory = [JobHistoryVO]()
    var dataSource = [JobHistoryVO]()
    var allDataSource = [JobHistoryVO]()
    let notificationButton = SSBadgeButton()
    var params : [String:Any] = [:]

    var annotationArray : [MKAnnotation] = []
    var annotationImageView : UIImage!
    var child : JobHistoryVO!
    var jobDotIndicator = false
    static var lastSavedLocation : CLLocation?
    
    var selectedIndex = Int()
    
    var selectiveJobID : String!
    var selectedDate = Calendar.current.startOfDay(for: Date()).iso8601
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupChatButton()
        self.tableView.register(UINib(nibName: "JobList", bundle: nil), forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.viewInitializer()
        self.mapViewInitializer()
        
        annotationArray = [MKAnnotation]()
        
//        delayWithSeconds(1.5) {
//
//            let startOfDay = Calendar.current.startOfDay(for: Date()).iso8601
//            self.handymanNearbyCallingApi(date: startOfDay)
//        }
        
        //print("Token: \(user?.token)")
        
        SocketManager.shared.establishConnection()
        
        
    
        self.FSCalendar.select(Date())
        self.setupSideMenu()
        //updateJobCategoryBottomViews()
        self.addObservers()
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.getUserLocation()
        self.getUnreadMessageCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if DashboardVC.lastSavedLocation != nil
        {
            self.handymanNearbyCallingApi(date: self.selectedDate)
            
        }
        updateJobCategoryBottomViews()
    }
    
    func addObservers()
    {
        
         
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.didReceiveSocketConectionResponse(notification:)), name: .kSocketConnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(DashboardVC.didReceiveSocketDisconectResponse(notification:)), name: .kSocketDisconnected, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadDashboardJobs(_:)), name: .reloadDashboardJobs, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.didReceiveUnreadMessageResponse), name: NSNotification.Name.kGetUnreadMsgs, object: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func reloadDashboardJobs(_ botification: Notification){
        self.handymanNearbyCallingApi(date: self.selectedDate)
    }
    
    
    func setupChatButton(){
        notificationButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        notificationButton.setImage(UIImage(named: "chatWhite"), for: .normal)
        notificationButton.addTarget(self, action: #selector(self.gotoMessages), for: .touchUpInside)
        notificationButton.badgeEdgeInsets = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 8)
        
        notificationButton.badge = "\(UserDefaults.standard.integer(forKey: DashboardVC.KEY_UNREAD_MESSAGES))"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: notificationButton)
    }
    
    @objc func gotoMessages(){
        NotificationCenter.default.post(name: .gotoMessagesNotification, object: nil)
    }
    
    @objc func didReceiveUnreadMessageResponse(notification : Notification)
    {
        
        if let userInfo = notification.userInfo as NSDictionary?
        {
            UserDefaults.standard.set(userInfo["count"] as? Int ?? 0, forKey: DashboardVC.KEY_UNREAD_MESSAGES)
            UserDefaults.standard.synchronize()
            UIApplication.shared.applicationIconBadgeNumber = UserDefaults.standard.integer(forKey: DashboardVC.KEY_UNREAD_MESSAGES)
            
            let unreadCount: Int = userInfo["count"] as! Int
            
            if(unreadCount != 0){
                self.notificationButton.badge =  "\(unreadCount)"
            }
            
            
            
            
            
            
            
            
        }
    }
    @objc func didReceiveSocketDisconectResponse(notification : Notification)
    {
        
    }
    
    @objc func didReceiveSocketConectionResponse(notification : Notification)
    {
        
        self.getUnreadMessageCount()
        
    }
    
    func getUnreadMessageCount(){
        
        
        let params = ["userId": user?._id ?? ""] as [String : Any]
        SocketManager.shared.sendSocketRequest(name: SocketEvent.getUnreadMsgs, params: params)
        
    }
    
    func updateJobCategoryBottomViews(){
        self.plottingJobsOnMap(handyman: self.allJobHistory)
        viewBottomActive.isHidden = selectedJobCategory != .active
        viewBottomCompleted.isHidden = !viewBottomActive.isHidden
        dataSource = []
        for job in allDataSource {
            if selectedJobCategory == .completed && job.status == JobStatus.completed.rawValue {
                dataSource.append(job)
            } else if selectedJobCategory == .active && job.status != JobStatus.completed.rawValue {
                dataSource.append(job)
            }
        }
        if allDataSource.count == 0 {
            lblNoJobs.isHidden = false
            lblNoJobs.text = "You have no Jobs for this date"
        } else if allDataSource.count != 0 && dataSource.count == 0{
            lblNoJobs.text = "You have no \(selectedJobCategory == .active ? "active":"completed") Jobs for this date"
            lblNoJobs.isHidden = false
        } else {
            lblNoJobs.isHidden = true
        }
        self.tableView.reloadData()
    }
    
    func getUserLocation()
    {
        if let lastSavedLocation = DashboardVC.lastSavedLocation
        {
            self.process(foundLocation: lastSavedLocation)
        }
    }
    
    func process(foundLocation : CLLocation)
    {
        DispatchQueue.main.async {
            
            self.setMapCentred(aroundLocation: foundLocation)
        }
    }
    
    func delayWithSeconds(_ seconds: Double, completion: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
            completion()
        }
    }
    
    func viewInitializer() {
        
        if isMapActive {
            self.btnMap.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.btnList.setTitleColor(lightColor, for: UIControl.State.normal)
            self.viewBarMap.backgroundColor = UIColor.white
            self.viewBarList.backgroundColor = UIColor.clear
            self.viewBackgroundListView.isHidden = true
            self.viewBackgroundMap.isHidden = false
            lblNoJobs.isHidden = true
        } else {
            self.btnList.setTitleColor(UIColor.white, for: UIControl.State.normal)
            self.btnMap.setTitleColor(lightColor, for: UIControl.State.normal)
            self.viewBarList.backgroundColor = UIColor.white
            self.viewBarMap.backgroundColor = UIColor.clear
            self.viewBackgroundMap.isHidden = true
            self.viewBackgroundListView.isHidden = false
            updateJobCategoryBottomViews()
        }
        
        self.FSCalendar.scope = .week
        btnCreateNewJob.layer.cornerRadius = self.btnCreateNewJob.frame.height/2
    }
    
    func mapViewInitializer() {
        
        self.locationManager.delegate = self
        self.mapView.delegate = self
        self.mapView.showsUserLocation = true
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        self.locationManager.startUpdatingLocation()
        self.mapView.reloadInputViews()
    }
    
    func handymanNearbyCallingApi(date: String) {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        if let lastSavedLocation = DashboardVC.lastSavedLocation
        {
            self.params = [
                "latitude" :  String(describing : lastSavedLocation.coordinate.latitude),
                "longitude" : String(describing : lastSavedLocation.coordinate.longitude)
                ] as! [String: Any]
        }
        else
        {
            showInfoAlertWith(title: "Location Error", message: "Please turn on your location")
            return;
        }
        
        print(date)
        
        self.params = ["created" : date]
        
        showProgressHud(viewController: self)
        
        Api.jobHistoryApi.jobHistory(params: self.params, completion: { (success:Bool, message : String, jobHistory : [JobHistoryVO?]) in
            
            hideProgressHud(viewController: self)
            
            if success
            {
                if jobHistory != nil
                {
                    self.allJobHistory.removeAll()
                    self.dataSource.removeAll()
                    self.annotationArray.removeAll()
                    
                    
                    self.allJobHistory = jobHistory as! [JobHistoryVO]
                    self.dataSource = jobHistory as! [JobHistoryVO]
                    self.allDataSource = self.dataSource
                    
                    if let anotations = self.mapView?.annotations {
                        self.mapView.removeAnnotations(anotations)
                        self.plottingJobsOnMap(handyman: self.allJobHistory)
                        
                    }
                    if !self.isMapActive {
                        self.updateJobCategoryBottomViews()
                        self.tableView.reloadData()
                    }
                    
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
    
    func plottingJobsOnMap(handyman: [JobHistoryVO])
    {
        hideProgressHud(viewController: self)

        for job in handyman {
            if job.status != JobStatus.completed.rawValue {
                addAnnotation(handyman: job)
            }
            
        }
        if(!annotationArray.isEmpty)
        {
            mapView.showAnnotations(self.annotationArray, animated: true)
        }
        hideProgressHud(viewController: self)
        
    }
    
    func addAnnotation(handyman : JobHistoryVO)
    {
        let annnotation = CustomAnnotation()
        annnotation.coordinate = handyman.coordinaate!
        print("ClientID : \(handyman.clientID)")
        annnotation.id = handyman.clientID
//        annnotation.imagePath = URLConfiguration.ServerUrl + "/" + handyman.profileImageURL
        
        annnotation.image = UIImage(named: "markersmall")
        annotationArray.append(annnotation)
    }
    
    @IBAction func btnCurrentLocation(_ sender: Any) {
        
        self.getUserLocation()
    }
    @IBAction func btnActiveJobs(_ sender: Any) {
        selectedJobCategory = .active
        updateJobCategoryBottomViews()
    }
    @IBAction func btnCompletedJobs(_ sender: Any) {
        selectedJobCategory = .completed
        updateJobCategoryBottomViews()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if (annotation is MKUserLocation)
        {
            return nil
        }
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: "customAnnotation") as? CustomAnnotationView
        
        if view == nil {
            view = CustomAnnotationView.instanceFromNib()
            view?.annotation = annotation
        }
        
        view?.canShowCallout = false
        let customAnnotation = annotation as! CustomAnnotation
        
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: URL(string: customAnnotation.imagePath!)!)
//            {
//                DispatchQueue.main.async {
//                    view?.imgChild.image = UIImage(data: data)
//                }
//            }
//        }
        
//        view?.imgChild.layer.cornerRadius = (view?.imgChild.bounds.width)! / 2
//        view?.imgChild.layer.borderWidth = 3
//        view?.imgChild.layer.borderColor = UIColor.white.cgColor
//        view?.imgChild.clipsToBounds = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(DashboardVC.callPhoneNumber))
        view?.imgChild.addGestureRecognizer(tap)
        
        return view
    }
    
    var selectedAnnotation: CustomAnnotation?
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        self.selectedAnnotation = view.annotation as? CustomAnnotation
        print(self.selectedAnnotation?.id)
    }
    
    @objc func callPhoneNumber()
    {
        print("Tap")
    }
    
    @IBAction func btnMapAction(_ sender: Any) {
        isMapActive = true
        viewInitializer()
    }
    
    @IBAction func btnListAction(_ sender: Any) {
        isMapActive = false
        viewInitializer()
        updateJobCategoryBottomViews()
    }
    
    @IBAction func btnCreateNewAction(_ sender: Any) {
        self.performSegue(withIdentifier: "categorySegue", sender: nil)
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let userLocation = locations.first
        {
            DashboardVC.lastSavedLocation = userLocation
            self.locationManager.stopUpdatingLocation()
            self.getUserLocation()
            self.handymanNearbyCallingApi(date: self.selectedDate)
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let center = mapView.centerCoordinate
        let coordinate = CLLocationCoordinate2D(latitude: center.latitude, longitude: center.longitude)
        print(center)
        print(coordinate)
//
//        self.latitude = coordinate.latitude
//        self.longitude = coordinate.longitude
    }
    
    func setMapCentred(aroundLocation location : CLLocation)
    {
        let latDelta:CLLocationDegrees = 0.005
        let longDelta:CLLocationDegrees = 0.005
        
        let doubleLatitude = Double(location.coordinate.latitude.roundedStringValue())
        let doubleLongitude = Double(location.coordinate.longitude.roundedStringValue())
        
        let coordinate = CLLocationCoordinate2D(latitude: doubleLatitude!, longitude: doubleLongitude!)
        
        let theSpan:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
        let region:MKCoordinateRegion = MKCoordinateRegion(center: coordinate, span: theSpan)
        self.mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error occured \(error.localizedDescription)")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! JobListTVC
        cell.selectionStyle = .none
        let currentIndex = self.dataSource[indexPath.row]
        //print("Job ID is : \(currentIndex._id)")
        
        let newStr = currentIndex.categoryImageURL ?? ""
//        newStr.remove(at: (newStr.startIndex))
//        let imageUrl = URLConfiguration.ServerUrl + newStr
//        
//        if let url = URL(string: imageUrl) {
//            cell.imgClient.kf.setImage(with: url)
//        }
        
        
        var imageURl = ""
        if(!newStr.isEmpty){
            //newStr.remove(at: (newStr.startIndex))
            //imageURl = URLConfiguration.ServerUrl + newStr
            imageURl = newStr
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
                {
                    DispatchQueue.main.async {
                        cell.imgClient.image = UIImage(data: data)
                    }
                }
            }
        }
        
        
        
        
        
        
        cell.imgClient.layer.cornerRadius = cell.imgClient.frame.height/2
        cell.lblName.text = currentIndex.categoryName
        cell.imgClient.layer.cornerRadius = cell.imgClient.frame.height/2
        cell.lblAddress.text = currentIndex.wheree
        cell.lblStatus.text = currentIndex.status.capitalized
        cell.lblDateTime.text = DateUtil.getSimpleDateAndTime(currentIndex.when.dateFromISO8601!)
        
        if currentIndex.status == JobStatus.completed.rawValue
        {
            cell.viewBackground.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1)
        }
        else
        {
            cell.viewBackground.backgroundColor = UIColor.white
        }
        
        
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        selectedIndex = indexPath.row
        let job = self.dataSource[indexPath.row]
        selectiveJobID = self.dataSource[indexPath.row]._id
        
        if job.status == JobStatus.arounded.rawValue
        {
            self.performSegue(withIdentifier: "providerListSegue", sender: nil)
        }
        else if job.status == JobStatus.quoted.rawValue || job.status == JobStatus.accepted.rawValue
        {
            self.performSegue(withIdentifier: "homeToQuoteDetailSegue", sender: nil)
        }
        else if job.status == JobStatus.onway.rawValue || job.status == JobStatus.arrived.rawValue || job.status == JobStatus.started.rawValue
        {
            self.performSegue(withIdentifier: "homeToOnTheWaySegue", sender: nil)
        }
        else if job.status == JobStatus.completed.rawValue
        {
            let vc = UIStoryboard.main().instantiateViewController(withIdentifier: "ReceiptVC_ID") as! ReceiptVC
            vc.jobID = self.dataSource[indexPath.row]._id
            self.navigationController?.pushViewController(vc, animated: true)
        }
        else if job.status == JobStatus.cancelled.rawValue
        {
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
        
        heightConstraintsCalendar.constant = bounds.height
        self.view.layoutIfNeeded()
    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        jobDotIndicator = false
        self.checkJobOnDate(newDate: date)
        
        if jobDotIndicator
        {
            cell.numberOfEvents = 1
            cell.eventIndicator.isHidden = false
            cell.eventIndicator.numberOfEvents = 1
        }
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
//        var currentDate = Date()
        let datee = Calendar.current.date(byAdding: .day, value: -1, to: date)!
        let curDate = Calendar.current.startOfDay(for: datee).iso8601
        print(calendar.currentPage)
        self.selectedDate = date.iso8601
        handymanNearbyCallingApi(date: date.iso8601)
        
        //self.filterJobsFor(date: date)
    }
    
    func checkJobOnDate(newDate : Date)
    {
        for job in self.allJobHistory
        {
            if let jobDate = job.when.dateFromISO8601
            {
                if jobDate.isEqualTo(anotherDate: newDate, ignoreTime: true)
                {
                    jobDotIndicator = true
                    break
                }
            }
        }
    }
    
    func filterJobsFor( date : Date )
    {
        dataSource.removeAll()
        
        for job in self.allJobHistory
        {
            if let jobStartDate = job.when.dateFromISO8601
            {
                if jobStartDate.isEqualTo(anotherDate: date, ignoreTime: true)
                {
                    dataSource.append(job)
                    jobDotIndicator = true
                }
            }
        }
        
        dataSource = dataSource.sorted { (job1 : JobHistoryVO, job2 : JobHistoryVO) -> Bool in
            
            let job1StartTime = job1.when.dateFromISO8601
            let job2StartTime = job2.when.dateFromISO8601
            
            return job1StartTime!.compare(job2StartTime!) == .orderedDescending
        }
        
        if(dataSource.count == 0)
        {
            lblNoJobs.isHidden = false
//            lblNoJobs.isHidden = true
        }
        else
        {
            lblNoJobs.isHidden = true
        }
        tableView.reloadData()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let controller = segue.destination as? ProviderListVC
        {
            if let lastSavedLocation = DashboardVC.lastSavedLocation
            {
                controller.jobID = selectiveJobID
                controller.latitude = lastSavedLocation.coordinate.latitude
                controller.longitude =  lastSavedLocation.coordinate.longitude
            }
        }
        else if let controller = segue.destination as? RequestJobDetailVC
        {
            
            
            
            controller.jobID = self.allJobHistory[selectedIndex]._id
            controller.jobInfo = self.allJobHistory[selectedIndex]
            controller.providerID = self.allJobHistory[selectedIndex].providerID ?? ""
        }
        else if let controller = segue.destination as? ProviderOnTheWayVC
        {
            controller.jobID = self.allJobHistory[selectedIndex]._id
        }
    }

}
