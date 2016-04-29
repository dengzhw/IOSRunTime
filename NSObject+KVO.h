//
//  NSObject+KVO.h
//  SOProperty
//
//  Created by zwdeng on 16/4/29.
//  Copyright © 2016年 zwdeng. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void(^KVOBlock)(id observerdObject,NSString*observedKey,id oldValue,id newValue);

@interface NSObject(KVO)
-(void)DZ_addObserver:(NSObject*)observer forKey:(NSString*)key withBlock:(KVOBlock)block;
-(void)DZ_removeObserver:(NSObject*)observer forKey:(NSString*)key;

@end
