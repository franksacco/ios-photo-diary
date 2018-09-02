//
//  AlbumPhotoController.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 27/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "AlbumPhoto+CoreDataClass.h"


@interface AlbumPhotoController : UIViewController<UIScrollViewDelegate>

@property PHAsset *asset;
@property AlbumPhoto *albumPhoto;
- (void)showImage:(UIImage *)image;

@end
