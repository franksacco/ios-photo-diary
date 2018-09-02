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
#import <QuartzCore/QuartzCore.h>


@interface AlbumPhotosController ()

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) PHFetchResult *assetsFetchResults;

@end


@implementation AlbumPhotosController

static NSString * const reuseIdentifier = @"AlbumPhotoCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageManager = [[PHCachingImageManager alloc] init];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.album.title == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    self.title = self.album.title;
    
    NSSet<AlbumPhoto *> *albumPhotos = self.album.photos;
    NSMutableArray<NSString *> *identifiers = [[NSMutableArray alloc] initWithCapacity:albumPhotos.count];
    for (AlbumPhoto *photo in albumPhotos) {
        [identifiers addObject:photo.localIdentifier];
    }
    self.assetsFetchResults = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
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
            NSIndexPath *index = [self.collectionView indexPathForCell:(AlbumPhotoCell *)sender];
            
            PHAsset *asset = [self.assetsFetchResults objectAtIndex:index.row];
            AlbumPhoto *albumPhoto;
            for (albumPhoto in [self.album.photos allObjects]) {
                if ([albumPhoto.localIdentifier isEqualToString:asset.localIdentifier]) {
                    break;
                }
            }
            
            AlbumPhotoController *cv = [segue destinationViewController];
            cv.asset = asset;
            cv.albumPhoto = albumPhoto;
            [self.imageManager requestImageForAsset:asset
                                         targetSize:PHImageManagerMaximumSize
                                        contentMode:PHImageContentModeDefault
                                            options:nil
                                      resultHandler:^(UIImage *result, NSDictionary *info) {
                                          [cv showImage:result];
                                      }];
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


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *header =
        [collectionView
         dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
         withReuseIdentifier:@"albumHeader" forIndexPath:indexPath];
        
        UIView *padding = [[UIView alloc] initWithFrame:
                           CGRectMake(16, 16, header.bounds.size.width-32, header.bounds.size.height-32)];
        UILabel *label = [[UILabel alloc] initWithFrame:
                          CGRectMake(0, 0, padding.bounds.size.width, padding.bounds.size.height)];
        [label setText:self.album.desc];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textColor = [UIColor grayColor];
        
        [padding addSubview:label];
        [header addSubview:padding];
        return header;
    }
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(UIScreen.mainScreen.bounds.size.width, [self.album.desc length] == 0 ? 0 : 80);
}


@end
