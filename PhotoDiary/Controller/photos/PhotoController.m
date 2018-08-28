//
//  PhotoController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 26/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "PhotoController.h"
#import "PhotoDetailsController.h"

@interface PhotoController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property PHAsset *asset;

@end


@implementation PhotoController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.scrollView setDelegate:self];
    [self.scrollView setMaximumZoomScale:4];
}


- (void)setImage:(UIImage *)image withAsset:(PHAsset *)asset {
    [self.imageView setImage:image];
    self.asset = asset;
    
    [self.scrollView setMinimumZoomScale:
        self.scrollView.frame.size.width / self.imageView.frame.size.width];
    [self.scrollView setContentSize:
        CGSizeMake(self.imageView.frame.size.width, self.imageView.frame.size.height)];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPhotoDetails"]) {
        if ([[segue destinationViewController] isKindOfClass:[PhotoDetailsController class]]) {
            PhotoDetailsController *cv = [segue destinationViewController];
            cv.asset = self.asset;
        }
    }
}


@end
