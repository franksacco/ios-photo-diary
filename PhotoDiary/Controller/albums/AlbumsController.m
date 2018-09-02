//
//  AlbumsViewController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 24/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "AlbumsController.h"
#import "AlbumPhotosController.h"
#import "AlbumCell.h"
#import "AppDelegate.h"
#import "Album+CoreDataClass.h"
#import "AlbumPhoto+CoreDataClass.h"
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>


@interface AlbumsController ()

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSArray<Album *> *albums;

@end


@implementation AlbumsController

static NSString * const reuseIdentifier = @"AlbumCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageManager = [[PHCachingImageManager alloc] init];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Album"];
    self.albums = [managedObjectContext executeFetchRequest:fetchRequest error:nil];
    NSLog(@"%ld album founded", self.albums.count);
    
    [self.collectionView reloadData];
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        context = [[delegate persistentContainer] viewContext];
    }
    return context;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showAlbumPhotos"]) {
        if ([segue.destinationViewController isKindOfClass:[AlbumPhotosController class]]) {
            AlbumPhotosController *cv = segue.destinationViewController;
            NSIndexPath *index = [self.collectionView indexPathForCell:(AlbumCell *)sender];
            cv.album = [self.albums objectAtIndex:index.row];
        }
    }
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return self.albums.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = (AlbumCell *)[collectionView
                                    dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                    forIndexPath:indexPath];
    Album *album = [self.albums objectAtIndex:indexPath.row];
    [cell.label setText:album.title];
    cell.image.layer.cornerRadius = 5;
    cell.image.layer.masksToBounds = YES;
    [cell.elementNumber setText:[NSString stringWithFormat:@"%ld elementi", album.photos.count]];
    if (album.photos.count > 0) {
        NSArray *identifiers = [[NSArray alloc] initWithObjects:[album.photos anyObject].localIdentifier, nil];
        PHFetchResult *asset = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
        [self.imageManager requestImageForAsset:[asset firstObject]
                                     targetSize:CGSizeMake(cell.image.bounds.size.width, cell.image.bounds.size.height)
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
                                      //NSLog(@"set image to album %@", album.title);
                                      cell.image.image = result;
                                  }];
    } else {
        cell.image.backgroundColor = [UIColor lightGrayColor];
    }
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat size = collectionView.bounds.size.width / 2.0;
    return CGSizeMake(size, size + 20);
}


@end
