//
//  UIButton+View.h
//  SOProperty
//
//  Created by zwdeng on 16/4/28.
//  Copyright © 2016年 zwdeng. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UIButton(CallBack)
- (instancetype)initWithFrame:(CGRect)frame callback:(void (^)(UIButton *))callbackBlock;

@end
