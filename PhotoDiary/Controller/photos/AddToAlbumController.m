//
//  AddToAlbumControllerCollectionViewController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 28/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "AppDelegate.h"
#import "AddToAlbumController.h"
#import "AlbumCell.h"
#import "Album+CoreDataClass.h"
#import "AlbumPhoto+CoreDataClass.h"
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>


@interface AddToAlbumController ()

@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) NSArray<Album *> *albums;
- (IBAction)cancel:(UIButton *)sender;

@end


@implementation AddToAlbumController

static NSString * const reuseIdentifier = @"AddToAlbumCell";


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


- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    [cell.image.layer setCornerRadius:5];
    [cell.elementNumber setText:[NSString stringWithFormat:@"%ld elementi", album.photos.count]];
    if (album.photos.count > 0) {
        NSArray *identifiers = [[NSArray alloc] initWithObjects:[album.photos anyObject].localIdentifier, nil];
        PHFetchResult *asset = [PHAsset fetchAssetsWithLocalIdentifiers:identifiers options:nil];
        [self.imageManager requestImageForAsset:[asset firstObject]
                                     targetSize:CGSizeMake(cell.image.bounds.size.width, cell.image.bounds.size.height)
                                    contentMode:PHImageContentModeAspectFill
                                        options:nil
                                  resultHandler:^(UIImage *result, NSDictionary *info) {
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
    return CGSizeMake(size, size);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if (kind == UICollectionElementKindSectionHeader) {
        UICollectionReusableView *header =
            [collectionView
             dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
             withReuseIdentifier:@"addToAlbumHeader" forIndexPath:indexPath];
        return header;
    }
    return nil;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(UIScreen.mainScreen.bounds.size.width, 60);
}


#pragma mark <UICollectionViewDelegate>

- (BOOL)collectionView:(UICollectionView *)collectionView
shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}


- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    Album *album = [self.albums objectAtIndex:indexPath.row];
    NSManagedObjectContext *context = [self managedObjectContext];
    for (PHAsset *asset in self.photos) {
        if (![self isAsset:asset alreadyInAlbum:album]) {
            AlbumPhoto *photo = (AlbumPhoto *)[NSEntityDescription
                                               insertNewObjectForEntityForName:@"AlbumPhoto"
                                               inManagedObjectContext:context];
            photo.localIdentifier = asset.localIdentifier;
            [album addPhotosObject:photo];
            NSLog(@"photo added: %@", photo);
        }
    }
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"Error during photos inserting: %@ %@", error, [error localizedDescription]);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)isAsset:(PHAsset *)asset alreadyInAlbum:(Album *)album {
    for (AlbumPhoto *photo in album.photos) {
        if ([photo.localIdentifier isEqualToString:asset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}


@end
