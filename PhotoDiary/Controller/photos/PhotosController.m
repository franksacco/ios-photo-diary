//
//  FotoViewController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 23/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "PhotosController.h"
#import "PhotoController.h"
#import "AddToAlbumController.h"
#import "PhotoCell.h"
#import "Album+CoreDataProperties.h"
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>


@interface PhotosController ()

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@property BOOL selectionMode;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *selectionButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addToButton;
@property (nonatomic, strong) NSMutableArray<PHAsset *> *selectedPhotos;
- (IBAction)toggleSelectionMode:(UIBarButtonItem *)sender;

@end


@implementation PhotosController

static NSString * const reuseIdentifier = @"PhotoCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectionMode = NO;
    self.selectedPhotos = [[NSMutableArray alloc] init];
    self.clearsSelectionOnViewWillAppear = YES;
    self.collectionView.allowsMultipleSelection = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationItem.leftBarButtonItem.title = @"";
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self.navigationItem setTitle:@"Foto"];
    [self.selectionButton setTitle:@"Seleziona"];
    [self.selectedPhotos removeAllObjects];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    self.imageManager = [[PHCachingImageManager alloc] init];
    NSLog(@"%td images founded", self.assetsFetchResults.count);
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAddToAlbum"]) {
        if ([segue.destinationViewController isKindOfClass:[AddToAlbumController class]]) {
            AddToAlbumController *cv = segue.destinationViewController;
            cv.photos = self.selectedPhotos;
        }
    }
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
    PhotoCell *cell = (PhotoCell *)[collectionView
                                    dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                    forIndexPath:indexPath];
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.imageManager requestImageForAsset:asset
                                 targetSize:CGSizeMake(cell.bounds.size.width, cell.bounds.size.height)
                                contentMode:PHImageContentModeAspectFill
                                    options:nil
                              resultHandler:^(UIImage *result, NSDictionary *info) {
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
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    if (self.selectionMode) {
        [self.selectedPhotos addObject:asset];
        NSLog(@"selected: %@", cell);
    } else {
        [self viewImageForAsset:asset];
    }
}

- (void)viewImageForAsset:(PHAsset *)asset {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PhotoController *controller =
        (PhotoController *)[storyboard instantiateViewControllerWithIdentifier:@"PhotoController"];
    [self.navigationController pushViewController:controller
                                         animated:YES];
    [self.imageManager requestImageForAsset:asset
                                 targetSize:PHImageManagerMaximumSize
                             contentMode:PHImageContentModeDefault
                                 options:nil
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
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    // change layout
    [self.selectedPhotos removeObject:asset];
    NSLog(@"deselected: %@", cell);
}


- (IBAction)toggleSelectionMode:(UIBarButtonItem *)sender {
    if (self.selectionMode) {
        self.navigationItem.leftBarButtonItem.title = @"";
        self.navigationItem.leftBarButtonItem.enabled = NO;
        [self.navigationItem setTitle:@"Foto"];
        [sender setTitle:@"Seleziona"];
        for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
        }
        [self.selectedPhotos removeAllObjects];
    } else {
        self.navigationItem.leftBarButtonItem.title = @"Aggiungi";
        self.navigationItem.leftBarButtonItem.enabled = YES;
        [self.navigationItem setTitle:@"Seleziona foto"];
        [sender setTitle:@"Annulla"];
    }
    self.selectionMode = !self.selectionMode;
}


@end
