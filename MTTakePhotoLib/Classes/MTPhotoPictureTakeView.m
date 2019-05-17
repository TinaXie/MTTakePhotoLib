//
//  MTPhotoPictureTakeView.m
//  MTTakePictureDemo
//
//  Created by xiejc on 2019/5/16.
//  Copyright © 2019 xiejc. All rights reserved.
//

#import "MTPhotoPictureTakeView.h"
#import "YYPhotoPictureGestureView.h"

#import "Masonry.h"
#import "MTTools.h"

@interface MTPhotoPictureTakeView ()
<YYPhotoPictureGestureViewDelegate>

@property (nonatomic, strong) UIView *videoView;
@property (nonatomic, strong) YYPhotoPictureGestureView *gestureView;

//切换摄像头
@property (nonatomic, strong) UIButton *changeCameraBtn;
//闪光灯
@property (nonatomic, strong) UIButton *flashBtn;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, assign) BOOL isUsingFrontFacingCamera;


/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput *stillImageOutput;

@end

@implementation MTPhotoPictureTakeView


- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
        self.isUsingFrontFacingCamera = NO;
        [self updateFlashButton];

    }
    return self;
}

- (void) initView {
    self.videoView = [[UIView alloc] init];
    self.videoView.backgroundColor = [UIColor clearColor];
    self.videoView.layer.masksToBounds = YES;
    [self addSubview:self.videoView];
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(self);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.bottom.mas_equalTo(self).mas_offset(-100);
    }];

    //初始化预览图层
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] init];

    [self.previewLayer setVideoGravity:AVLayerVideoGravityResize];
    [self.videoView.layer addSublayer:self.previewLayer];
    
    self.flashBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.flashBtn setTitle:@"闪光灯" forState:UIControlStateNormal];
    [self.flashBtn addTarget:self action:@selector(flashButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.flashBtn];
    
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).mas_offset(15.0);
        make.left.mas_equalTo(self).mas_offset(15.0);

        make.width.mas_equalTo(80);
        make.height.mas_equalTo(40);
    }];
    
    self.changeCameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.changeCameraBtn setTitle:@"切换摄像头" forState:UIControlStateNormal];
    [self.changeCameraBtn addTarget:self action:@selector(switchCamera:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.changeCameraBtn];
    
    [self.changeCameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.flashBtn.mas_top);
        make.right.mas_equalTo(self.mas_right).mas_offset(-15.0);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(40);
    }];
    
    self.changeCameraBtn.titleLabel.textColor = self.flashBtn.titleLabel.textColor = [UIColor whiteColor];
    self.changeCameraBtn.titleLabel.font = self.flashBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    self.changeCameraBtn.backgroundColor = self.flashBtn.backgroundColor = [UIColor clearColor];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.lineView];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).mas_offset(15.0);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY).multipliedBy(0.8);
        make.height.mas_equalTo(self.mas_height).multipliedBy(0.4);
    }];
    
    
    self.descLabel = [[UILabel alloc] init];
    self.descLabel.text = @"请瞄准扫描物放入框内";
    self.descLabel.textAlignment = NSTextAlignmentCenter;
    self.descLabel.textColor = [UIColor whiteColor];
    self.descLabel.font = MT_PingFangSC_LightFont(16);
    self.descLabel.backgroundColor = [UIColor clearColor];
    [self addSubview:self.descLabel];
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(20.0);
        make.bottom.mas_equalTo(self.lineView.mas_top).mas_offset(-10.0);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColor blackColor];
    [self addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(self);
        make.height.mas_equalTo(100);
    }];
    
    self.photoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.photoBtn.backgroundColor = [UIColor whiteColor];
    [self.bottomView addSubview:self.photoBtn];
    
    [self.photoBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.bottomView.mas_centerX);
        make.bottom.mas_equalTo(self.bottomView).mas_offset(-20);
        make.width.height.mas_equalTo(60.0);
    }];
    
    
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.cancelBtn.backgroundColor = [UIColor clearColor];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [self.bottomView addSubview:self.cancelBtn];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.photoBtn.mas_centerY);
        make.left.mas_equalTo(self.bottomView).mas_offset(20);
        make.width.mas_equalTo(60.0);
        make.height.mas_equalTo(30.0);
    }];
    
    self.changeCameraBtn.exclusiveTouch = self.photoBtn.exclusiveTouch = self.cancelBtn.exclusiveTouch = YES;

    
