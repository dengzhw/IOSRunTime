//
//  UIButton+View.m
//  SOProperty
//
//  Created by zwdeng on 16/4/28.
//  Copyright © 2016年 zwdeng. All rights reserved.
//

#import "UIButton+CallBack.h"
#include<objc/runtime.h>

@interface UIButton()
@property(nonatomic,copy)void(^callbackBlock)(UIButton* button);
@end

@implementation UIButton(CallBack)

-(void(^)(UIButton*))callbackBlock{
    return objc_getAssociatedObject(self, @selector(callbackBlock));
}
-(void)setCallbackBlock:(void (^)(UIButton *))callbackBlock{
    objc_setAssociatedObject(self, @selector(callbackBlock), callbackBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}
-(instancetype)initWithFrame:(CGRect)frame callback:(void (^)(UIButton *))callbackBlock{
    self = [super initWithFrame:frame];
    if(self){
        self.callbackBlock = callbackBlock;
        [self addTarget:self action:@selector(didClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

-(void)didClickAction:(UIButton*)button{
    self.callbackBlock(button);
}



@end
