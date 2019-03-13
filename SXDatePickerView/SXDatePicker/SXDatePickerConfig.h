//
//  SXDatePickerConfig.h
//  SXDatePickerView
//
//  Created by apple on 2019/3/13.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SXDateType) {
    SXDateType_DateTime = 0,
    SXDateType_Date = 1,
    SXDateType_Time = 2,
};

@interface SXDatePickerConfig : NSObject

@property(nonatomic,strong)NSDate *minDate;
@property(nonatomic,strong)NSDate *maxDate;
@property(nonatomic,strong)NSDate *currentDate;
@property(nonatomic,strong)NSArray *unitArr;
@property(nonatomic,assign)SXDateType dateType;
@property(nonatomic,assign)int intervalOfMinute;
@property(nonatomic,assign)NSRange hourRange;

@end

