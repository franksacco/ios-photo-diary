//
//  PhotoViewCell.h
//  PhotoDiary
//
//  Created by Francesco Saccani on 24/08/2018.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PhotoCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *selectionIcon;

@end
