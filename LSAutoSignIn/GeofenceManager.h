//
//  GeofenceManager.h
//  LSAutoSignIn
//
//  Created by Aneesh Sachdeva on 1/5/15.
//  Copyright (c) 2015 Applos. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface GeofenceManager : NSObject<CLLocationManagerDelegate>

@property CLLocationManager* locationManager;

@end