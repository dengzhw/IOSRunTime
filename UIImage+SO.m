//
//  UIImage+SO.m
//  SOProperty
//
//  Created by zwdeng on 16/4/28.
//  Copyright © 2016年 zwdeng. All rights reserved.
//

#import "UIImage+SO.h"
#import <objc/runtime.h>

@implementation UIImage(SO)
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class selfClass = object_getClass([self class]);
        SEL oriSEL = @selector(imageNamed:);
        Method oriMethod = class_getInstanceMethod(selfClass, oriSEL);
        
        SEL cusSEL = @selector(mImageName:);
        Method cusMethod = class_getInstanceMethod(selfClass, cusSEL);
        Boolean addSucc = class_addMethod(selfClass, oriSEL, method_getImplementation(cusMethod), method_getTypeEncoding(cusMethod));
        if (addSucc) {
            class_replaceMethod(selfClass, cusSEL, method_getImplementation(oriMethod), method_getTypeEncoding(oriMethod));
        }else{
            method_exchangeImplementations(oriMethod, cusMethod);
        }
    });
    
}

+ (UIImage *)mImageName:(NSString *)name {
    
    NSString * newName = [NSString stringWithFormat:@"%@%@", @"new_", name];
    return [self mImageName:newName];
}

@end
