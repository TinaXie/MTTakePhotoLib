//
//  MTPhotoPictureTakeView.h
//  MTTakePictureDemo
//
//  Created by xiejc on 2019/5/16.
//  Copyright © 2019 xiejc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

NS_ASSUME_NONNULL_BEGIN

#define MTPhotoPictureH 

@interface MTPhotoPictureTakeView : UIView


@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UIView *lineView;

//预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

//拍照
@property (nonatomic, strong) UIButton *photoBtn;

@property (nonatomic, strong) UIButton *cancelBtn;

- (void)loadAVSession:(AVCaptureSession *)session imageOutput:(AVCaptureStillImageOutput *)imageOutput;

- (CGRect)getCoverRect;

@end

NS_ASSUME_NONNULL_END
