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

/** Initialize class and create the strong reference to the locationManager object */
- (instancetype)init
{
    self = [super init];
    if (self)
    {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    
    return self;
}

/** Safely convert the value in the dictionary to a CLRegion object */
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


- (void)locationManager:(CLLocationManager *)manager didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region
{
    if(state == CLRegionStateInside)
    {
        NSLog(@"##Entered Region - %@", region.identifier);
    }
    else if(state == CLRegionStateOutside)
    {
        NSLog(@"##Exited Region - %@", region.identifier);
    }
    else{
        NSLog(@"##Unknown state  Region - %@", region.identifier);
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    static BOOL firstTime = YES; // We only want to run the following code upon recieving the first location update
    CLLocation* newLocation = [locations lastObject]; // get the new (current) location
    
    if (firstTime)
    {
        firstTime = NO;
        NSSet* monitoredRegions = locationManager.monitoredRegions;
        if (monitoredRegions)
        {
            [monitoredRegions enumerateObjectsUsingBlock:^(CLRegion* region, BOOL *stop)
             {
                 NSString* identifier = region.identifier;
                 CLLocationCoordinate2D centerCoordinate = region.center; // This is actually deprecated, but we'll see...
                 CLLocationCoordinate2D currentLocation = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
                 CLLocationDistance regionRadius = region.radius; // This is also deprecated...
                 
                 NSNumber* currentLocationToCenterDistance = [self calculateDistanceBetweenCoordinatesInMeters:currentLocation coordinate:centerCoordinate];
                 
                 // If the user is already inside of the region, we manually invoke didEnterRegion
                 if ([currentLocationToCenterDistance floatValue] <= regionRadius)
                 {
                     NSLog(@"Manually invoking didEnterRegion for region: %@", identifier);
                     
                     // Stop monitoring region temporarily
                     [locationManager stopMonitoringForRegion:region];
                     
                     // Invoke call
                     [self locationManager:locationManager didEnterRegion:region];
                     
                     // Resume monitering
                     [locationManager startMonitoringForRegion:region];
                 }
             }];
        }
        
        // Stop updating the location because it is not needed for now (region monitoring is still active)
        [locationManager stopUpdatingLocation];
    }
}

- (NSNumber *)calculateDistanceBetweenCoordinatesInMeters:(CLLocationCoordinate2D)coordinate1 coordinate:(CLLocationCoordinate2D)coordinate2
{
    NSInteger earthRadius = 6371; // Earth's radius in kilometers
    double latitudeDelta = (coordinate2.latitude = coordinate1.latitude) * (M_PI/180);
    double longitudeDelta = (coordinate2.longitude = coordinate1.longitude) * (M_PI/180);
    double latitude1InRadians = coordinate1.latitude * (M_PI/180);
    double latitude2InRadians = coordinate2.latitude * (M_PI/180);
    
    // The following is the formula to calculate the distance between two coordinates
    double nA = pow ( sin(latitudeDelta/2), 2 ) + cos(latitude1InRadians) * cos(latitude2InRadians) * pow ( sin(longitudeDelta/2), 2 );
    double nC = 2 * atan2( sqrt(nA), sqrt( 1 - nA ));
    double nD = earthRadius * nC;
    
    // Convert to meters;
    return @(nD * 1000);
}

@end

