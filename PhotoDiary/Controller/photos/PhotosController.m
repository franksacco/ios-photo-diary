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

- (IBAction)openCamera:(UIBarButtonItem *)sender;

@end


@implementation PhotosController

static NSString * const reuseIdentifier = @"PhotoCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.imageManager = [[PHCachingImageManager alloc] init];
    
    self.selectionMode = NO;
    self.selectedPhotos = [[NSMutableArray alloc] init];
    self.clearsSelectionOnViewWillAppear = YES;
    self.collectionView.allowsMultipleSelection = YES;
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.addToButton.title = @"";
    self.addToButton.enabled = NO;
    [self.navigationItem setTitle:@"Foto"];
    [self.selectionButton setTitle:@"Seleziona"];
    self.selectionMode = NO;
    [self.selectedPhotos removeAllObjects];
    
    [self loadPhotos];
}


- (void)loadPhotos {
    PHFetchOptions *options = [[PHFetchOptions alloc] init];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    self.assetsFetchResults = [PHAsset fetchAssetsWithOptions:options];
    
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
    if (cell.selected) {
        [cell.image setAlpha:0.7];
        [cell.selectionIcon setHidden:NO];
    } else {
        [cell.image setAlpha:1];
        [cell.selectionIcon setHidden:YES];
    }
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
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    if (self.selectionMode) {
        [cell.image setAlpha:0.7];
        [cell.selectionIcon setHidden:NO];
        [self.selectedPhotos addObject:asset];
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
    PhotoCell *cell = (PhotoCell *)[collectionView cellForItemAtIndexPath:indexPath];
    [cell.image setAlpha:1];
    [cell.selectionIcon setHidden:YES];
    PHAsset *asset = self.assetsFetchResults[indexPath.item];
    [self.selectedPhotos removeObject:asset];
}


- (IBAction)toggleSelectionMode:(UIBarButtonItem *)sender {
    if (self.selectionMode) {
        self.addToButton.title = @"";
        self.addToButton.enabled = NO;
        [self.navigationItem setTitle:@"Foto"];
        [sender setTitle:@"Seleziona"];
        for (NSIndexPath *indexPath in [self.collectionView indexPathsForSelectedItems]) {
            [self.collectionView deselectItemAtIndexPath:indexPath animated:NO];
            [self collectionView:self.collectionView didDeselectItemAtIndexPath:indexPath];
        }
        [self.selectedPhotos removeAllObjects];
    } else {
        self.addToButton.title = @"Aggiungi";
        self.addToButton.enabled = YES;
        [self.navigationItem setTitle:@"Seleziona foto"];
        [sender setTitle:@"Annulla"];
    }
    self.selectionMode = !self.selectionMode;
}


- (IBAction)openCamera:(UIBarButtonItem *)sender {
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIAlertController *dialog =
            [UIAlertController alertControllerWithTitle:@"Errore"
                                                message:@"Questo dipositivo non ha la fotocamera"
                                         preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action =
            [UIAlertAction actionWithTitle:@"OK"
                                     style:UIAlertActionStyleDefault
                                   handler:nil];
        [dialog addAction:action];
        [self presentViewController:dialog animated:YES completion:nil];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    
    [self presentViewController:picker animated:YES completion:NULL];
}


#pragma mark <UIImagePickerControllerDelegate>

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *photo = info[UIImagePickerControllerEditedImage];
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        [PHAssetChangeRequest creationRequestForAssetFromImage:photo];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        if (!success) {
            NSLog(@"Error: %@, %@", error, error.localizedDescription);
        }
    }];
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self loadPhotos];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:NULL];
}


@end
