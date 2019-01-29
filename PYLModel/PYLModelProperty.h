//
//  PYLModelProperty.h
//  PYLModel
//
//  Created by yulei pang on 2019/1/29.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@class PYLModelPropertyAttributes;
@interface PYLModelProperty : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *type;
- (instancetype)initWithObjcProperty:(objc_property_t)prop;
@end
