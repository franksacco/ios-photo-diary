//
//  AlbumPhotoDetailsController.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 29/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "AlbumPhoto+CoreDataClass.h"


@interface AlbumPhotoDetailsController : UITableViewController

@property AlbumPhoto *albumPhoto;
@property PHAsset *asset;

@end
