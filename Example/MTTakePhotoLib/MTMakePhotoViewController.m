//
//  MTMakePhotoViewController.m
//  MTTakePhotoLib
//
//  Created by fayxjc@163.com on 05/17/2019.
//  Copyright (c) 2019 fayxjc@163.com. All rights reserved.
//

#import "MTMakePhotoViewController.h"

#import "MTPhotoPictureViewController.h"


@interface MTMakePhotoViewController ()

@property (nonatomic, weak) IBOutlet UIImageView *imgView;
@property (nonatomic, weak) IBOutlet UIView *renderView;


@property (nonatomic, weak) IBOutlet UIImageView *resizeImageView;

@end

@implementation MTMakePhotoViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.resizeImageView.contentMode =
    UIViewContentModeCenter;
}

- (IBAction)goToPhoto:(id)sender {
    MTPhotoPictureViewController *photoVC = [[MTPhotoPictureViewController alloc] init];
    photoVC.photoFinishBlock = ^(UIImage * _Nonnull img, UIImage * _Nonnull scaleImage) {
        self.imgView.image = scaleImage;
    };
    [self presentViewController:photoVC animated:YES completion:nil];
}



@end

