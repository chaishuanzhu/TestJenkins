//
//  ViewController.m
//  TestJenkins
//
//  Created by 飞鱼 on 2019/5/13.
//  Copyright © 2019 xxx. All rights reserved.
//

#import "ViewController.h"
#import "HLThread.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startHLThread];
    // Do any additional setup after loading the view.
}

- (void)startHLThread {
    HLThread *thread = [[HLThread alloc]initWithTarget:self selector:@selector(hlThreadOperation) object:nil];
    [thread start];
}

- (void)hlThreadOperation {

    NSLog(@"%@----",[NSThread currentThread]);
    [NSThread sleepForTimeInterval:3.0];
    NSLog(@"%@-----",[NSThread currentThread]);
}

@end
