//
//  SampleViewController.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/4.
//

#import "SampleViewController.h"

@implementation SampleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 100, 240, 50)];
    self.title = @"普通界面";
    label.text = @"这是一个正常的界面";
    if (self.forceLandscape) {
        self.title = @"强制横屏界面";
        label.text = @"这是一个强制横屏的界面";
    } else if (self.forcePortrait) {
        self.title = @"强制竖屏界面";
        label.text = @"这是一个强制竖屏的界面";
    }
    [self.view addSubview:label];
    // Do any additional setup after loading the view.
}

//#pragma mark - 支持设备旋转
//
//- (void)viewWillAppear:(BOOL)animated {
//    [super viewWillAppear:animated];
//    
//    // 必要时旋转方向
//    [self changeOrientationIfNeeded];
//}
//
//- (void)viewWillDisappear:(BOOL)animated {
//    [super viewWillDisappear:animated];
//    // 恢复方向
//    [self restoreOrientation];
//}


@end
