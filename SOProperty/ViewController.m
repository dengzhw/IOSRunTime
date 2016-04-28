//
//  ViewController.m
//  SOProperty
//
//  Created by zwdeng on 16/4/28.
//  Copyright © 2016年 zwdeng. All rights reserved.
//

#import "ViewController.h"
#import "SOModel.h"
#import "UIButton+CallBack.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    SOModel *model = [[SOModel alloc] init];
    [model fetchList];
    NSDictionary *dic = [[NSDictionary alloc] init];
    SOModel * m = [[SOModel alloc] initWithDict:dic];
    NSLog(@"keys :%@=====> values :%@",dic.allKeys,dic.allValues);
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 60) callback:^(UIButton * bt){
        NSLog(@"hahahahahahah");
    }];
    button.titleLabel.text=@"点我";
    button.backgroundColor = [UIColor redColor];
    [self.view addSubview:button];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
