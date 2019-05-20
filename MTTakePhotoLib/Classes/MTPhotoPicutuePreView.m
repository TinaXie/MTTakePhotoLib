//
//  MTPhotoPicutuePreView.m
//  MTTakePictureDemo
//
//  Created by xiejc on 2019/5/16.
//  Copyright © 2019 xiejc. All rights reserved.
//

#import "MTPhotoPicutuePreView.h"
#import "MTPhotoPictureTakeView.h"

#import "Masonry.h"
#import "MTTools.h"

@interface MTPhotoPicutuePreView ()

@end

@implementation MTPhotoPicutuePreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blackColor];
        
        self.imgView = [[UIImageView alloc] init];
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.backgroundColor = [UIColor clearColor];
        self.imgView.clipsToBounds = YES;
        [self addSubview:self.imgView];
        
        [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self).mas_offset(15.0);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.centerY.mas_equalTo(self.mas_centerY).multipliedBy(0.9);
            make.height.mas_equalTo(self.mas_height).multipliedBy(0.25);
        }];
        
        self.rePictureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.rePictureBtn setTitle:@"重拍" forState:UIControlStateNormal];
        [self addSubview:self.rePictureBtn];
        
        [self.rePictureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.mas_left).mas_offset(15.0);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-15.0);
            make.height.mas_equalTo(40.0);
            make.width.mas_equalTo(60.0);
        }];
        
        self.useBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.useBtn setTitle:@"使用" forState:UIControlStateNormal];
        [self addSubview:self.useBtn];
        [self.useBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.mas_right).mas_offset(-15.0);
            make.bottom.mas_equalTo(self.rePictureBtn.mas_bottom);
            make.height.mas_equalTo(self.rePictureBtn.mas_height);
            make.width.mas_equalTo(self.rePictureBtn.mas_width);
        }];
        
        self.useBtn.exclusiveTouch = self.rePictureBtn.exclusiveTouch = YES;
        
        self.rePictureBtn.titleLabel.textColor = self.useBtn.titleLabel.textColor = [UIColor whiteColor];
        self.rePictureBtn.titleLabel.font = self.useBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        self.rePictureBtn.backgroundColor = self.useBtn.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}


@end
