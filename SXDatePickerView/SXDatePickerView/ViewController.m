//
//  ViewController.m
//  SXDatePickerView
//
//  Created by apple on 2019/3/5.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import "ViewController.h"
#import "SXDatePickerView.h"
#import "SXDatePickerConfig.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    SXDatePickerConfig *config = [[SXDatePickerConfig alloc] init];
    config.unitArr = @[@"年",@"月",@"日",@"时",@"分"];
    config.intervalOfMinute = 30;
    config.minDate = [NSDate new];
    config.hourRange = NSMakeRange(18, 4);
    
    SXDatePickerView *pv = [[SXDatePickerView alloc] initWithConfig:config];
    
    [self.view addSubview:pv];
    
    pv.selectDateBlock = ^(NSDate *date) {
        NSLog(@"%@",date);
    };
    
    pv.selectDateStrBlock = ^(NSString *dateStr) {
        NSLog(@"%@",dateStr);
    };
}
@end
