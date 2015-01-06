//
//  GeofenceManager.m
//  LSAutoSignIn
//
//  Created by Aneesh Sachdeva on 1/5/15.
//  Copyright (c) 2015 Applos. All rights reserved.
//

#import "GeofenceManager.h"

@implementation GeofenceManager

@synthesize locationManager;

- (CLRegion*)dictionaryToRegion:(NSDictionary *)dictionary
{
    // Retrieve neccessary values from dict.
    NSString* identifier = [dictionary valueForKey:@"Identifier"];
    CLLocationDegrees latitude = [[dictionary valueForKey:@"Latitude"] doubleValue];
    CLLocationDegrees longitude = [[dictionary valueForKey:@"Longitude"] doubleValue];
    CLLocationCoordinate2D centerCoordinate = CLLocationCoordinate2DMake(latitude, longitude);
    CLLocationDegrees regionRadius = [[dictionary valueForKey:@"Region Radius"] doubleValue];
    
    // Make sure radius isn't bigger than permitted. Error prevention.
    if (regionRadius > locationManager.maximumRegionMonitoringDistance)
    {
        regionRadius = locationManager.maximumRegionMonitoringDistance;
    }
    
    CLRegion* region = nil;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0f) // iOS 7 and newer
    {
        region = [[CLCircularRegion alloc] initWithCenter:centerCoordinate radius:regionRadius identifier:identifier];
    }
    else // Below iOS 7
    {
        //NOTE: This is deprecated.
        region = [[CLRegion alloc] initCircularRegionWithCenter:centerCoordinate radius:regionRadius identifier:identifier];
    }
    
    return region;
}

@end

