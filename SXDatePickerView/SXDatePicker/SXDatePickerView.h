//
//  SXDatePickerView.h
//  SXDatePickerView
//
//  Created by apple on 2019/3/5.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SXDatePickerConfig;
@interface SXDatePickerView : UIView

@property(nonatomic,strong)SXDatePickerConfig *config;

@property(nonatomic,copy)void(^selectDateBlock)(NSDate *date);
@property(nonatomic,copy)void(^selectDateStrBlock)(NSString *dateStr);
-(void)hidden;

-(instancetype)initWithConfig:(SXDatePickerConfig *)config;
@end

