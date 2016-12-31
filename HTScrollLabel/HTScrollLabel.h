//
//  HTScrollLabel.h
//  HTScrollLabel
//
//  Created by HengtaoDai on 2016/12/10.
//  Copyright © 2016年 HengtaoDai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HTScrollLabelDirection)
{
    HTScrollLabelDirectionHorizontal = 1, //defaultValue
    HTScrollLabelDirectionVertical = 2
};

@interface HTScrollLabel : UIScrollView

@property (nonatomic, strong) NSArray   *arrLabelTexts;
@property (nonatomic, copy)   NSString  *placeholder;
@property (nonatomic, assign) CGFloat   fontSize;       //default 15px
@property (nonatomic, strong) UIColor   *textColor;     //default black
@property (nonatomic, assign) CGFloat   moveSpeed;      //default 1.0
@property (nonatomic, assign) NSTimeInterval   timeInterval;    //default 0.1
@property (nonatomic, assign) HTScrollLabelDirection direction; //default Horizontal


- (instancetype)initWithFrame:(CGRect)frame;

- (instancetype)initWithFrame:(CGRect)frame withTexts:(NSArray *)arrTexts;

- (void)run;

- (void)stop;

@end
