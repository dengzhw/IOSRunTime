//
//  SOModel.h
//  SOProperty
//
//  Created by zwdeng on 16/4/28.
//  Copyright © 2016年 zwdeng. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SOModel : NSObject{
    NSString* myStr1;
}
@property(strong,nonatomic) NSString *myStr2;
@property(assign,nonatomic) NSInteger count;
@property(strong,nonatomic) NSDictionary*myDic;
-(void)fetchList;
- (instancetype)initWithDict:(NSDictionary *)dict;

@end
