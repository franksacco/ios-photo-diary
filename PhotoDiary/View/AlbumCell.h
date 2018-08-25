//
//  AlbumCell.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 25/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlbumCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end
