//
//  Book.h
//  PYLModelTests
//
//  Created by yulei pang on 2019/1/29.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import "PYLModel.h"

@class Author;
@interface Book : PYLModel
@property (nonatomic) long long bookID;
@property (nonatomic) BOOL isSoldOut;
@property (nonatomic) BOOL isOkForKid;
@property (nonatomic) char sign;
@property (nonatomic) short testShort;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *salary;
@property (nonatomic) NSDate *created;
@property (nonatomic) NSDate *updated;
@property (nonatomic) NSArray<NSString *> *previews;
@property (nonatomic) NSMutableArray<Author *> *authors;
@property (nonatomic) Author *single;
@property (nonatomic) NSMutableDictionary<id,Author*> *extraAuthDict;
@property (nonatomic) id some;
@property (nonatomic) Class fatherClass;
@property (nonatomic) SEL aSEL;
@end
