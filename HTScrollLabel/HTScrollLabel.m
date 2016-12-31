//
//  HTScrollLabel.m
//  HTScrollLabel
//
//  Created by HengtaoDai on 2016/12/10.
//  Copyright © 2016年 HengtaoDai. All rights reserved.
//

#import "HTScrollLabel.h"

static const float kTimeInterval = 0.1;
static const float kMoveSpeed = 1;

@implementation HTScrollLabel
{
    NSMutableArray  *_reusableLabels;   //labels的复用池
    NSMutableArray  *_visibleLabels;    //可见labels
    NSInteger       _indexOfLabel;      //标识最优先复用的text
    CGFloat         _widthOfLabel;      //label的宽度
    CGFloat         _heightOfLabel;     //label单行的高度
    NSTimer         *_timer;            //定时器
}


- (instancetype)initWithFrame:(CGRect)frame
{
    return [self initWithFrame:frame withTexts:nil];
}


- (instancetype)initWithFrame:(CGRect)frame withTexts:(NSArray *)arrTexts
{
    if (self = [super initWithFrame:frame])
    {
        NSAssert([self checkClassOfElementInArray:arrTexts], @"All the element of array must be string");
        
        _placeholder = @"测试文本 testText";
        _fontSize = 15;
        _textColor = [UIColor blackColor];
        _direction = HTScrollLabelDirectionHorizontal;
        _arrLabelTexts = @[];
        _reusableLabels = [NSMutableArray array];
        _visibleLabels = [NSMutableArray array];
        _indexOfLabel = 0;
        _moveSpeed = kMoveSpeed;
        _timeInterval = kTimeInterval;
        
        
        if (arrTexts && arrTexts.count) _arrLabelTexts = arrTexts;
    }
    
    return self;
}


#pragma mark - setter方法
- (void)setArrLabelTexts:(NSArray *)arrLabelTexts
{
    NSAssert([self checkClassOfElementInArray:arrLabelTexts], @"the array is invalid");
    
    _arrLabelTexts = arrLabelTexts;
}


- (void)setDirection:(HTScrollLabelDirection)direction
{
    if (direction != HTScrollLabelDirectionVertical)  _direction = HTScrollLabelDirectionHorizontal;
    else _direction = HTScrollLabelDirectionVertical;
}


- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = placeholder.length? placeholder: @"测试文本 testText";
    if (!_arrLabelTexts.count) _arrLabelTexts = @[_placeholder];
}


- (void)setFontSize:(CGFloat)fontSize
{
    _fontSize = fontSize < 10? 10: fontSize;
}


- (void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
}


- (void)setMoveSpeed:(CGFloat)moveSpeed
{
    if (moveSpeed < 0) _moveSpeed = kMoveSpeed;
    else _moveSpeed = moveSpeed;
}


- (void)setTimeInterval:(NSTimeInterval)timeInterval
{
    if (timeInterval < 0) _timeInterval = kTimeInterval;
    else _timeInterval = timeInterval;
}


#pragma mark - load Data and View

- (void)loadData
{
    if (!_arrLabelTexts.count) _arrLabelTexts = @[_placeholder];
    
    if (_direction == HTScrollLabelDirectionHorizontal)
    {
        NSInteger iCountOfLabels = 1;
        _indexOfLabel = iCountOfLabels;

        _heightOfLabel = self.frame.size.height;
        _widthOfLabel = [self widthForText:_arrLabelTexts[0] fontSize:_fontSize textHeight:_heightOfLabel];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _widthOfLabel, _heightOfLabel)];
        lbl.textColor = _textColor;
        lbl.font = [UIFont systemFontOfSize:_fontSize];
        [_visibleLabels addObject:lbl];
        
        
    }
    else if (_direction == HTScrollLabelDirectionVertical)
    {
        _widthOfLabel = self.frame.size.width-10;
        _heightOfLabel = [self heightForText:@"测试" fontSize:_fontSize textWidth:_widthOfLabel];
        
        /*计算所需label的个数
         如果: _arrLabelTexts.count *_heightOfLabel < frame.height ，则label的个数 = _arrLabelTexts.count+1；
         否则：label的个数 = frame.height/_heightOfLabel +2；
         */
        NSInteger iCountOfLabels = 0;
        if (_arrLabelTexts.count *_heightOfLabel < self.frame.size.height) iCountOfLabels = _arrLabelTexts.count;
        else iCountOfLabels = (NSInteger)(self.frame.size.height/_heightOfLabel)+2;
        
        _indexOfLabel = iCountOfLabels;
        
        for (NSInteger i = 0; i < iCountOfLabels; i++)
        {
            UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _widthOfLabel, _heightOfLabel)];
            lbl.textColor = _textColor;
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.font = [UIFont systemFontOfSize:_fontSize];
            [_visibleLabels addObject:lbl];
        }
    }
}


- (void)loadView
{
    if (_direction == HTScrollLabelDirectionHorizontal)
    {
        UILabel *label = _visibleLabels[0];
        label.text = _arrLabelTexts[0];
        CGFloat widthOfLbl = [self widthForText:label.text fontSize:_fontSize textHeight:_heightOfLabel];
        label.frame = CGRectMake(self.frame.size.width, 0, widthOfLbl, _heightOfLabel);
        
        [self addSubview:label];
    }
    else if (_direction == HTScrollLabelDirectionVertical)
    {
        for (NSInteger i = 0; i < _visibleLabels.count; i++)
        {
            UILabel *label = _visibleLabels[i];
            label.frame = CGRectMake(5, i*_heightOfLabel, _widthOfLabel, _heightOfLabel);
            label.text = _arrLabelTexts[i];
            
            [self addSubview:label];
        }
    }
}


