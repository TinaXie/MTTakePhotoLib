//
//  YYPhotoPictureGestureView.h
//  MTTakePictureDemo
//
//  Created by xiejc on 2019/5/16.
//  Copyright © 2019 xiejc. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol YYPhotoPictureGestureViewDelegate <NSObject>

- (void)photoPictureGestureViewDidPinchGesture:(UIPinchGestureRecognizer *)recognizer;

@end

@interface YYPhotoPictureGestureView : UIView

@property (nonatomic, assign) id<YYPhotoPictureGestureViewDelegate> delegate;

/**
 *  记录开始的缩放比例
 */
@property(nonatomic,assign) CGFloat beginGestureScale;
/**
 * 最后的缩放比例
 */
@property(nonatomic,assign) CGFloat effectiveScale;



@end

NS_ASSUME_NONNULL_END
