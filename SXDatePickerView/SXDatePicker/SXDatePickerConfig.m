//
//  SXDatePickerConfig.m
//  SXDatePickerView
//
//  Created by apple on 2019/3/13.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import "SXDatePickerConfig.h"

@interface SXDatePickerConfig()
@property(nonatomic,strong)NSCalendar *calendar;
@end

@implementation SXDatePickerConfig
-(instancetype)init {
    self = [super init];
    if (self) {
        _minDate = [NSDate dateWithTimeIntervalSince1970:0];
        
        NSDateComponents *components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate new]];
        [components setValue:components.year + 100 forComponent:NSCalendarUnitYear];
        _maxDate = [self.calendar dateFromComponents:components];
        
        _currentDate = [NSDate new];
        
        _unitArr = @[@"年",@"月",@"日",@"时",@"分"];
        
        _intervalOfMinute = 1;
        
        _hourRange = NSMakeRange(0, 23);
        
        _dateType = SXDateType_DateTime;
        
        [self initData];
    }
    return self;
}

-(void)setMaxDate:(NSDate *)maxDate {
    NSAssert([maxDate compare:_minDate] == kCFCompareGreaterThan, @"The maxDate must be greater than minDate!");
    _maxDate = maxDate;
    
    [self initData];
}
-(void)setMinDate:(NSDate *)minDate {
    NSAssert([minDate compare:_maxDate] == kCFCompareLessThan, @"The minDate must be less than maxDate!");
    _minDate = minDate;
    
    [self initData];
}
-(void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    
    [self initData];
}

-(void)setUnitArr:(NSArray *)unitArr {
    NSAssert(unitArr.count == 5, @"The count of unitArr must is five!");
    _unitArr = unitArr;

}
-(void)setIntervalOfMinute:(int)intervalOfMinute {
    
    NSAssert(intervalOfMinute > 0 && intervalOfMinute < 60, @"intervalOfMinute must be greater than 0 and smaller than 60");
    
    _intervalOfMinute = intervalOfMinute;

}
-(void)setHourRange:(NSRange)hourRange {
    NSAssert(hourRange.location >= 0 && hourRange.location <= 23 && (hourRange.location + hourRange.length) <= 23, @"hourRange is wrong");
    _hourRange = hourRange;
}


-(void)initData {
    //_minDate时间格式化
    {
        NSDateComponents * minComp = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_minDate];
        
        NSInteger minute = minComp.minute;
        
        if (minute % _intervalOfMinute != 0) {
            minute = _intervalOfMinute - minute % _intervalOfMinute + minute;
        }
        
        [minComp setMinute:minute];
        
        _minDate = [self.calendar dateFromComponents:minComp];
    }
    //_maxDate时间格式化
    {
        NSDateComponents * maxComp = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_maxDate];
        
        NSInteger minute = maxComp.minute;
        
        minute = minute - minute % _intervalOfMinute;
        
        [maxComp setMinute:minute];
        
        _maxDate = [self.calendar dateFromComponents:maxComp];
    }
    //_currentDate时间格式化
    {
        NSDateComponents * currentComp = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_currentDate];
        
        NSInteger minute = currentComp.minute;
        
        minute = _intervalOfMinute - minute % _intervalOfMinute + minute;
        
        [currentComp setMinute:minute];
        
        _currentDate = [self.calendar dateFromComponents:currentComp];
        
        if ([_currentDate compare:_minDate] == kCFCompareLessThan) {
            _currentDate = _minDate;
        }
        if ([_currentDate compare:_maxDate] == kCFCompareGreaterThan) {
            _currentDate = _maxDate;
        }
    }
}

-(NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
        
    }
    return _calendar;
}
@end
