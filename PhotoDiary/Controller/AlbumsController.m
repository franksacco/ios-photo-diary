//
//  AlbumsViewController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 24/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "AlbumsController.h"
#import "AlbumCell.h"

@interface AlbumsController ()

@property (nonatomic, strong) NSMutableArray *albums;

@end


@implementation AlbumsController

static NSString * const reuseIdentifier = @"AlbumCell";


- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSManagedObjectContext *managedObjectContext = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Album"];
    [fetchRequest setReturnsObjectsAsFaults:NO];
    self.albums = [[managedObjectContext executeFetchRequest:fetchRequest error:nil] mutableCopy];
    NSLog(@"%ld album founded", self.albums.count);
    
    [self.collectionView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    AppDelegate *delegate = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([delegate respondsToSelector:@selector(persistentContainer)]) {
        context = [[delegate persistentContainer] viewContext];
    }
    return context;
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
    return self.albums.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
                                                                forIndexPath:indexPath];
    
    NSManagedObject *album = [self.albums objectAtIndex:indexPath.row];
    cell.image.backgroundColor = [UIColor lightGrayColor];
    [cell.label setText:[album valueForKey:@"title"]];
    return cell;
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout*)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat size = collectionView.bounds.size.width / 2.0;
    return CGSizeMake(size, size);
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

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
