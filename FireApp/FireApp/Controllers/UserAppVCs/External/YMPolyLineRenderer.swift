//
//  YMPolyLineRenderer.swift
//  NeighboorhoodDriver
//
//  Created by Zain on 24/05/2017.
//  Copyright © 2017 Yamsol. All rights reserved.
//

import UIKit
import MapKit

class YMPolyLineRenderer: MKPolylineRenderer {

    
    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        return true
    }
    
    
}
