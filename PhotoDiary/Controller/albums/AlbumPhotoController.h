//
//  AlbumPhotoController.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 27/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@interface AlbumPhotoController : UIViewController<UIScrollViewDelegate>

- (void)setImage:(UIImage *)image withAsset:(PHAsset *)asset;

@end
