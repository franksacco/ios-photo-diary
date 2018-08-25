//
//  FotoViewController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 23/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "PhotosController.h"
#import "PhotoCell.h"
#import <Photos/Photos.h>

@interface PhotosController ()

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end


@implementation PhotosController

static NSString * const reuseIdentifier = @"PhotoCell";


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    _assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    _imageManager = [[PHCachingImageManager alloc] init];
    NSLog(@"%td images founded", _assetsFetchResults.count);
    
    [self.collectionView reloadData];
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

// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView
shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}


- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //PHAsset *selected = _assetsFetchResults[indexPath.item];
    NSLog(@"selected: %td", indexPath.item);
}

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
