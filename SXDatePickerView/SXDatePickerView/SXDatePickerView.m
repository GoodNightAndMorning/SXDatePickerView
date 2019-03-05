//
//  SXDatePickerView.m
//  SXDatePickerView
//
//  Created by apple on 2019/3/5.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import "SXDatePickerView.h"

#define SX_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define SX_IS_IOS_11  ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.f)
#define SX_IS_IPHONE_X (SX_IS_IOS_11 && SX_IS_IPHONE && (MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 375 && MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) >= 812))

#define SX_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SX_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define TOOL_HEIGHT 50
#define PICKER_HEIGHT 220

@interface SXDatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@property(nonatomic,strong)UIView *contentView;

@property(nonatomic,strong)UIView *toolView;

@property(nonatomic,strong)UIPickerView *pickerView;

@property(nonatomic,strong)UILabel *titleLb;

@property(nonatomic,strong)UIButton *confirmBtn;

@property(nonatomic,strong)UIView *line;

@property(nonatomic,strong)NSMutableArray *yearArr;
@property(nonatomic,strong)NSMutableArray *monthArr;
@property(nonatomic,strong)NSMutableArray *dayArr;
@property(nonatomic,strong)NSMutableArray *hourArr;
@property(nonatomic,strong)NSMutableArray *minuteArr;

@property(nonatomic,strong)NSDate *selectDate;
@property(nonatomic,strong)NSMutableArray<NSNumber *> *currentPickerArr;
@property(nonatomic,strong)NSArray *timeDataArr;

@property(nonatomic,strong)NSCalendar *calendar;
@property(nonatomic,strong)NSDateComponents *minComponents;
@property(nonatomic,strong)NSDateComponents *maxComponents;
@property(nonatomic,strong)NSDateComponents *selComponents;

@end

@implementation SXDatePickerView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
        
        self.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(p_closeAction)];
        [self addGestureRecognizer:tap];
        
        self.frame = [UIScreen mainScreen].bounds;
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        [window addSubview:self];
        
        
        [self p_initData];
        
        [self p_initUi];
    }
    return self;
}


#pragma mark - 私有方法
-(void)p_confirmAction {
    if (self.selectDateBlock) {
        self.selectDateBlock(self.selectDate);
    }
    if (self.selectDateStrBlock) {
        self.selectDateStrBlock(self.titleLb.text);
    }
    
    [self hidden];
}
-(void)p_closeAction {
    [self hidden];
}
#pragma mark - 公有方法
-(void)hidden {
    [self removeFromSuperview];
}
#pragma mark - set方法
-(void)setMaxDate:(NSDate *)maxDate {
    _maxDate = maxDate;
    [self p_setData];
}
-(void)setMinDate:(NSDate *)minDate {
    _minDate = minDate;
    
    [self p_setData];
}
-(void)setCurrentDate:(NSDate *)currentDate {
    _currentDate = currentDate;
    self.selectDate = currentDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:currentDate];
    
    NSArray *arr = @[@(components.year),
                              @(components.month),
                              @(components.day),
                              @(components.hour),
                              @(components.minute)];
    [self.currentPickerArr removeAllObjects];
    [self.currentPickerArr addObjectsFromArray:arr];
    
    [self p_setData];
}

-(void)setUnitArr:(NSArray *)unitArr {
    NSAssert(unitArr.count == 5, @"The count of unitArr must is five!");
    _unitArr = unitArr;
    
    [self.pickerView reloadAllComponents];
}
-(void)setIntervalOfMinute:(int)intervalOfMinute {
    
    NSAssert(intervalOfMinute > 0 && intervalOfMinute < 60, @"intervalOfMinute must be greater than 0 and smaller than 60");
    
    _intervalOfMinute = intervalOfMinute;
    
    [self p_setData];
}

