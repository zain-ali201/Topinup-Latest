//
//  CustomChildAnnotation.swift
//  Neighbourhoods
//
//  Created by Zain on 12/04/2017.
//  Copyright © 2017 Hanan. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class CustomAnnotation : NSObject, MKAnnotation {
    
    var coordinate: CLLocationCoordinate2D
    var id : String?
    var title: String?
    var image: UIImage?
    var imagePath: String?
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil
        self.id = nil
        self.image = nil
        self.imagePath = nil
    }
}

class CustomAnnotationView: MKAnnotationView {

    @IBOutlet weak var imgChild: UIImageView!
    
    override var reuseIdentifier: String? {
        get { return "customAnnotation" }
    }
    
    class func instanceFromNib() -> CustomAnnotationView
    {
        return UINib(nibName: "CustomChildAnnotation", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CustomAnnotationView
    }
 
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
//        self.imgChild.layer.cornerRadius = self.imgChild.frame.height/2
//        self.imgChild.clipsToBounds = true
        
    }
    
    override var image: UIImage? {
        get {
            return self.imgChild.image
        }
        set {
            self.imgChild.image = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

//    func setImage(relativePath : String?)
//    {
//        if let imagePath = relativePath
//        {
//            var newStr = relativePath!
//            newStr.remove(at: (newStr.startIndex))
//            let imageURl = URLConfiguration.ServerUrl + newStr
//
//            DispatchQueue.global().async {
//                if let data = try? Data(contentsOf: URL(string: imageURl)!) //make sure your image in this url does exist, otherwise
//                {
//                    DispatchQueue.main.async {
//
//                        self.imgChild.image = UIImage(data: data)
//
//                    }
//                }
//
//            }
//            self.imgChild.layer.cornerRadius = (self.imgChild.bounds.width) / 2
//            self.imgChild.layer.borderWidth = 3.0
//            self.imgChild.layer.borderColor = UIColor(red: 0/255, green: 170/255, blue: 247/255, alpha: 1.0).cgColor
//            self.imgChild.clipsToBounds = true
//        }
//
//    }
}
