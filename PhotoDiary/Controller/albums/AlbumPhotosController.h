//
//  AlbumPhotosController.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 27/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Album+CoreDataClass.h"

@interface AlbumPhotosController : UICollectionViewController

@property (nonatomic, strong) Album *album;

@end
