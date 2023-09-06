//
//  DemoViewController.m
//  RSRotatePage
//
//  Created by 黄雄荣 on 2023/9/6.
//

#import "DemoViewController.h"
#import "RSSDK.h"

static NSString *kRuseIdentifier = @"reuse";

@interface DemoViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *scenes;
@property (strong, nonatomic) UITableView *tableView;

@end

@implementation DemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"指定界面支持旋转";
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorColor = [UIColor colorWithWhite:0.9 alpha:1];
    tableView.tableFooterView = [UIView new];
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kRuseIdentifier];
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.scenes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kRuseIdentifier forIndexPath:indexPath];
    cell.textLabel.text = self.scenes[indexPath.row];
    cell.textLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [RSSDK sdkPushController:SDKControllerTypeNormal];
    } else if (indexPath.row == 1) {
        [RSSDK sdkPushController:SDKControllerTypeForceLandscape];
    } else if (indexPath.row == 2) {
        [RSSDK sdkPushController:SDKControllerTypeForcePortrait];
    }
    
}

- (NSArray *)scenes{
    if (!_scenes) {
        _scenes = @[@"普通界面", @"强制横屏界面", @"强制竖屏界面"];
    }
    return _scenes;
}

@end
