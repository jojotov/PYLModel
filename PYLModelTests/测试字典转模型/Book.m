//
//  Book.m
//  PYLModelTests
//
//  Created by yulei pang on 2019/1/29.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import "Book.h"
#import "Author.h"

@implementation Book

- (NSDictionary<NSString *, NSString *> *)propertyName_jsonKey_mapper {
    return @{
             @"bookID":@"id",
             @"created": @"created_at",
             @"updated": @"updated_at",
             @"single": @"singleAuthor"
             };
}

- (NSDictionary<NSString *,Class> *)propertyName_elementClass_mapper {
    return @{@"authors":Author.class, @"extraAuthDict":Author.class};
}

- (NSDictionary<NSString *,NSString *> *)propertyName_dateFormat_mapper {
    return @{@"updated": @"YYYY-MM-dd"};
}
@end
