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
    
    [self.view addSubview:pv];
}
@end
