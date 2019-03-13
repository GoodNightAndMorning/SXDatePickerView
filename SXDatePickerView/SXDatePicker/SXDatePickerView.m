//
//  SXDatePickerView.m
//  SXDatePickerView
//
//  Created by apple on 2019/3/5.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import "SXDatePickerView.h"
#import "SXDatePickerConfig.h"
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
-(instancetype)initWithConfig:(SXDatePickerConfig *)config {
    self.config = config;
    return [self init];
}
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

-(void)p_confirmAction {
    if (self.selectDateBlock) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyy-MM-dd HH:mm"];
        
        NSDate *date = [formatter dateFromString:self.titleLb.text];
        
        self.selectDateBlock(date);
    }
    if (self.selectDateStrBlock) {
        self.selectDateStrBlock(self.titleLb.text);
    }
    
    [self hidden];
}
-(void)p_closeAction {
    [self hidden];
}

-(void)hidden {
    [self removeFromSuperview];
}

-(void)p_initData {
    
    _timeDataArr = @[self.yearArr,self.monthArr,self.dayArr,self.hourArr,self.minuteArr];
    
    
    _selectDate = _config.currentDate;
    
    NSDateComponents * components = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_config.currentDate];
    
    NSArray *arr = @[@(components.year),
                     @(components.month),
                     @(components.day),
                     @(components.hour),
                     @(components.minute)];
    [self.currentPickerArr removeAllObjects];
    [self.currentPickerArr addObjectsFromArray:arr];
    
    [self p_setData];
}
-(void)p_setData {

    
    _minComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_config.minDate];
    _maxComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_config.maxDate];
    _selComponents = [self.calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:_selectDate];
    
    [self p_setYearData];
    [self p_setMonthData];
    [self p_setDayData];
    [self p_setHourData];
    [self p_setMinuteData];
    
    [self.pickerView reloadAllComponents];
    
    [self p_selectRowInComponent];
    
    
    
    NSMutableArray *dStrs = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.currentPickerArr.count; i++) {
        NSString *str = [NSString stringWithFormat:@"%@",self.currentPickerArr[i]];
        if (str.length == 1) {
            str = [NSString stringWithFormat:@"0%@",str];
        }
        [dStrs addObject:str];
    }
    self.titleLb.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",dStrs[0],dStrs[1],dStrs[2],dStrs[3],dStrs[4]];
    
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
    
    if (_yearArr.count > 0) {
        return;
    }
    
    int minYear = (int)_minComponents.year;
    int maxYear = (int)_maxComponents.year;
    for (int i = minYear; i <= maxYear; i++) {
        [self.yearArr addObject:@(i)];
    }
}
-(void)p_setMonthData {

    [self.monthArr removeAllObjects];
    
    int minMonth = 1;
    int maxMonth = 12;
    
    int minYear = (int)_minComponents.year;
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
    
    NSInteger year = self.currentPickerArr[0].integerValue;
    NSInteger month = self.currentPickerArr[1].integerValue;
    
    if (year == _minComponents.year && month < _minComponents.month) {
        month = _minComponents.month;
        self.currentPickerArr[1] = @(month);
    }
    
    NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld",(long)year,(long)month];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-M"];

    NSDate *date = [dateFormatter dateFromString:dateStr];
    
    NSInteger days = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
    for (int i = 1; i <= days; i++) {
        
        NSString *dateStr = [NSString stringWithFormat:@"%ld-%ld-%d",(long)year,(long)month,i];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyy-M-d"];

        NSDate *d = [dateFormatter dateFromString:dateStr];

        
        if ( [d compare:[NSDate dateWithTimeInterval:-60*60*24 sinceDate:_config.minDate]] == kCFCompareGreaterThan && [d compare:_config.maxDate] == kCFCompareLessThan) {
            
            [self.dayArr addObject:@(i)];
        }
    }
}
-(void)p_setHourData {

    
    [self.hourArr removeAllObjects];
    
    NSInteger year = self.currentPickerArr[0].integerValue;
    NSInteger month = self.currentPickerArr[1].integerValue;
    NSInteger day = self.currentPickerArr[2].integerValue;
    
    if (year == _minComponents.year && month == _minComponents.month && day < _minComponents.day) {
        day = _minComponents.day;
        self.currentPickerArr[2] = @(day);
    }
    
    [_selComponents setYear:year];
    [_selComponents setMonth:month];
    [_selComponents setDay:day];
    
    for (int i = 0; i < 24; i++) {
        [_selComponents setHour:i];
        NSDate *d = [self.calendar dateFromComponents:_selComponents];
        if ([d compare:[NSDate dateWithTimeInterval:-(59 - 59 % _config.intervalOfMinute) * 60 sinceDate:_config.minDate]] == kCFCompareGreaterThan && [d compare:_config.maxDate] == kCFCompareLessThan) {

            if (i >= _config.hourRange.location && i <= _config.hourRange.location + _config.hourRange.length) {
                [self.hourArr addObject:@(i)];
            }
        }
    }
}
-(void)p_setMinuteData {

    [self.minuteArr removeAllObjects];
    
    NSInteger year = self.currentPickerArr[0].integerValue;
    NSInteger month = self.currentPickerArr[1].integerValue;
    NSInteger day = self.currentPickerArr[2].integerValue;
    NSInteger hour = self.currentPickerArr[3].integerValue;
    
    if (year == _minComponents.year && month == _minComponents.month && day == _minComponents.day && hour < _minComponents.hour) {
        hour = _minComponents.hour;
        self.currentPickerArr[3] = @(hour);
    }
    
    [_selComponents setYear:year];
    [_selComponents setMonth:month];
    [_selComponents setDay:day];
    [_selComponents setHour:hour];
    
    for (int i = 0; i < 60; i = i + _config.intervalOfMinute) {
        [_selComponents setValue:i forComponent:NSCalendarUnitMinute];
        NSDate *d = [self.calendar dateFromComponents:_selComponents];
        if ([d compare:[NSDate dateWithTimeInterval:-60 sinceDate:_config.minDate]] == kCFCompareGreaterThan && [d compare:_config.maxDate] == kCFCompareLessThan) {
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
    if (_config.dateType == SXDateType_DateTime) {
        return SX_SCREEN_WIDTH / 5;
    }else if (_config.dateType == SXDateType_Date) {
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
    
    if (component != 0) {
        if (str.length == 1) {
            str = [NSString stringWithFormat:@"0%@",str];
        }
    }
    
    str = [NSString stringWithFormat:@"%@%@",str,_config.unitArr[component]];
    
    lb.text = str;
    lb.textAlignment = NSTextAlignmentCenter;
    
    [cellView addSubview:lb];
    
    return cellView;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    self.currentPickerArr[component] = self.timeDataArr[component][row];
    if (component == 0 || component == 1) {
        NSString *dateStr = [NSString stringWithFormat:@"%@-%@",self.currentPickerArr[0],self.currentPickerArr[1]];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-M"];

        NSDate *date = [dateFormatter dateFromString:dateStr];
        
        NSInteger days = [self.calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
        
        if (self.currentPickerArr[2].intValue > days) {
            self.currentPickerArr[2] = @(days);
        }
    }
    
    
    NSString *formatter = @"";
    NSString *dateStr = @"";
    if (_config.dateType == SXDateType_DateTime) {
        formatter = @"yyyy-MM-dd HH:mm";
        dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",self.currentPickerArr[0],self.currentPickerArr[1],self.currentPickerArr[2],self.currentPickerArr[3],self.currentPickerArr[4]];
    }else if (_config.dateType == SXDateType_Date) {
        formatter = @"yyyy-MM-dd";
        dateStr = [NSString stringWithFormat:@"%@-%@-%@",self.currentPickerArr[0],self.currentPickerArr[1],self.currentPickerArr[2]];
    }else {
        formatter = @"yyyy-MM-dd HH:mm";
        dateStr = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",self.currentPickerArr[0],self.currentPickerArr[1],self.currentPickerArr[2],self.currentPickerArr[3],self.currentPickerArr[4]];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formatter];

    self.selectDate = [dateFormatter dateFromString:dateStr];
    
    [self p_setData];
    
    NSMutableArray *dStrs = [[NSMutableArray alloc] init];
    for (int i = 0; i < self.currentPickerArr.count; i++) {
        NSString *str = [NSString stringWithFormat:@"%@",self.currentPickerArr[i]];
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
