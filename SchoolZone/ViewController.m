//
//  ViewController.m
//  SchoolZone
//
//  Created by Shawn on 28/6/15.
//  Copyright (c) 2015 Shawn. All rights reserved.
//

#import "ViewController.h"
#import "MyCustomAnnotation.h"
#import "School.h"
#import "ClusterView.h"

#import "kingpin/KPAnnotation.h"
#import "kingpin/KPClusteringAlgorithm.h"
#import "kingpin/KPGridClusteringAlgorithm.h"
#import "kingpin/KPClusteringController.h"




@interface ViewController ()<CLLocationManagerDelegate, MKMapViewDelegate, KPClusteringControllerDelegate>

@property (nonatomic, strong) KPClusteringController *clusteringController;
@property (nonatomic, strong) NSDictionary *allSchoolCoorinates;
@property (nonatomic, strong) NSDictionary *allSchools;
@property (nonatomic, strong) MKPolyline *polyLine;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastLocation;
@property (nonatomic, strong) School *lastSchool;

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *trackingButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *titleItem;

@end

@implementation ViewController

#pragma mark - private
- (CLLocationCoordinate2D)_locationFromCoordinateObject:(NSArray *)coor
{
    CLLocationDegrees n1 = [[coor firstObject] doubleValue];
    CLLocationDegrees n2 = [[coor lastObject] doubleValue];
    return CLLocationCoordinate2DMake(n2, n1);
}


- (void)_drawLine:(NSArray *)coordinatesArray
{
    
    [self.mapView removeOverlay:self.polyLine];
    self.polyLine = nil;
    
    int count = (int)[coordinatesArray count];
    CLLocationCoordinate2D points[count];
    for (int i = 0 ; i < count; i++) {
        NSArray *pointArr = coordinatesArray[i];
        points[i] = [self _locationFromCoordinateObject:pointArr];
    }
    self.polyLine = [MKPolyline polylineWithCoordinates:points count:count];
    [self.mapView addOverlay:self.polyLine];
    
}




- (void)_addAnnotations
{
    NSMutableArray *resultArray = [NSMutableArray array];
    
    NSArray *keyArray = [self.allSchoolCoorinates allKeys];
    for (int i = 0; i < [keyArray count]; i++) {
        NSString *key = keyArray[i];
        NSArray *array = self.allSchoolCoorinates[key];
        CLLocationCoordinate2D coordinate = [self _locationFromCoordinateObject:array];
        MyCustomAnnotation *annotation = [[MyCustomAnnotation alloc]init];
        annotation.coordinate = coordinate;
        annotation.schoolNumberStr = key;
        School *school = self.allSchools[key];
        annotation.title = school.title;
        //if   (i== 0) {NSLog(@"shool title %@",school.title); }
        [resultArray addObject:annotation];
    }
    //NSLog(@"add %lu annation", (unsigned long)[resultArray count]);
    
    [self.clusteringController setAnnotations:resultArray];
}


- (void)_addClusteringControlle
{
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView];
    
    KPGridClusteringAlgorithm *algorithm = [KPGridClusteringAlgorithm new];
    algorithm.annotationSize = CGSizeMake(25, 50);
    algorithm.clusteringStrategy = KPGridClusteringAlgorithmStrategyTwoPhase;
    self.clusteringController = [[KPClusteringController alloc] initWithMapView:self.mapView
                                                            clusteringAlgorithm:algorithm];
    self.clusteringController.delegate = self;
    self.clusteringController.animationOptions = UIViewAnimationOptionCurveEaseOut;
    [self _addAnnotations];
}

#pragma mark - VC life Circle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.trackingButton setImage:[UIImage imageNamed:@"TrackingLocationMask"] forState:UIControlStateHighlighted];
    self.mapView.rotateEnabled = NO;
    
    //magic number: centralize map in NZ
    CLLocationCoordinate2D coor = CLLocationCoordinate2DMake(-41.508575, 174.199219);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor ,772137.12 + 1000000, 1291192.25+1000000);
    [self.mapView setRegion:region animated:YES];
    
    self.toolbar.backgroundColor = [UIColor colorWithRed:83.0/255 green:150.0/255 blue:199.0/255 alpha:1]; //magic number: color
    self.titleItem.title = @"";
    self.toolbar.translucent = YES;
    //self.toolbar.barStyle = UIBarStyleBlack;
    
    self.allSchools = [School allSchools];
    self.allSchoolCoorinates = [School allSchoolsCoordinates];
    
    NSLog(@"all school %lu",(unsigned long)[[self.allSchoolCoorinates allKeys] count]);
    
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.distanceFilter = 500;
    self.mapView.showsUserLocation = YES;
    
    
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        NSLog(@"request authrozie");
        [self.locationManager requestWhenInUseAuthorization];
    }else{
        [self.locationManager startUpdatingLocation];
    }
    
    [self _addClusteringControlle];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Core Loaction Delegate


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            [self.locationManager startUpdatingLocation];
            break;
            
        default:
            break;
    }
}

- (void)_showLocation
{
    // FIXME: if use location no in NZ, not set map to user location
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.lastLocation.coordinate ,10000, 10000);
    [self.mapView setRegion:region animated:YES];
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"update");
    self.lastLocation = [locations lastObject];
    [self _showLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"fail with error: %@", error);
}




