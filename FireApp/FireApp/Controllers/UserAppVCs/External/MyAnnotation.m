//
//  MyAnnotation.m
//  ShipFinder
//
//  Created by Mutee ur Rehman on 8/18/14.
//  Copyright (c) 2014 Mutee ur Rehman. All rights reserved.
//

#import "MyAnnotation.h"

@implementation MyAnnotation
-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
    _coordinate = newCoordinate;
}
-(MKAnnotationView*)annotaionView
{
    MKAnnotationView * annotationView = [[MKAnnotationView alloc] initWithAnnotation:self reuseIdentifier:@"MyAnnotation" ];
    [annotationView sizeToFit];
 
    
   // annotationView.enabled = YES;
   // annotationView.canShowCallout = YES;
     return annotationView;
}
@end
