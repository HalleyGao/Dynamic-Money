//
//  FSBezierLabel.m
//  CallPlaneFS
//
//  Created by Rafferty on 15/11/9.
//  Copyright © 2015年 PowerVision. All rights reserved.
//

#import "FSBezierLabel.h"
#import "Bezier.h"

#define KMaxTimes 50

@interface FSBezierLabel()
{
    NSMutableArray *totlePoints; //记录所有的点
    Bezier *bezier;  //通过bezier函数的参数变化改变动画的样式
    float _duration; //动画间隔
    float _fromNum;  //开始数值
    float _toNum;  //结束数值
    float _lastTime;
    int _index;

}
@end
@implementation FSBezierLabel

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        //初始化贝塞尔曲线
        [self initBezier];
        
        [self cleanVars];
        
    }
    return self;
}

- (void)initBezier{
    bezier = [[Bezier alloc] init];
}

- (void)cleanVars{
    _lastTime = 0;
    _index = 0;
    self.text = @"0";
}


- (void)animationFromNum:(float)fromNum toNum:(float)toNum duration:(float)duration{
    [self cleanVars];
    
    _duration = duration;
    _fromNum = fromNum;
    _toNum = toNum;
    
    totlePoints = [NSMutableArray array];
    float dt = 1.0 / (KMaxTimes - 1);
    
    for (NSInteger i = 0; i < KMaxTimes; i ++ ) {
        
        BezierPoint point = [bezier pointWithDt:dt * i];
        
        float currTime = point.x * _duration;
        float currValue = point.y * (_toNum - _fromNum) + _fromNum;
        NSArray *array = [NSArray arrayWithObjects:[NSNumber numberWithFloat:currTime] , [NSNumber numberWithFloat:currValue], nil];
        
        [totlePoints addObject:array];
    }
    [self changeNumberBySelector];
}

- (void)changeNumberBySelector{
    if (_index >= KMaxTimes) {
        self.text = [NSString stringWithFormat:@"%.2f",_toNum];
        return;
    } else {
        NSArray *pointValues = [totlePoints objectAtIndex:_index];
        _index++;
        float value = [(NSNumber *)[pointValues objectAtIndex:1] floatValue];
        
        float currentTime = [(NSNumber *)[pointValues objectAtIndex:0] floatValue];
        float timeDuration = currentTime - _lastTime;
        _lastTime = currentTime;
        self.text = [NSString stringWithFormat:@"%.2f",value];
        
       
        //和列表一块用时，当滚动时阻塞主线程，次方法不执行，
       // [self performSelector:@selector(changeNumberBySelector) withObject:nil afterDelay:timeDuration];
        
        //所以改成用GCD的方式
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, timeDuration * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            [self changeNumberBySelector];
        });

    }
}


@end