- (void)run
{
    if (!_visibleLabels.count)
    {
        [self loadData];
        [self loadView];
    }
    
    if (!_timer)
    {
        _timer = [NSTimer scheduledTimerWithTimeInterval:_timeInterval
                                                  target:self
                                                selector:@selector(refreshTime)
                                                userInfo:nil
                                                 repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}


- (void)stop
{
    [_timer invalidate];
    _timer = nil;
}


- (void)refreshTime
{
    //-------------------------- 移动 label的位置 moving Label----------------------------
    NSMutableArray *marrDel = [NSMutableArray array];

    for (NSInteger i = 0; i < _visibleLabels.count; i++)
    {
        UILabel *label = _visibleLabels[i];
        CGRect frame = label.frame;
        
        if (_direction == HTScrollLabelDirectionVertical)
        {
            frame.origin.y -= _moveSpeed;
            label.frame = frame;
            
            CGFloat bottom = label.frame.origin.y +_heightOfLabel;
            if (bottom < 0)
            {
                [_reusableLabels addObject:label];
                [marrDel addObject:label];
                [label removeFromSuperview];
                
            }
        }
        else if (_direction == HTScrollLabelDirectionHorizontal)
        {
            frame.origin.x -= _moveSpeed;
            label.frame = frame;
            
            CGFloat right = label.frame.origin.x + label.frame.size.width;
            if (right < 0)
            {
                [_reusableLabels addObject:label];
                [marrDel addObject:label];
                [label removeFromSuperview];
            }
        }
        
    }
    
    [_visibleLabels removeObjectsInArray:marrDel];
    
    //--------------------- 需要重新启用的label的个数 Num of reuse Label-----------------------
    NSInteger iNeedNumOfLabel = 0;
    UILabel *labelLast = [_visibleLabels lastObject];
    
    if (_direction == HTScrollLabelDirectionVertical)
    {
        CGFloat bottom = labelLast.frame.origin.y +_heightOfLabel;
        if (bottom < self.frame.size.height && _reusableLabels.count > 0)
        {
            iNeedNumOfLabel = (NSInteger)(self.frame.size.height - bottom)/_heightOfLabel + 1;
            iNeedNumOfLabel = iNeedNumOfLabel >_reusableLabels.count? _reusableLabels.count: iNeedNumOfLabel;
        }
    }
    else if (_direction == HTScrollLabelDirectionHorizontal)
    {
        CGFloat rightOfLastLbl = labelLast.frame.origin.x +labelLast.frame.size.width;
        if (rightOfLastLbl < self.frame.size.width)
        {
            iNeedNumOfLabel ++;
            CGFloat widthOfInterval = self.frame.size.width - rightOfLastLbl;   //label和右边界之间的空隙宽度
            _indexOfLabel = _indexOfLabel%_arrLabelTexts.count;
            
            for (NSInteger i = _indexOfLabel; ; i++)
            {
                CGFloat widthOfLbl = [self widthForText:_arrLabelTexts[i] fontSize:_fontSize textHeight:_heightOfLabel];
                if (widthOfLbl <= widthOfInterval)
                {
                    iNeedNumOfLabel ++;
                    widthOfInterval -= widthOfLbl;
                }
                else
                {
                    break;
                }
            }
        }
        
    }
    
    //------------------------ 复用 reuse label----------------------------
    
    CGFloat left = 0;
    for (NSInteger i = 0; i < iNeedNumOfLabel; i++)
    {
        UILabel *lblNew = [self dequeueReusableLabel];
        [_visibleLabels addObject:lblNew];
        
        _indexOfLabel = _indexOfLabel%_arrLabelTexts.count;
        lblNew.text = _arrLabelTexts[_indexOfLabel++];
        
        if (_direction == HTScrollLabelDirectionVertical)
        {
            lblNew.frame = CGRectMake(5, self.frame.size.height+i*_heightOfLabel, _widthOfLabel, _heightOfLabel);
        }
        else if (_direction == HTScrollLabelDirectionHorizontal)
        {
            CGFloat widthOfLabel = [self widthForText:lblNew.text fontSize:_fontSize textHeight:_heightOfLabel];
            lblNew.frame = CGRectMake(self.frame.size.width+left, 0, widthOfLabel, _heightOfLabel);
            left += widthOfLabel;
        }
        
        [self addSubview:lblNew];
    }
    
}


#pragma mark - reuse Label
- (UILabel *)dequeueReusableLabel
{
    UILabel *label = [_reusableLabels firstObject];
    [_reusableLabels removeObject:label];
    
    if (label)
    {
        label.text = @"";
    }
    else if (_direction == HTScrollLabelDirectionHorizontal)
    {
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, _heightOfLabel)];
        label.textColor = _textColor;
        label.font = [UIFont systemFontOfSize:_fontSize];
    }
    
    return label;
}


#pragma mark - private Method
- (BOOL)checkClassOfElementInArray:(NSArray *)array
{
    for (NSInteger i = 0; i < array.count; i++)
    {
        //如果数组中的元素不全是字符串，返回NO；
        if (![array[i] isKindOfClass:[NSString class]])
        {
            return NO;
        }
    }
    
    return YES;
}


- (float)heightForText:(NSString *)text fontSize:(float)fontSize textWidth:(float)textWidth
{
    CGSize constraint = CGSizeMake(textWidth, MAXFLOAT);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGRect rect = [attributedText boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size.height;
}


- (float)widthForText:(NSString *)text fontSize:(float)fontSize textHeight:(float)textHeight
{
    CGSize constraint = CGSizeMake(MAXFLOAT, textHeight);
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIFont systemFontOfSize:fontSize] forKey:NSFontAttributeName];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    CGRect rect = [attributedText boundingRectWithSize:constraint
                                               options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    return size.width+50;
}

@end
