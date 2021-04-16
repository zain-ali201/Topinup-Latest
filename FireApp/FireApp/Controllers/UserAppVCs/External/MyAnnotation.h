//
//  MyAnnotation.h
//  ShipFinder
//
//  Created by Mutee ur Rehman on 8/18/14.
//  Copyright (c) 2014 Mutee ur Rehman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MyAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy) NSMutableDictionary *CompleteInfo;

@property (nonatomic, copy) NSString * idVal;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, strong) NSString *type;

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) float bearing;

@property (nonatomic, strong) NSString *carType;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, assign) CLLocationCoordinate2D previousCoordinate;



-(void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

-(MKAnnotationView*)annotaionView;

@end
