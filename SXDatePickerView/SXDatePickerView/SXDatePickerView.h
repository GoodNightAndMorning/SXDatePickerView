//
//  SXDatePickerView.h
//  SXDatePickerView
//
//  Created by apple on 2019/3/5.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, SXDateType) {
    SXDateType_DateTime = 0,
    SXDateType_Date = 1,
    SXDateType_Time = 2,
};
@interface SXDatePickerView : UIView
@property(nonatomic,assign)int showRows;
@property(nonatomic,strong)NSDate *minDate;
@property(nonatomic,strong)NSDate *maxDate;
@property(nonatomic,strong)NSDate *currentDate;
@property(nonatomic,strong)NSArray *unitArr;
@property(nonatomic,assign)SXDateType dateType;
//-(void)setDateItem:(SXDateItem)item;
-(void)hidden;
@end

