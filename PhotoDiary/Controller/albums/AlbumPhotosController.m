//
//  AlbumPhotosController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 27/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "AlbumPhotosController.h"
#import "AlbumPhotoController.h"
#import "EditAlbumController.h"
#import "AlbumPhotoCell.h"
#import "AlbumPhoto+CoreDataClass.h"
#import <Photos/Photos.h>


@interface AlbumPhotosController ()

@property (nonatomic, strong) PHFetchResult *assetsFetchResults;
@property (nonatomic, strong) PHCachingImageManager *imageManager;

@end


@implementation AlbumPhotosController

static NSString * const reuseIdentifier = @"AlbumPhotoCell";


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.title = self.album.title;
    
    NSSet<AlbumPhoto *> *albumPhotos = self.album.photos;
    NSMutableArray<NSString *> *identifiers = [[NSMutableArray alloc] initWithCapacity:albumPhotos.count];
    for (AlbumPhoto *photo in albumPhotos) {
        [identifiers addObject:photo.localIdentifier];
    }
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assetsFetchResults = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:options];
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
    if ([segue.identifier isEqualToString:@"showAlbumPhoto"]) {
        if ([segue.destinationViewController isKindOfClass:[AlbumPhotoController class]]) {
            //AlbumPhotoController *cv = [segue destinationViewController];
            
        }
    } else if ([segue.identifier isEqualToString:@"showEditAlbum"]) {
        if ([segue.destinationViewController isKindOfClass:[EditAlbumController class]]) {
            EditAlbumController *cv = segue.destinationViewController;
            cv.album = self.album;
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
    AlbumPhotoCell *cell = (AlbumPhotoCell *)[collectionView
                                              dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                              forIndexPath:indexPath];

    [self.imageManager requestImageForAsset:self.assetsFetchResults[indexPath.item]
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


@end