#pragma mark - <MKMapViewDelegate>

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        MKPolyline *route = overlay;
        MKPolylineRenderer *render = [[MKPolylineRenderer alloc] initWithPolyline:route];
        render.strokeColor = [UIColor colorWithRed:52.0/255 green:60.0/255 blue:62.0/255 alpha:1];  //magic number: color
        render.lineWidth = 3;
        return render;
    }else
        return nil;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    [self.clusteringController refresh:true];
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
      if ([view.annotation isKindOfClass:[KPAnnotation class]]) {
        
        KPAnnotation *cluster = (KPAnnotation *)view.annotation;
        
        if (cluster.annotations.count > 1){
            [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(cluster.coordinate,
                                                                       cluster.radius * 2.5f,
                                                                       cluster.radius * 2.5f)
                           animated:YES];
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    MKPinAnnotationView *annotationView = nil;
    
    if ([annotation isKindOfClass:[KPAnnotation class]]) {
        KPAnnotation *a = (KPAnnotation *)annotation;
        
        if ([annotation isKindOfClass:[MKUserLocation class]]){
            return nil;
        }
        
        if (a.isCluster) {
            
            annotationView = (ClusterView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"cluster"];
            //ClusterView *clusterView = (ClusterView *)annotationView;
            
            if (annotationView == nil) {
                //annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:a reuseIdentifier:@"cluster"];
                annotationView = [[ClusterView alloc] initWithAnnotation:a reuseIdentifier:@"cluster"];
            }
            
            ClusterView *clusterView = (ClusterView *)annotationView;
            
            clusterView.number = [a.annotations count];
            
            
            //annotationView.pinColor = MKPinAnnotationColorPurple;
        }
        
        else {
            annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pin"];
            
            if (annotationView == nil) {
                annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:[a.annotations anyObject]
                                                                 reuseIdentifier:@"pin"];
            }
            //NSLog(@"new ann is cutome %@", a);
            
            MyCustomAnnotation *anno = (MyCustomAnnotation *)[a.annotations anyObject];
            if ( [anno isKindOfClass:[MyCustomAnnotation class]]) {
                
                
                NSString *schoolNum = anno.schoolNumberStr;
                School *school = self.allSchools[schoolNum];
                
                //NSLog(@"a is cutome %@, schoo %@, arry:%@", annotation, school.title, school.schoolGeoJsonArray);
                if (school.schoolGeoJsonArray) {
                    annotationView.pinColor = MKPinAnnotationColorPurple;
                    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
                }else{
                    annotationView.pinColor = MKPinAnnotationColorRed;
                    annotationView.rightCalloutAccessoryView = nil;
                }
                
            }
        }
        
        annotationView.canShowCallout = YES;
    }
    
    else if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"nocluster"];
        annotationView.pinColor = MKPinAnnotationColorGreen;
    }
    
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    //NSLog(@"call out pressed");
    KPAnnotation *annoation = (KPAnnotation *)view.annotation;
    MyCustomAnnotation *a = (MyCustomAnnotation *)[annoation.annotations anyObject];
    School *school = self.allSchools[a.schoolNumberStr];
    self.lastSchool = school;
    self.titleItem.title = school.title;
    NSArray *geoArray = school.schoolGeoJsonArray;
    [self _drawLine:geoArray];
}


#pragma mark - <KPClusteringControllerDelegate>

- (void)clusteringController:(KPClusteringController *)clusteringController configureAnnotationForDisplay:(KPAnnotation *)annotation {
    
    if ([annotation isCluster]) {
        annotation.title = [NSString stringWithFormat:@"%lu Schools", (unsigned long)annotation.annotations.count];
    }else {
        MyCustomAnnotation *a = (MyCustomAnnotation *)[annotation.annotations anyObject];
        annotation.title = a.title;
        
    }
    //annotation.subtitle = [NSString stringWithFormat:@"%.0f meters", annotation.radius];
}

- (BOOL)clusteringControllerShouldClusterAnnotations:(KPClusteringController *)clusteringController {
    return YES;
}

- (void)clusteringControllerWillUpdateVisibleAnnotations:(KPClusteringController *)clusteringController {
    //NSLog(@"Clustering controller %@ will update visible annotations", clusteringController);
}

- (void)clusteringControllerDidUpdateVisibleMapAnnotations:(KPClusteringController *)clusteringController {
    //NSLog(@"Clustering controller %@ did update visible annotations", clusteringController);
}



- (void)clusteringController:(KPClusteringController *)clusteringController performAnimations:(void (^)())animations withCompletionHandler:(void (^)(BOOL))completion {
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:0.6
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:animations
                     completion:completion];
}

#pragma mark - IBAction

- (IBAction)trackingButtonPressed:(UIButton *)sender {
    NSLog(@"pressed, status %d", [CLLocationManager authorizationStatus]);
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled"
                                                        message:@"To re-enable, please go to Settings and turn on Location Service for this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }else if([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse){
        [self _showLocation];
    }
}
- (IBAction)itemPressed:(UIBarButtonItem *)sender {
    NSString *key =  self.lastSchool.schoolNumberStr;
    NSArray *array = self.allSchoolCoorinates[key];
    CLLocationCoordinate2D coor = [self _locationFromCoordinateObject:array];
    
    //TODO:  set map to show school zone properly
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coor ,15000, 15000);
    [self.mapView setRegion:region animated:YES];
}

@end
