//
//  CategoriesVC.swift
//  Neighboorhood-iOS-Services-User
//
//  Created by Zain ul Abideen on 30/12/2017.
//  Copyright © 2017 yamsol. All rights reserved.
//

import UIKit

class CategoriesVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var allCategories = [CategoriesListVO]()
    var allCategoriesDescriptions = [String]()
    
    var categoryID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.callingCategoriesListApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func callingCategoriesListApi() {
        
        if !Connection.isInternetAvailable()
        {
            print("FIXXXXXXXX Internet not connected")
            Connection.showNetworkErrorView()
            return;
        }
        
        showProgressHud(viewController: self)
        Api.categoryApi.getCategories(completion: { (success:Bool, message : String, category : [CategoriesListVO]?) in
            hideProgressHud(viewController: self)
            
            if success {
                if category != nil {
                    self.allCategories.removeAll()
                    self.allCategories = category as! [CategoriesListVO]
                    self.tableView.reloadData()
                } else {
                    self.showInfoAlertWith(title: "Internal Error", message: "Logged In but user object not returned")
                }
            } else {
                self.showInfoAlertWith(title: "Error", message: message)
            }
        })
    }
   
    @IBAction func btnBackAction(_ sender: Any) {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell") as! UserCategoryTVC
        cell.selectionStyle = .none
        
        let currentIndex = self.allCategories[indexPath.row]
        
        cell.imgView.layer.cornerRadius = 10
        cell.imgView.clipsToBounds = true
        
        let imageURl = currentIndex.imageURL!
        //newStr.remove(at: (newStr.startIndex))
        //let imageURl = URLConfiguration.ServerUrl + newStr
        
        //let imageURl = newStr
        
        
        
        if(!imageURl.isEmpty){
            //newStr.remove(at: (newStr.startIndex))
            //imageURl = URLConfiguration.ServerUrl + newStr
            
            
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
                {
                    DispatchQueue.main.async {
                        cell.imgView.image = UIImage(data: data)
                    }
                }
            }
        }
        
        
        
        
        
//        DispatchQueue.global().async {
//            if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
//            {
//                DispatchQueue.main.async {
//                    cell.imgView.image = UIImage(data: data)
//                }
//            }
//        }
        
        cell.lblCategoryName.text = currentIndex.name.uppercased()
        cell.lblCategoryDescription.text = currentIndex.descriptionn
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        categoryID = self.allCategories[indexPath.row]._id
        self.performSegue(withIdentifier: "enterJobDetailSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? NewJobRequestVC {
            controller.selectedCategory = self.categoryID
        }
    }
    
    
 

}