-(void)p_initData {
    
    NSDate *date = [NSDate new];
    
    self.timeDataArr = @[self.yearArr,self.monthArr,self.dayArr,self.hourArr,self.minuteArr];
    
    self.minDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    [components setValue:components.year + 100 forComponent:NSCalendarUnitYear];
    
    self.maxDate = [calendar dateFromComponents:components];
    
    self.currentDate = date;
    
    self.intervalOfMinute = 1;
    
    self.unitArr = @[@"",@"",@"",@"",@""];
    self.dateType = SXDateType_DateTime;
}
-(void)p_setData {
    
    if (self.minDate == nil || self.maxDate == nil || self.currentDate == nil || self.intervalOfMinute == 0) {
        return;
    }
    

    _minComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.minDate];
    _maxComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.maxDate];
    _selComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:self.selectDate];
    
    [self p_setYearData];
    [self p_setMonthData];
    [self p_setDayData];
    [self p_setHourData];
    [self p_setMinuteData];
    
    [self.pickerView reloadAllComponents];
    
    [self p_selectRowInComponent];
    
}
-(void)p_selectRowInComponent {
    for (int i = 0; i < self.currentPickerArr.count; i++) {
        for (int j = 0; j < [self.timeDataArr[i] count]; j++) {
            if (self.currentPickerArr[i].intValue == [self.timeDataArr[i][j] intValue]) {
                [self.pickerView selectRow:j inComponent:i animated:NO];
            }
        }
    }
}
-(void)p_setYearData {
    if (self.yearArr.count > 0) {
        return;
    }
    
    [self.yearArr removeAllObjects];
    
    int minYear = (int)_minComponents.year;
    int maxYear = (int)_maxComponents.year;
    for (int i = minYear; i <= maxYear; i++) {
        [self.yearArr addObject:@(i)];
    }
}
-(void)p_setMonthData {
    
    if (self.monthArr.count > 0 && (self.currentPickerArr[0].intValue != _minComponents.year || self.currentPickerArr[0].intValue != _minComponents.year)) {
        return;
    }
    [self.monthArr removeAllObjects];
    
    int minMonth = 0;
    int maxMonth = 11;
    
    int minYear = (int)_maxComponents.year;
    int maxYear = (int)_maxComponents.year;
    int currentYear = (int)_selComponents.year;

    if (currentYear == minYear) {
        minMonth = (int)_minComponents.month;
    }else if (currentYear == maxYear) {
        maxMonth = (int)_maxComponents.month;
    }
    
    for (int i = minMonth; i <= maxMonth; i++) {
        [self.monthArr addObject:@(i)];
    }
}
-(void)p_setDayData {
  
    
    [self.dayArr removeAllObjects];
    
    NSString *dateStr = [NSString stringWithFormat:@"%@-%@",self.currentPickerArr[0],@(self.currentPickerArr[1].intValue + 1)];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-M"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    NSInteger days = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
    for (int i = 1; i <= days; i++) {
        
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@-%d",_currentPickerArr[0],@(_currentPickerArr[1].intValue + 1),i];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyy-M-d"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
        NSDate *d = [dateFormatter dateFromString:dateStr];
//
//        NSDate *d = [NSDate dateWithTimeInterval:24*60*60*i sinceDate:zeroDayDate];
        
        if ([d laterDate:[NSDate dateWithTimeInterval:0 sinceDate:self.minDate]] && [d earlierDate:[NSDate dateWithTimeInterval:0 sinceDate:self.maxDate]]) {
            
            [self.dayArr addObject:@(i)];
        }
    }
}
-(void)p_setHourData {

    
    
    [self.hourArr removeAllObjects];
    
    [_selComponents setValue:self.currentPickerArr[0].intValue forComponent:NSCalendarUnitYear];
    [_selComponents setValue:self.currentPickerArr[1].intValue forComponent:NSCalendarUnitMonth];
    [_selComponents setValue:self.currentPickerArr[2].intValue forComponent:NSCalendarUnitDay];
    
    for (int i = 0; i < 24; i++) {
        [_selComponents setValue:i forComponent:NSCalendarUnitHour];
        NSDate *d = [self.calendar dateFromComponents:_selComponents];
        if ([d laterDate:[NSDate dateWithTimeInterval:-60*60 sinceDate:self.minDate]] && [d earlierDate:[NSDate dateWithTimeInterval:60*60 sinceDate:self.maxDate]]) {
            [self.hourArr addObject:@(i)];
        }
    }
}
-(void)p_setMinuteData {

    [self.minuteArr removeAllObjects];
    
    [_selComponents setValue:self.currentPickerArr[0].intValue forComponent:NSCalendarUnitYear];
    [_selComponents setValue:self.currentPickerArr[1].intValue forComponent:NSCalendarUnitMonth];
    [_selComponents setValue:self.currentPickerArr[2].intValue forComponent:NSCalendarUnitDay];
    [_selComponents setValue:self.currentPickerArr[3].intValue forComponent:NSCalendarUnitHour];
    
    for (int i = 0; i < 60; i = i + self.intervalOfMinute) {
        [_selComponents setValue:i forComponent:NSCalendarUnitMinute];
        NSDate *d = [self.calendar dateFromComponents:_selComponents];
        if ([d laterDate:[NSDate dateWithTimeInterval:0 sinceDate:self.minDate]] && [d earlierDate:[NSDate dateWithTimeInterval:0 sinceDate:self.maxDate]]) {
            [self.minuteArr addObject:@(i)];
        }
    }
}

