//
//  YYPhotoPictureGestureView.m
//  MTTakePictureDemo
//
//  Created by xiejc on 2019/5/16.
//  Copyright © 2019 xiejc. All rights reserved.
//

#import "YYPhotoPictureGestureView.h"

@implementation YYPhotoPictureGestureView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addGesture];
    }
    return self;
}

- (void)addGesture {
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self addGestureRecognizer:pinchGesture];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIPinchGestureRecognizer class]] ) {
        self.beginGestureScale = self.effectiveScale;
    }
    return YES;
}


//缩放手势 用于调整焦距
- (void)handlePinchGesture:(UIPinchGestureRecognizer *)recognizer {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoPictureGestureViewDidPinchGesture:)]) {
        [self.delegate photoPictureGestureViewDidPinchGesture:recognizer];
    }
}


@end
