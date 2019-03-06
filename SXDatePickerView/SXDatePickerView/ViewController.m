//
//  ViewController.m
//  SXDatePickerView
//
//  Created by apple on 2019/3/5.
//  Copyright © 2019年 zsx. All rights reserved.
//

#import "ViewController.h"
#import "SXDatePickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
  
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    SXDatePickerView *pv = [[SXDatePickerView alloc] init];
    pv.unitArr = @[@"年",@"月",@"日",@"时",@"分"];
    pv.intervalOfMinute = 30;
    pv.minDate = [NSDate new];
    pv.hourRange = NSMakeRange(18, 4);
    [self.view addSubview:pv];
    
    pv.selectDateBlock = ^(NSDate *date) {
        NSLog(@"%@",date);
    };
    
    pv.selectDateStrBlock = ^(NSString *dateStr) {
        NSLog(@"%@",dateStr);
    };
}
@end
