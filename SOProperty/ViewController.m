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
#import "NSObject+KVO.h"

@interface KVOTest : NSObject
@property (nonatomic, copy) NSString *text;
@end

@implementation KVOTest

@end

@interface ViewController ()
@property(nonatomic,strong) KVOTest *kvo;
@property(nonatomic,strong) UITextView *tv;

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
    
    self.tv = [[UITextView alloc] initWithFrame:CGRectMake(0, 200, 400, 50)];
    self.tv.backgroundColor = [UIColor grayColor];
    
    __weak ViewController *weakself = self;
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 300, 100, 60) callback:^(UIButton * btn) {
        NSArray *arry =@[@"deng",@"la",@"ha",@"ya"];
        weakself.kvo.text = arry[arc4random()%4];
    }];
//    [button1  addTarget:self action:@selector(clickMe:) forControlEvents:UIControlEventTouchUpInside];
    
    
    button1.titleLabel.text=@"改变我";
    button1.backgroundColor = [UIColor redColor];
    button1.tintColor = [UIColor blueColor];
    [self.view addSubview:button];
    
    [self.view addSubview:_tv];
    [self.view addSubview:button1];
    
    self.kvo = [[KVOTest alloc] init];
    [self.kvo DZ_addObserver:self forKey:NSStringFromSelector(@selector(text)) withBlock:^(id observerdObject, NSString *observedKey, id oldValue, id newValue) {
        NSLog(@"%@.%@ is now: %@", observerdObject, observedKey, newValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.tv.text = newValue;
        });
        
    }];
    
}
-(void)clickMe:(UIButton*)btn{
     NSArray *arry =@[@"deng",@"la",@"ha",@"ya"];
    self.kvo.text = arry[arc4random()%4];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
