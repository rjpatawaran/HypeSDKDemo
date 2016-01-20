//
//  BranchMapViewController.m
//  HypeSDKDemo
//
//  Created by RJ Patawaran on 9/30/15.
//  Copyright © 2015 Entropy Soluction. All rights reserved.
//

#import "BranchMapViewController.h"
@import MapKit;

@interface BranchMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@end

@implementation BranchMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = _branch.name;

    if (_branch.polygon != nil) {
        NSArray *polygon = _branch.polygon;
        int count = (int)[polygon count];
        CLLocationCoordinate2D *coords = calloc(count, sizeof(CLLocationCoordinate2D));
        
        int i = 0;
        for (NSArray *point in polygon) {
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake([[point objectAtIndex:0] floatValue], [[point objectAtIndex:1] floatValue]);
            coords[i++] = coord;
        }
        MKPolygon *polygon_ = [MKPolygon polygonWithCoordinates:coords count:count];
        [_mapView addOverlay:polygon_];
    } else {
        MKCircle *circle = [MKCircle circleWithCenterCoordinate:_branch.location.coordinate radius:_branch.radius];
        [_mapView addOverlay:circle];
    }
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(_branch.location.coordinate, 500, 500);
    MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
    [_mapView setRegion:adjustedRegion animated:YES];
}


- (MKOverlayView *)mapView:(MKMapView *)map viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKCircle class]]) {
        MKCircleView *circleView = [[MKCircleView alloc] initWithOverlay:overlay];
        circleView.lineWidth = 1.0f;
        circleView.strokeColor = [UIColor blueColor];
        circleView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
        return circleView;
    } else if([overlay isKindOfClass:[MKPolygon class]]) {
        MKPolygonView* polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon*)overlay];
        polygonView.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.25];
        polygonView.strokeColor = [UIColor blueColor];
        polygonView.lineWidth = 1.0f;
        return polygonView;
    }
    return nil;
}


@end
