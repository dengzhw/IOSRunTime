//
//  NSObject+KVO.m
//  SOProperty
//
//  Created by zwdeng on 16/4/29.
//  Copyright © 2016年 zwdeng. All rights reserved.
//

#import "NSObject+KVO.h"
#include <objc/runtime.h>
#import <objc/message.h>

NSString *const kDZKVONotifyPrefix = @"DZKVONotify_";
NSString *const kDZAssociatedObservers = @"DZKVOAssociatedObservers";



@interface DZObserverModel : NSObject
@property(nonatomic,weak) NSObject* observer;
@property(nonatomic,copy) NSString* key;
@property(nonatomic,copy) KVOBlock block;

@end

@implementation DZObserverModel

-(instancetype)initWithObserver:(NSObject*)observer Key:(NSString*)key  block:(KVOBlock)block{
    self  =[super init];
    if (self) {
        _observer = observer;
        _key = key;
        _block = block;
    }
    return self;
}

@end


#pragma mark - Helpers
static NSString * getSetter(NSString *setter)
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    // remove 'set' at the begining and ':' at the end
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    // lower case the first letter
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    
    return key;
}

#pragma mark - Overridden Methods
static void kvo_setter(id self, SEL _cmd, id newValue)
{
    NSString *setterName = NSStringFromSelector(_cmd);
    NSString *getterName = getSetter(setterName);
    
    if (!getterName) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }
    
    id oldValue = [self valueForKey:getterName];
    
    struct objc_super superclazz = {
        .receiver = self,
        .super_class = class_getSuperclass(object_getClass(self))
    };
    
    // cast our pointer so the compiler won't complain
    void (*objc_msgSendSuperCasted)(void *, SEL, id) = (void *)objc_msgSendSuper;
    
    // call super's setter, which is original class's setter method
    objc_msgSendSuperCasted(&superclazz, _cmd, newValue);
    
    // look up observers and call the blocks
    NSMutableArray *observers = objc_getAssociatedObject(self, (__bridge const void *)(kDZAssociatedObservers));
    for (DZObserverModel *mode in observers) {
        if ([mode.key isEqualToString:getterName]) {
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                mode.block(self, getterName, oldValue, newValue);
            });
        }
    }
}

static Class kvo_class(id self, SEL _cmd)
{
    return class_getSuperclass(object_getClass(self));
}


@implementation NSObject(KVO)
-(void)DZ_addObserver:(NSObject*)observer forKey:(NSString*)key withBlock:(KVOBlock)block{
    SEL setterSelector = NSSelectorFromString([self getSetterKey:key]);
    Method setterMethod = class_getInstanceMethod([self class], setterSelector);
    if (!setterMethod) {
        NSString *error = [NSString stringWithFormat:@"Object %@ does not have a setter method for key %@",self,key];
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:error userInfo:nil];
        return;
    }
    Class clazz = object_getClass(self);
    NSString *clazzName = NSStringFromClass(clazz);
    if (![clazzName hasPrefix:kDZKVONotifyPrefix]) {
        clazz = [self makeKvoClassWithOriginClass:clazzName];
        object_setClass(self, clazz);
    }
    if (![self hasSelector:setterSelector]) {
        const char * type = method_getTypeEncoding(setterMethod);
        class_addMethod(clazz, setterSelector, (IMP)kvo_setter, type);
        
    }
    DZObserverModel * mode = [[DZObserverModel alloc] initWithObserver:observer Key:key block:block];
    NSMutableArray *mobservers = objc_getAssociatedObject(self, (__bridge const void *)(kDZAssociatedObservers));
    if (!mobservers) {
        mobservers = [NSMutableArray array];
        objc_setAssociatedObject(self,(__bridge const void *)(kDZAssociatedObservers), mobservers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    [mobservers addObject:mode];
    
}



-(void)DZ_removeObserver:(NSObject*)observer forKey:(NSString*)key{
    NSMutableArray* observers = objc_getAssociatedObject(self, (__bridge const void *)(kDZAssociatedObservers));
    
    DZObserverModel *model;
    for (DZObserverModel* info in observers) {
        if (info.observer == observer && [info.key isEqual:key]) {
            model = info;
            break;
        }
    }
    
    [observers removeObject:model];
    
}
-(NSString*)getSetterKey:(NSString*)key{
    if (key==nil||key.length<=0) {
        return nil;
    }
    NSString *firstLetter = [[key substringToIndex:1] uppercaseString];
    NSString *leaveLetter =[key substringFromIndex:1];
    NSString *setterString = [NSString stringWithFormat:@"set%@%@:",firstLetter,leaveLetter];
    return setterString;

}
-(Class)makeKvoClassWithOriginClass:(NSString*)className{
    NSString * kvoClassName  = [kDZKVONotifyPrefix stringByAppendingString:className];
    Class clazz = NSClassFromString(kvoClassName);
    if (clazz) {
        return clazz;
    }
    Class originalClass = object_getClass(self);
    Class currentkvoClass = objc_allocateClassPair(originalClass, kvoClassName.UTF8String, 0);
    Method originalClassMethod = class_getInstanceMethod(originalClass, @selector(class));
    const char* types = method_getTypeEncoding(originalClassMethod);
    class_addMethod(currentkvoClass, @selector(class), (IMP)kvo_class, types);
    objc_registerClassPair(currentkvoClass);
    return currentkvoClass;
}

-(Boolean)hasSelector:(SEL)selector{
    Class clazz = object_getClass(self);
    unsigned int count  = 0;
    Method *MethodList  = class_copyMethodList(clazz, &count);
    for(unsigned int i = 0;i<count;i++){
        SEL currentSelector = method_getName(MethodList[i]);
        if (currentSelector == selector) {
            return YES;
        }
    }
    free(MethodList);
    return NO;
}






















@end
