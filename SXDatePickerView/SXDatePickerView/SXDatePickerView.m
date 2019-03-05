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
#define ROW_HEIGHT 44

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
@property(nonatomic,strong)NSArray<NSNumber *> *currentPickerArr;
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
    
}
-(void)p_closeAction {
    [self hidden];
}
#pragma mark - 公有方法
-(void)hidden {
    [self removeFromSuperview];
}
#pragma mark - set方法
-(void)setShowRows:(int)showRows {
    _showRows = showRows;
    
    CGFloat bottomH = 0;
    if (SX_IS_IPHONE_X) {
        bottomH = 35;
    }
    
    self.contentView.frame = CGRectMake(0, SX_SCREEN_HEIGHT - (TOOL_HEIGHT + ROW_HEIGHT * showRows + bottomH), SX_SCREEN_WIDTH, TOOL_HEIGHT + ROW_HEIGHT * showRows + bottomH);
    self.pickerView.frame = CGRectMake(0, TOOL_HEIGHT, SX_SCREEN_WIDTH, ROW_HEIGHT * showRows);
    
//    [self.pickerView reloadAllComponents];
}
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
    
    self.currentPickerArr = @[@(components.year),
                              @(components.month),
                              @(components.day),
                              @(components.hour),
                              @(components.minute)];
    
    [self p_setData];
}
-(void)setUnitArr:(NSArray *)unitArr {
    NSAssert(unitArr.count == 5, @"The count of unitArr must is five!");
    _unitArr = unitArr;
}


-(void)p_initData {
    
    NSDate *date = [NSDate new];
    
    self.timeDataArr = @[self.yearArr,self.monthArr,self.dayArr,self.hourArr,self.minuteArr];
    
    self.showRows = 7;
    
    self.minDate = [NSDate dateWithTimeIntervalSince1970:0];
    
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:date];
    [components setValue:components.year + 100 forComponent:NSCalendarUnitYear];
    
    self.maxDate = [calendar dateFromComponents:components];
    
    self.currentDate = date;
    
    self.unitArr = @[@"",@"",@"",@"",@""];
    self.dateType = SXDateType_DateTime;
}
-(void)p_setData {
    
    if (self.minDate == nil || self.maxDate == nil || self.currentDate == nil) {
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
}
-(void)p_setYearData {
    
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
  
    [_selComponents setValue:self.currentPickerArr[0].intValue forComponent:NSCalendarUnitYear];
    [_selComponents setValue:self.currentPickerArr[1].intValue forComponent:NSCalendarUnitMonth];
    [_selComponents setValue:0 forComponent:NSCalendarUnitDay];
    NSDate *zeroDayDate = [self.calendar dateFromComponents:_selComponents];
    
    for (int i = 1; i <= 31; i++) {
        NSDate *d = [NSDate dateWithTimeInterval:24*60*60*i sinceDate:zeroDayDate];
        
        if ([d laterDate:[NSDate dateWithTimeInterval:-24*60*60 sinceDate:self.minDate]] && [d earlierDate:[NSDate dateWithTimeInterval:24*60*60 sinceDate:self.maxDate]]) {
            
            NSCalendar *calendar1 = [NSCalendar currentCalendar];
            NSDateComponents *components1 = [calendar1 components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:d];
            if (components1.month == self.currentPickerArr[1].intValue) {
                [self.dayArr addObject:@(i)];
            }
        }
    }
}
-(void)p_setHourData {

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

    [_selComponents setValue:self.currentPickerArr[0].intValue forComponent:NSCalendarUnitYear];
    [_selComponents setValue:self.currentPickerArr[1].intValue forComponent:NSCalendarUnitMonth];
    [_selComponents setValue:self.currentPickerArr[2].intValue forComponent:NSCalendarUnitDay];
    [_selComponents setValue:self.currentPickerArr[3].intValue forComponent:NSCalendarUnitHour];
    
    for (int i = 0; i < 60; i++) {
        [_selComponents setValue:i forComponent:NSCalendarUnitMinute];
        NSDate *d = [self.calendar dateFromComponents:_selComponents];
        if ([d laterDate:[NSDate dateWithTimeInterval:-60 sinceDate:self.minDate]] && [d earlierDate:[NSDate dateWithTimeInterval:60 sinceDate:self.maxDate]]) {
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
    return ROW_HEIGHT;
}
-(NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component {
    
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
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
    return attrStr;
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
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, SX_SCREEN_HEIGHT - 300, SX_SCREEN_WIDTH, 300)];
        _contentView.backgroundColor = UIColor.whiteColor;
        if (SX_IS_IPHONE_X) {
            
        }
    }
    return _contentView;
}
-(UIView *)toolView {
    if (!_toolView) {
        _toolView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SX_SCREEN_WIDTH, 44)];
    }
    return _toolView;
}
-(UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 44, SX_SCREEN_WIDTH, 254)];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
    }
    return _pickerView;
}
-(UILabel *)titleLb {
    if (!_titleLb) {
        _titleLb = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SX_SCREEN_WIDTH, 44)];
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
        _line = [[UIView alloc] initWithFrame:CGRectMake(0, 43, SX_SCREEN_WIDTH, 1)];
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
