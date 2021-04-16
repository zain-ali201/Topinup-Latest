//
//  UIView+Extesnion.swift
//  BN News
//
//  Created by ArhamSoft on 05/04/2019.
//  Copyright © 2019 ArhamSoft. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    func dropShadow(color: UIColor = .lightGray, opacity: Float = 0.5, radius: CGFloat = 1, scale: Bool = true) {
        layer.masksToBounds = false
        layer.cornerRadius = cornerRadius
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize(width: 0, height: 3)
        layer.shadowRadius = radius
        layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        layer.shouldRasterize = true
        layer.rasterizationScale = scale ? UIScreen.main.scale : 1
    }
    
    func removeShadow() {
        self.layer.shadowOffset = CGSize(width: 0 , height: 0)
        self.layer.shadowColor = UIColor.clear.cgColor
        self.layer.cornerRadius = 0.0
        self.layer.shadowRadius = 0.0
        self.layer.shadowOpacity = 0.00
    }
    
    func roundWithShadowLayer() {
        self.layer.masksToBounds = false
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.shadowColor = UIColor.lightGray.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 2.0
    }
    
    func updateShadowLayerProperties(color: UIColor = .black) {
        self.layer.shadowColor = color.cgColor
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.layer.cornerRadius).cgPath
        self.layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 1.0
    }
    
    func applyNavBarConstraints(size: (width: CGFloat, height: CGFloat)) {
        let widthConstraint = self.widthAnchor.constraint(equalToConstant: size.width)
        let heightConstraint = self.heightAnchor.constraint(equalToConstant: size.height)
        heightConstraint.isActive = true
        widthConstraint.isActive = true
    }
    
    func round() {
        self.layer.cornerRadius = self.bounds.height / 2
        self.layer.masksToBounds = true
    }
    
    func round(_ round: CGFloat) {
        self.layer.cornerRadius = round
        self.layer.masksToBounds = true
    }
    
    func updateBorder(color: UIColor = .clear) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = 1
    }
    
    func addGradient(_ top: UIColor, _ bottom: UIColor) {
        let colours = [top, bottom]
        self.applyGradient(colours: colours)
    }
    
    private func applyGradient(colours: [UIColor]) {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colours.map { $0.cgColor }
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradient, at: 0)
    }
    
    func addDashedBorder() {
        let color = UIColor.lightText.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        shapeLayer.bounds = shapeRect
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 1
        shapeLayer.lineJoin = CAShapeLayerLineJoin.round
        shapeLayer.lineDashPattern = [1,1]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: 1).cgPath
        
        self.layer.addSublayer(shapeLayer)
    }
}

@IBDesignable extension UIView {
    @IBInspectable var borderColor:UIColor? {
        set {
            layer.borderColor = newValue!.cgColor
        }
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor:color)
            }
            else {
                return nil
            }
        }
    }
    @IBInspectable var borderWidth:CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    @IBInspectable var cornerRadius:CGFloat {
        set {
            layer.cornerRadius = newValue
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var cornerRadTL:CGFloat {
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMinXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var cornerRadTR:CGFloat {
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMaxXMinYCorner]
            } else {
                // Fallback on earlier versions
            }
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var cornerRadBL:CGFloat {
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMinXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    
    @IBInspectable var cornerRadBR:CGFloat {
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var corBRTR:CGFloat {
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMaxXMinYCorner,.layerMaxXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    
    @IBInspectable var corBLTL:CGFloat {
        set {
            layer.cornerRadius = newValue
            if #available(iOS 11.0, *) {
                layer.maskedCorners = [.layerMinXMinYCorner,.layerMinXMaxYCorner]
            } else {
                // Fallback on earlier versions
            }
            clipsToBounds = newValue > 0
        }
        get {
            return layer.cornerRadius
        }
    }
    
    
    
    @IBInspectable var padding:CGFloat {
        
        set {
            self.bounds = self.frame.insetBy(dx: padding, dy: padding);
        }
        get {
            return self.bounds.origin.x
        }
    }
    
    @IBInspectable var dropShadow: UIColor {
        set {
            layer.shadowPath = nil
            let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: self.cornerRadius)
            layer.masksToBounds = false
            layer.shadowColor = newValue.cgColor
            layer.shadowOffset = CGSize(width: 0, height: 3);
            layer.shadowOpacity = 1
            layer.shadowPath = shadowPath.cgPath
        }
        get {
            return UIColor.clear
        }
    }
    
    class func loadFromNibNamed(_ nibNamed: String, bundle : Bundle? = nil,owner: AnyObject) -> UIView? {
        return UINib(
            nibName: nibNamed,
            bundle: bundle
            ).instantiate(withOwner: owner, options: nil)[0] as? UIView
    }
    
    //    func addBorder(_ edge: UIRectEdge, color: UIColor, thickness: CGFloat) {
    //        self.layer.addBorder(edge, color: color, thickness: thickness)
    //    }
    
}
