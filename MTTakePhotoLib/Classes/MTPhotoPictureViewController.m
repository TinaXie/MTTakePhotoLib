//
//  MTPhotoPictureViewController.m
//  MTTakePictureDemo
//
//  Created by xiejc on 2019/5/16.
//  Copyright © 2019 xiejc. All rights reserved.
//

#import "MTPhotoPictureViewController.h"
#import "MTPhotoPicutuePreView.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "Masonry.h"
#import "MTTools.h"

@interface MTPhotoPictureViewController ()

/**
 *  AVCaptureSession对象来执行输入设备和输出设备之间的数据传递
 */
@property (nonatomic, strong) AVCaptureSession *session;
/**
 *  输入设备
 */
@property (nonatomic, strong) AVCaptureDeviceInput* videoInput;
/**
 *  照片输出流
 */
@property (nonatomic, strong) AVCaptureStillImageOutput* stillImageOutput;

@property (nonatomic, strong) AVCaptureConnection *stillImageConnection;

@property (nonatomic, strong) MTPhotoPictureTakeView *takeView;
@property (nonatomic, strong) MTPhotoPicutuePreView *preView;

@property (nonatomic, strong) UIImage *pictureImage;

@end

@implementation MTPhotoPictureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initAVCaptureSession];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    [self startAVCapture];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:YES];
    
    [self stopAVCapture];
}

- (void)initAVCaptureSession {
    self.session = [[AVCaptureSession alloc] init];
    self.session.sessionPreset = AVCaptureSessionPresetPhoto;
    NSError *error;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //更改这个设置的时候必须先锁定设备，修改完后再解锁，否则崩溃
    [device lockForConfiguration:nil];
    //设置闪光灯为自动
    [device setFlashMode:AVCaptureFlashModeAuto];
    [device unlockForConfiguration];
    
    self.videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
    if (error) {
        NSLog(@"initAVCaptureSession:%@", error);
    }
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    //输出设置。AVVideoCodecJPEG   输出jpeg格式图片
    NSDictionary * outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];

    if ([self.session canAddInput:self.videoInput]) {
        [self.session addInput:self.videoInput];
    }
    if ([self.session canAddOutput:self.stillImageOutput]) {
        [self.session addOutput:self.stillImageOutput];
    }
}

-(AVCaptureVideoOrientation)avOrientationForDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation result = (AVCaptureVideoOrientation)deviceOrientation;
    if ( deviceOrientation == UIDeviceOrientationLandscapeLeft )
        result = AVCaptureVideoOrientationLandscapeRight;
    else if ( deviceOrientation == UIDeviceOrientationLandscapeRight )
        result = AVCaptureVideoOrientationLandscapeLeft;
    return result;
}


#pragma mark - ui

- (void)initView {
    self.view.backgroundColor = [UIColor blackColor];
    self.takeView = [[MTPhotoPictureTakeView alloc] init];
    [self.view addSubview:self.takeView];
    [self.takeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
    [self.takeView loadAVSession:self.session imageOutput:self.stillImageOutput];
    [self.takeView.photoBtn addTarget:self action:@selector(takePhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.takeView.cancelBtn addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
}


- (void)closeView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)showCaptureImage {
    if (self.preView == nil) {
        self.preView = [[MTPhotoPicutuePreView alloc] init];
        [self.view addSubview:self.preView];
        [self.preView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.view);
        }];
        [self.preView.rePictureBtn addTarget:self action:@selector(reTakePhoto:) forControlEvents:UIControlEventTouchUpInside];
        [self.preView.useBtn addTarget:self action:@selector(usePhoto:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    [self.view bringSubviewToFront:self.preView];
    self.preView.hidden = NO;
    self.preView.imgView.image = self.pictureImage;
}


- (void)startAVCapture {
    if (self.session) {
        [self.session startRunning];
    }
}

- (void)stopAVCapture {
    if (self.session) {
        [self.session stopRunning];
    }
}

- (IBAction)reTakePhoto:(id)sender {
    self.preView.hidden = YES;
    self.preView.imgView.image = nil;
    self.pictureImage = nil;
    [self startAVCapture];
}

- (IBAction)usePhoto:(id)sender {
    if (self.photoFinishBlock) {
        self.photoFinishBlock(self.pictureImage);
    }
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"====dismiss====use");
    }];
}

//点击拍照
- (IBAction)takePhotoButtonClick:(UIButton *)sender {
    AVCaptureConnection *stillImageConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    AVCaptureVideoOrientation avcaptureOrientation = [self avOrientationForDeviceOrientation:curDeviceOrientation];
    [stillImageConnection setVideoOrientation:avcaptureOrientation];
    [stillImageConnection setVideoScaleAndCropFactor:1];

    self.stillImageConnection = stillImageConnection;
    
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:stillImageConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

            NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            
            if (error) {
                NSLog(@"===image data error:%@", error.localizedDescription);
                return;
            }
            
            if (imgData == nil ) {
                NSLog(@"===no more image data");
                return;
            }
            
            [self stopAVCapture];
            
            UIImage *originImg = [UIImage imageWithData:imgData];
            [self getTakeImage:originImg];
            [self showCaptureImage];
        });
    }];
}


- (void)getTakeImage:(UIImage *)originImg {
    //先按比例缩放
    CGFloat outSizeW = self.takeView.frame.size.width;
    CGFloat ratio = outSizeW / originImg.size.width;
    UIImage *scaleImage = [originImg scaleImageToRatio:ratio];

    CGRect coverRect = [self.takeView getCoverRect];
    
    //先横向截屏
    CGRect takeRectW = coverRect;
    takeRectW.origin.y = 0;
    takeRectW.size.height = scaleImage.size.height;
    UIImage *cropImage1 = [scaleImage cropImageInRect:takeRectW];

    
    
    //修正preview图片大于取图的高度 先将图片放大后再进行竖向截图
    CGFloat preferredH = self.takeView.previewLayer.preferredFrameSize.height;
    if (preferredH > scaleImage.size.height) {
        CGFloat ratio = preferredH / scaleImage.size.height;
        cropImage1 = [cropImage1 scaleImageToRatio:ratio];
    }

    CGRect takeRectH = coverRect;
    takeRectH.origin.x = 0;
    takeRectH.size.width = cropImage1.size.width;
    
    UIImage *cropImage = [cropImage1 cropImageInRect:takeRectH];
    self.pictureImage = cropImage;
}


@end