#pragma mark - <UIPickerViewDelegate,UIPickerViewDataSource>

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return self.timeDataArr.count;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.timeDataArr[component] count];
}

-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    if (self.dateType == SXDateType_DateTime) {
        return SX_SCREEN_WIDTH / 5;
    }else if (self.dateType == SXDateType_Date) {
        if (component <= 2) {
            return SX_SCREEN_WIDTH / 3;
        }else{
            return 0;
        }
    }else {
        if (component > 2) {
            return SX_SCREEN_WIDTH / 3;
        }else{
            return 0;
        }
    }
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 44;
}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UIView *cellView = view;
    if (!cellView) {
        cellView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [self.pickerView rowSizeForComponent:component].width, [self.pickerView rowSizeForComponent:component].height)];
    }
    
    UILabel *lb = [[UILabel alloc] initWithFrame:cellView.bounds];
    lb.font = [UIFont systemFontOfSize:16];
    
    NSString *str = [NSString stringWithFormat:@"%@",self.timeDataArr[component][row]];
    
    if (component == 1) {
        str = [NSString stringWithFormat:@"%d",str.intValue+1];
    }
    
    if (component != 0) {
        if (str.length == 1) {
            str = [NSString stringWithFormat:@"0%@",str];
        }
    }
    
    str = [NSString stringWithFormat:@"%@%@",str,self.unitArr[component]];
    
    lb.text = str;
    lb.textAlignment = NSTextAlignmentCenter;
    
    [cellView addSubview:lb];
    
    return cellView;
}
//-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
//
//
//
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
//    return attrStr;
//}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.currentPickerArr[component] = self.timeDataArr[component][row];
    if (component == 0 || component == 1) {
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@",self.currentPickerArr[0],@(self.currentPickerArr[1].intValue + 1)];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-M"];
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
        NSDate *date = [dateFormatter dateFromString:dateStr];
        
        NSInteger days = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
        
        if (self.currentPickerArr[2].intValue > days) {
            self.currentPickerArr[2] = @(days);
        }
    }
    
    
    NSString *formatter = @"";
    NSString *dateStr = @"";
    if (self.dateType == SXDateType_DateTime) {
        formatter = @"yyyy-MM-dd HH:mm";
        dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",self.currentPickerArr[0],@(self.currentPickerArr[1].intValue + 1),self.currentPickerArr[2],self.currentPickerArr[3],self.currentPickerArr[4]];
    }else if (self.dateType == SXDateType_Date) {
        formatter = @"yyyy-MM-dd";
        dateStr = [NSString stringWithFormat:@"%@-%@-%@",self.currentPickerArr[0],@(self.currentPickerArr[1].intValue + 1),self.currentPickerArr[2]];
    }else {
        formatter = @"yyyy-MM-dd HH:mm";
        dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",self.currentPickerArr[0],@(self.currentPickerArr[1].intValue + 1),self.currentPickerArr[2],self.currentPickerArr[3],self.currentPickerArr[4]];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];//解决8小时时间差问题
    self.selectDate = [dateFormatter dateFromString:dateStr];
    
    [self p_setData];
    
    NSMutableArray *dStrs = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.currentPickerArr.count; i++) {
        NSString *str = [NSString stringWithFormat:@"%@",self.currentPickerArr[i]];
        if (i == 1) {
            str = [NSString stringWithFormat:@"%d",str.intValue + 1];
        }
        if (str.length == 1) {
            str = [NSString stringWithFormat:@"0%@",str];
        }
        [dStrs addObject:str];
    }
    self.titleLb.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",dStrs[0],dStrs[1],dStrs[2],dStrs[3],dStrs[4]];
}
#pragma mark - UI
-(void)p_initUi {
    [self addSubview:self.contentView];
    
    [self.contentView addSubview:self.toolView];
    [self.toolView addSubview:self.titleLb];
    [self.toolView addSubview:self.confirmBtn];
    [self.toolView addSubview:self.line];
    
    [self.contentView addSubview:self.pickerView];
}
-(UIView *)contentView {
    if (!_contentView) {
        CGFloat bottomH = 0;
        if (SX_IS_IPHONE_X) {
            bottomH = 35;
        }
        
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SX_SCREEN_HEIGHT - (TOOL_HEIGHT + bottomH + PICKER_HEIGHT), SX_SCREEN_WIDTH, TOOL_HEIGHT + bottomH + PICKER_HEIGHT)];
        _contentView.backgroundColor = UIColor.whiteColor;
        if (SX_IS_IPHONE_X) {
            
        }
    }
    return _contentView;
}
-(UIView *)toolView {
    if (!_toolView) {
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SX_SCREEN_WIDTH, TOOL_HEIGHT)];
    }
    return _toolView;
}
-(UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, TOOL_HEIGHT, SX_SCREEN_WIDTH, PICKER_HEIGHT)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}
-(UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SX_SCREEN_WIDTH, TOOL_HEIGHT)];
        _titleLb.font = [UIFont systemFontOfSize:16];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.text = @"选择时间";
    }
    return _titleLb;
}
-(UIButton *)confirmBtn {
    if (!_confirmBtn) {
        _confirmBtn = [UIButton buttonWithType:UIButtonTypeSystem];
        [_confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        _confirmBtn.titleLabel.font = [UIFont systemFontOfSize:16];
        [_confirmBtn setTitleColor:UIColor.orangeColor forState:UIControlStateNormal];
        _confirmBtn.frame = CGRectMake(SX_SCREEN_WIDTH - 65, 0, 65, 44);
        [_confirmBtn addTarget:self action:@selector(p_confirmAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmBtn;
}
-(UIView *)line {
    if (!_line) {
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, TOOL_HEIGHT - 1, SX_SCREEN_WIDTH, 1)];
        _line.backgroundColor = UIColor.groupTableViewBackgroundColor;
    }
    return _line;
}
-(NSMutableArray *)yearArr {
    if (!_yearArr) {
        _yearArr = [[NSMutableArray alloc] init];
    }
    return _yearArr;
}
-(NSMutableArray *)monthArr {
    if (!_monthArr) {
        _monthArr = [[NSMutableArray alloc] init];
    }
    return _monthArr;
}
-(NSMutableArray *)dayArr {
    if (!_dayArr) {
        _dayArr = [[NSMutableArray alloc] init];
    }
    return _dayArr;
}
-(NSMutableArray<NSNumber *> *)currentPickerArr{
    if (!_currentPickerArr) {
        _currentPickerArr = [[NSMutableArray<NSNumber *> alloc] init];
    }
    return _currentPickerArr;
}
-(NSMutableArray *)hourArr {
    if (!_hourArr) {
        _hourArr = [[NSMutableArray alloc] init];
    }
    return _hourArr;
}
-(NSMutableArray *)minuteArr {
    if (!_minuteArr) {
        _minuteArr = [[NSMutableArray alloc] init];
    }
    return _minuteArr;
}
-(NSCalendar *)calendar {
    if (!_calendar) {
        _calendar = [NSCalendar currentCalendar];
    }
    return _calendar;
}
@end
