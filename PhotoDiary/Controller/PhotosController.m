//
//  FotoViewController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 23/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "PhotosController.h"
#import "PhotoController.h"
#import "PhotoCell.h"
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>

@interface PhotosController ()

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property BOOL selectionMode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectionButton;
- (IBAction)toggleSelectionMode:(UIBarButtonItem *)sender;

@end


@implementation PhotosController

static NSString * const reuseIdentifier = @"PhotoCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.selectionMode = NO;
    
    self.collectionView.allowsMultipleSelection = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    _assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    _imageManager = [[PHCachingImageManager alloc] init];
    NSLog(@"%td images founded", _assetsFetchResults.count);
    [self.collectionView reloadData];
    
    if (self.selectionMode) {
        [self toggleSelectionMode:self.selectionButton];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.assetsFetchResults.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *) [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                              forIndexPath:indexPath];
    PHAsset *asset = _assetsFetchResults[indexPath.item];
    [_imageManager requestImageForAsset:asset
                             targetSize:CGSizeMake(150, 150)
                            contentMode:PHImageContentModeAspectFill
                                options:nil
                          resultHandler:^(UIImage *result, NSDictionary *info) {
                              cell.image.opaque = NO;
                              cell.image.image = result;
                          }];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat size = (collectionView.bounds.size.width - 6.0) / 4.0;
    return CGSizeMake(size, size);
}


#pragma mark <UICollectionViewDelegate>


- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView
                                    dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                    forIndexPath:indexPath];
    if (self.selectionMode) {
        [cell.layer setBorderColor:[UIColor blueColor].CGColor];
        [cell.layer setBorderWidth:2];
        [cell reloadInputViews];
        NSLog(@"cell layer: %@", cell.layer);
        // save selection
        //[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    } else {
        [self viewImageForIndexPath:indexPath];
    }
}

- (void)viewImageForIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotoController *controller = (PhotoController *)[storyboard instantiateViewControllerWithIdentifier:@"PhotoController"];
    [self.navigationController pushViewController:controller
                                         animated:YES];
    
    PHAsset *asset = _assetsFetchResults[indexPath.item];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.resizeMode   = PHImageRequestOptionsResizeModeExact;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [_imageManager requestImageForAsset:asset
                             targetSize:PHImageManagerMaximumSize
                            contentMode:PHImageContentModeDefault
                                options:nil //options
                          resultHandler:^(UIImage *result, NSDictionary *info) {
                              [controller setImage:result withAsset:asset];
                          }];
}


- (BOOL)collectionView:(UICollectionView *)collectionView
shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView
didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    PhotoCell *cell = (PhotoCell *)[collectionView
                                    dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                    forIndexPath:indexPath];
    [cell.layer setBorderWidth:0];
    NSLog(@"deselected: %@", cell);
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
}


- (IBAction)toggleSelectionMode:(UIBarButtonItem *)sender {
    if (self.selectionMode) {
        [self.navigationItem setTitle:@"Foto"];
        [sender setTitle:@"Seleziona"];
        for (int i = 0; i < _assetsFetchResults.count; i++) {
            for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
                [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            }
        }
    } else {
        [self.navigationItem setTitle:@"Seleziona foto"];
        [sender setTitle:@"Annulla"];
    }
    self.selectionMode = !self.selectionMode;
}


@end
