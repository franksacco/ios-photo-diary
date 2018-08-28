//
//  AddToAlbumControllerCollectionViewController.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 28/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


@interface AddToAlbumController : UICollectionViewController

@property (nonatomic, strong) NSMutableArray<PHAsset *> *photos;

@end