//    self.gestureView = [[YYPhotoPictureGestureView alloc] init];
//    self.gestureView.delegate = self;
//    [self addSubview:self.gestureView];
//    [self.gestureView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.mas_equalTo(self.lineView);
//    }];
    
    self.flashBtn.hidden = self.changeCameraBtn.hidden = YES;
}

- (CGRect)getCoverRect {
    CGRect takeRect = [self convertRect:self.lineView.frame toView:self.videoView];
    return takeRect;
}

- (void)loadAVSession:(AVCaptureSession *)session imageOutput:(AVCaptureStillImageOutput *)imageOutput {
    self.stillImageOutput = imageOutput;
    self.previewLayer.session = session;
}


- (IBAction)flashButtonClick:(UIButton *)sender {
    NSLog(@"flashButtonClick");
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //修改前必须先锁定
    [device lockForConfiguration:nil];
    //必须判定是否有闪光灯，否则如果没有闪光灯会崩溃
    if ([device hasFlash]) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            device.flashMode = AVCaptureFlashModeOn;
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            device.flashMode = AVCaptureFlashModeAuto;
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            device.flashMode = AVCaptureFlashModeOff;
        }
    } else {
        NSLog(@"设备不支持闪光灯");
    }
    [self updateFlashButton];
    [device unlockForConfiguration];
}

- (void)updateFlashButton {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.flashBtn.hidden = ![device hasFlash];
    NSString *flashTitle = nil;
    if (!self.flashBtn.hidden) {
        if (device.flashMode == AVCaptureFlashModeOff) {
            flashTitle = @"打开闪光灯";
        } else if (device.flashMode == AVCaptureFlashModeOn) {
            flashTitle = @"自动";
        } else if (device.flashMode == AVCaptureFlashModeAuto) {
            flashTitle = @"关闭闪光灯";
        }
    }
    [self.flashBtn setTitle:flashTitle forState:UIControlStateNormal];

}

- (IBAction)switchCamera:(UIButton *)sender {
    NSLog(@"switchCameraSegmentedControlClick %ld", (long)sender);
    
    AVCaptureDevicePosition desiredPosition;
    if (self.isUsingFrontFacingCamera){
        desiredPosition = AVCaptureDevicePositionBack;
    } else {
        desiredPosition = AVCaptureDevicePositionFront;
    }
    
    for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
        if ([d position] == desiredPosition) {
            [self.previewLayer.session beginConfiguration];
            AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:d error:nil];
            for (AVCaptureInput *oldInput in self.previewLayer.session.inputs) {
                [[self.previewLayer session] removeInput:oldInput];
            }
            [self.previewLayer.session addInput:input];
            [self.previewLayer.session commitConfiguration];
            break;
        }
    }
    
    self.isUsingFrontFacingCamera = !self.isUsingFrontFacingCamera;
}


#pragma mark - YYPhotoPictureGestureViewDelegate

//缩放手势 用于调整焦距
- (void)photoPictureGestureViewDidPinchGesture:(UIPinchGestureRecognizer *)recognizer {
    
    BOOL allTouchesAreOnThePreviewLayer = YES;
    NSUInteger numTouches = [recognizer numberOfTouches], i;
    for ( i = 0; i < numTouches; ++i ) {
        CGPoint location = [recognizer locationOfTouch:i inView:self.gestureView];
        CGPoint convertedLocation = [self.previewLayer convertPoint:location fromLayer:self.previewLayer.superlayer];
        if ( ! [self.previewLayer containsPoint:convertedLocation] ) {
            allTouchesAreOnThePreviewLayer = NO;
            break;
        }
    }
    
    if (allTouchesAreOnThePreviewLayer ) {
        self.gestureView.effectiveScale = self.gestureView.beginGestureScale * recognizer.scale;
        if (self.gestureView.effectiveScale < 1.0){
            self.gestureView.effectiveScale = 1.0;
        }
        CGFloat maxScaleAndCropFactor = [[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] videoMaxScaleAndCropFactor];
        
        NSLog(@"======handlePinchGesture:%f",maxScaleAndCropFactor);
        if (self.gestureView.effectiveScale > maxScaleAndCropFactor) {
            self.gestureView.effectiveScale = maxScaleAndCropFactor;
        }
        
        [CATransaction begin];
        [CATransaction setAnimationDuration:.025];
        [self.previewLayer setAffineTransform:CGAffineTransformMakeScale(self.gestureView.effectiveScale, self.gestureView.effectiveScale)];
        [CATransaction commit];
        
    }
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.lineView cornerWithRadius:0.1 borderColor:[UIColor whiteColor]];
    self.previewLayer.frame = self.videoView.bounds;
}

@end
