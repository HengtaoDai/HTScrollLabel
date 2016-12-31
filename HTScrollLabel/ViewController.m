//
//  ViewController.m
//  HTScrollLabel
//
//  Created by HengtaoDai on 2016/12/10.
//  Copyright © 2016年 HengtaoDai. All rights reserved.
//

#import "ViewController.h"
#import "HTScrollLabel.h"

#define RGBColor(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"";
    self.view.backgroundColor = [UIColor whiteColor];

    [self initView];
}


- (void)initView
{
    NSArray *arrText = @[@"The year's at the spring,",
                         @"And day's at the morn;",
                         @"Morning's at seven;",
                         @"The hillside's dew-pearled;",
                         @"the lark's on the wing;",
                         @"The snail's on the thorn;",
                         @"God's in his heaven",
                         @"All's right with the world!",
                         @"一年之计在于春，",
                         @"一日之计在于晨",
                         @"一晨之计在于七时；",
                         @"山坡上装点着珍珠般的露水珠露；",
                         @"云雀在风中飞跃；",
                         @"山垆上蜗牛爬行",
                         @"神在天堂司宇宙",
                         @"世上一切都太平！"
                         ];
    
    HTScrollLabel *scrollLabel = [[HTScrollLabel alloc] initWithFrame:CGRectMake(0, 0, 260, 20) withTexts:arrText];
    scrollLabel.center = CGPointMake(self.view.center.x, 80);
    scrollLabel.direction = HTScrollLabelDirectionHorizontal;
    scrollLabel.backgroundColor = RGBColor(240, 240, 240);
    [self.view addSubview:scrollLabel];
    scrollLabel.moveSpeed = 1;
    scrollLabel.timeInterval = 0.01;
    [scrollLabel run];
    
    HTScrollLabel *scrollLabel2 = [[HTScrollLabel alloc] initWithFrame:CGRectMake(0, 0, 260, 300) withTexts:arrText];
    scrollLabel2.center = CGPointMake(self.view.center.x, 300);
    scrollLabel2.direction = HTScrollLabelDirectionVertical;
    scrollLabel2.backgroundColor = RGBColor(240, 240, 240);
    [self.view addSubview:scrollLabel2];
    scrollLabel2.moveSpeed = 1;
    scrollLabel2.timeInterval = 0.05;
    [scrollLabel2 run];
}





@end
