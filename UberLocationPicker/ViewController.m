//
//  ViewController.m
//  UberLocationPicker
//
//  Created by Dan Rudolf on 7/9/14.
//  Copyright (c) 2014 com.rudolfmedia. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate,UIAlertViewDelegate>

@property CLLocationManager *locationManager;
@property CLLocationCoordinate2D chosenLocation;

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIButton *setButton;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    UIImageView *pinImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pin1"]];
    [pinImage setCenter:CGPointMake(self.mapView.frame.size.width/2, self.mapView.frame.size.height/2 - pinImage.frame.size.height)];
    [self.mapView.superview addSubview:pinImage];

    self.setButton.layer.cornerRadius = 8;

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];

    self.mapView.delegate = self;

}
- (IBAction)setButtonPressed:(id)sender {

    self.chosenLocation = self.mapView.centerCoordinate;
    [self reverseGeocode:self.chosenLocation];
    NSLog(@"Latitude: %f Longetude: %f",self.chosenLocation.latitude, self.chosenLocation.longitude);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{

    for (CLLocation *current in locations) {
        if (current.horizontalAccuracy < 150 && current.verticalAccuracy < 150) {
            [self.locationManager stopUpdatingLocation];
            [self setMapViewRegion];
            break;
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{

    NSLog(@"%@",error);
}


- (void)setMapViewRegion{
    
    CLLocationCoordinate2D zoomCenter;
    zoomCenter = self.locationManager.location.coordinate;

    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(zoomCenter, 500, 500);
    [self.mapView setRegion:viewRegion animated:YES];
}

- (void)reverseGeocode:(CLLocationCoordinate2D)locationCord{

    CLGeocoder *geo = [[CLGeocoder alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:locationCord.latitude longitude:locationCord.longitude];

    [geo reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *addressPlacmark = [placemarks firstObject];
        NSString *street = [NSString stringWithFormat:@"%@ %@",addressPlacmark.subThoroughfare, addressPlacmark.thoroughfare];
        NSString *city = [NSString stringWithFormat:@"%@",addressPlacmark.locality];

        NSMutableDictionary *addressDictionary = [[NSMutableDictionary alloc] initWithObjects:@[street, city] forKeys:@[@"street", @"city"]];
        
        NSLog(@"%@",addressDictionary);
    }];
}

@end
