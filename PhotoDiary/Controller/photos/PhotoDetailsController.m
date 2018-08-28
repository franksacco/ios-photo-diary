//
//  PhotoDetailsController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 26/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "PhotoDetailsController.h"
#import <MapKit/MapKit.h>

@interface PhotoDetailsController ()

@property (weak, nonatomic) IBOutlet UILabel *mediaTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaSubtypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dimensionLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifiedLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender;

@end


@implementation PhotoDetailsController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView setAllowsSelection:NO];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    switch (self.asset.mediaType) {
        case PHAssetMediaTypeImage:
            [self.mediaTypeLabel setText:@"Foto"]; break;
        case PHAssetMediaTypeVideo:
            [self.mediaTypeLabel setText:@"Video"]; break;
        case PHAssetMediaTypeAudio:
            [self.mediaTypeLabel setText:@"Audio"]; break;
        case PHAssetMediaTypeUnknown:
        default:
            [self.mediaTypeLabel setText:@"Sconosciuto"];
    }
    
    switch (self.asset.mediaSubtypes) {
        case PHAssetMediaSubtypePhotoPanorama:
            [self.mediaSubtypeLabel setText:@"Foto panorama"]; break;
        case PHAssetMediaSubtypePhotoHDR:
            [self.mediaSubtypeLabel setText:@"Foto HDR"]; break;
        case PHAssetMediaSubtypePhotoScreenshot:
            [self.mediaSubtypeLabel setText:@"Screenshot"]; break;
        case PHAssetMediaSubtypePhotoLive:
            [self.mediaSubtypeLabel setText:@"Foto live"]; break;
        case PHAssetMediaSubtypeVideoStreamed:
            [self.mediaSubtypeLabel setText:@"Video streaming"]; break;
        case PHAssetMediaSubtypeVideoTimelapse:
            [self.mediaSubtypeLabel setText:@"Timelapse video"]; break;
        case PHAssetMediaSubtypePhotoDepthEffect:
            [self.mediaSubtypeLabel setText:@"Foto con effetto depth"]; break;
        case PHAssetMediaSubtypeVideoHighFrameRate:
            [self.mediaSubtypeLabel setText:@"Video high-frame-rate"]; break;
        case PHAssetMediaSubtypeNone:
        default:
            [self.mediaSubtypeLabel setText:@"Nessuno"];
    }
    
    switch (self.asset.sourceType) {
        case PHAssetSourceTypeUserLibrary:
            [self.sourceTypeLabel setText:@"Libreria foto"]; break;
        case PHAssetSourceTypeCloudShared:
            [self.sourceTypeLabel setText:@"Album condiviso di iCloud"]; break;
        case PHAssetSourceTypeiTunesSynced:
            [self.sourceTypeLabel setText:@"Sincronizzazione di iTunes da Mac o PC"]; break;
        case PHAssetSourceTypeNone:
        default:
            [self.sourceTypeLabel setText:@"Non disponibile"]; break;
    }
    
    unsigned int seconds = (unsigned int)round(self.asset.duration);
    NSString *string = [NSString stringWithFormat:@"%02u:%02u:%02u",
                        seconds / 3600, (seconds / 60) % 60, seconds % 60];
    [self.durationLabel setText:string];
    
    [self.dimensionLabel setText:[NSString stringWithFormat:@"%lu x %lu px",
                                  self.asset.pixelWidth, self.asset.pixelHeight]];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"d MMMM yyyy, HH:mm"];
    [self.modifiedLabel setText:[dateFormatter stringFromDate:self.asset.modificationDate]];
    [self.createdLabel setText:[dateFormatter stringFromDate:self.asset.creationDate]];
    
    if (self.asset.location == nil) {
        self.mapView.hidden = YES;
    } else {
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate: self.asset.location.coordinate];
        [self.mapView addAnnotation:annotation];
        [self.mapView setCenterCoordinate:self.asset.location.coordinate];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
