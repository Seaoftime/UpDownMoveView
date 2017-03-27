//
//  ViewController.m
//  UpDownMoveView
//
//  Created by Seiko on 17/3/27.
//  Copyright © 2017年 RuiZhang. All rights reserved.
//

#import "ViewController.h"

#import "ZRMoveView.h"
#import "PresentViewController.h"

@interface ViewController ()<ZRMoveViewDelegate>

@property (nonatomic, strong) ZRMoveView *scrollMoveView;


@end

@implementation ViewController

- (void)dealloc {

    NSLog(@"vc dealloc...");
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_scrollMoveView) {
        [_scrollMoveView start];
    }
   
}

- (void)viewWillDisappear:(BOOL)animated {

    [super viewWillDisappear:animated];
    
    if (_scrollMoveView) {
        [_scrollMoveView pause];
    }

}


- (void)viewDidLoad {
    [super viewDidLoad];
    //
    
    _scrollMoveView = [[ZRMoveView alloc] initWithFrame:CGRectMake(12 + 44, 200, [UIScreen mainScreen].bounds.size.width - 24 - 44, 30)];
    _scrollMoveView.moveDelegate = self;
    _scrollMoveView.timeIntervalPerScroll = 3.0f;
    _scrollMoveView.timeDurationPerScroll = 1.0f;
    [self.view addSubview:_scrollMoveView];
    [_scrollMoveView reloadData];

    
    
    
    UIButton *butt = [[UIButton alloc] initWithFrame:CGRectMake(0, 300, 100, 44)];
    [butt setTitle:@"present" forState:UIControlStateNormal];
    [butt addTarget:self action:@selector(buttonisclicked) forControlEvents:UIControlEventTouchUpInside];
    butt.backgroundColor = [UIColor orangeColor];
    
    [self.view addSubview:butt];
    
    
}


- (void)buttonisclicked {
    
    [self presentViewController:[[PresentViewController alloc] init] animated:YES completion:nil];
    
}



#pragma mark ------------------ MoveViewDelegate

- (NSInteger)numberOfVisibleItemsForMoveView:(ZRMoveView *)moveView {
    return 1;
}


- (NSArray*)dataSourceArrayForMoveView:(ZRMoveView *)moveView {
    
    return @[@"iOS操作系统Demo, iOS操作系统Demo", @"android操作系统Demo, android操作系统Demo", @"iOS...iOS...iOS...iOS"];
    
}


- (void)createItemView:(UIView *)itemView forMoveView:(ZRMoveView *)moveView {
    
    itemView.backgroundColor = [UIColor orangeColor];
    
    UILabel *content = [[UILabel alloc] initWithFrame:itemView.bounds];
    content.font = [UIFont systemFontOfSize:17];
    content.tag = 1011;
    [itemView addSubview:content];
}


- (void)updateItemView:(UIView *)itemView withData:(id)data forMoveView:(ZRMoveView *)moveView {
    
    UILabel *content = [itemView viewWithTag:1011];
    content.text = data;
    
}









- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
