//
//  ViewController.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import "ViewController.h"
#import "DemoViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        DemoViewController *demoVC = [[DemoViewController alloc] init];
        [self.navigationController pushViewController:demoVC animated:YES];
    });
}

@end
