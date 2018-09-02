//
//  AlbumPhotoDetailsController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 29/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "AlbumPhotoDetailsController.h"
#import "AlbumPhotosController.h"
#import "AppDelegate.h"
#import <MapKit/MapKit.h>


@interface AlbumPhotoDetailsController ()

@property (weak, nonatomic) IBOutlet UILabel *mediaTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *mediaSubtypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dimensionLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifiedLabel;
@property (weak, nonatomic) IBOutlet UILabel *createdLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender;
- (IBAction)delete:(UIBarButtonItem *)sender;

@end


@implementation AlbumPhotoDetailsController

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
        [self.addressLabel setText:@"Non disponibile"];
        self.mapView.hidden = YES;
    } else {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder reverseGeocodeLocation:self.asset.location
                       completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                           if (error == nil && placemarks.count > 0) {
                               CLPlacemark *placemark = placemarks[0];
                               [self.addressLabel setText:
                                [NSString stringWithFormat:@"%@ %@, %@ %@",
                                 placemark.thoroughfare, placemark.subThoroughfare,
                                 placemark.postalCode, placemark.locality]];
                           } else {
                               NSLog(@"Error: %@ %@", error, error.localizedDescription);
                           }
                       }];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate: self.asset.location.coordinate];
        [self.mapView addAnnotation:annotation];
        [self.mapView setCenterCoordinate:self.asset.location.coordinate];
    }
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        context = [[delegate persistentContainer] viewContext];
    }
    return context;
}


- (IBAction)closeButtonClicked:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)delete:(UIBarButtonItem *)sender {
    UIAlertController *dialog =
    [UIAlertController alertControllerWithTitle:@"Elimina foto"
                                        message:@"La foto verrà eliminata solo all'interno di questo album e il file rimarrà nella libreria, confermi?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *confirmAction =
    [UIAlertAction actionWithTitle:@"Conferma"
                             style:UIAlertActionStyleDestructive
                           handler:^(UIAlertAction * _Nonnull action) {
                               [self deletePhoto];
                           }];
    [dialog addAction:confirmAction];
    UIAlertAction *cancelAction =
    [UIAlertAction actionWithTitle:@"Annulla"
                             style:UIAlertActionStyleCancel
                           handler:nil];
    [dialog addAction:cancelAction];
    
    [self presentViewController:dialog animated:YES completion:nil];
}

- (void)deletePhoto {
    NSManagedObjectContext *context = [self managedObjectContext];
    [context deleteObject:self.albumPhoto];
    NSError *error = nil;
    if (![context save:&error]) {
        NSLog(@"Deleting error: %@ %@", error, [error localizedDescription]);
    }
    self.albumPhoto.localIdentifier = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
