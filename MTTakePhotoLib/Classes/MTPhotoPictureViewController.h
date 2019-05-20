//
//  MTPhotoPictureViewController.h
//  MTTakePictureDemo
//
//  Created by xiejc on 2019/5/16.
//  Copyright © 2019 xiejc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTPhotoPictureTakeView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MTPhotoPictureViewController : UIViewController

@property (nonatomic, copy) void(^photoFinishBlock)(UIImage *img);

//框上面的描述文字
@property (nonatomic, strong, nullable) NSString *desc;

@end

NS_ASSUME_NONNULL_END
