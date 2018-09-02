//
//  AlbumPhotoController.m
//  PhotoDiary
//
//  Created by Francesco Saccani on 27/08/18.
//  Copyright © 2018 Francesco Saccani. All rights reserved.
//

#import "AlbumPhotoController.h"
#import "AlbumPhotoDetailsController.h"
#import <FBSDKShareKit/FBSDKShareKit.h>


@interface AlbumPhotoController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property UIImage *image;

- (IBAction)shareClicked:(UIBarButtonItem *)sender;

@end


@implementation AlbumPhotoController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.scrollView setDelegate:self];
    [self.scrollView setMaximumZoomScale:4];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.albumPhoto.localIdentifier == nil) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)showImage:(UIImage *)image {
    self.image = image;
    [self.imageView setImage:image];
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
    if ([segue.identifier isEqualToString:@"showAlbumPhotoDetails"]) {
        if ([segue.destinationViewController isKindOfClass:[AlbumPhotoDetailsController class]]) {
            AlbumPhotoDetailsController *cv = segue.destinationViewController;
            cv.albumPhoto = self.albumPhoto;
            cv.asset = self.asset;
        }
    }
}


- (IBAction)shareClicked:(UIBarButtonItem *)sender {
    FBSDKSharePhoto *photo = [[FBSDKSharePhoto alloc] init];
    photo.image = self.image;
    photo.userGenerated = YES;
    FBSDKSharePhotoContent *content = [[FBSDKSharePhotoContent alloc] init];
    content.photos = @[photo];
    [FBSDKShareDialog showFromViewController:self
                                 withContent:content
                                    delegate:nil];
}


@end
