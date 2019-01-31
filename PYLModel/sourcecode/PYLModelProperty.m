//
//  PYLModelProperty.m
//  PYLModel
//
//  Created by yulei pang on 2019/1/29.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import "PYLModelProperty.h"

@implementation PYLModelProperty
- (instancetype)initWithObjcProperty:(objc_property_t)prop {
    if (self = [super init]) {
        _name = [NSString stringWithUTF8String:property_getName(prop)];
        //属性
        unsigned int attrCount;
        objc_property_attribute_t *attr_arr = property_copyAttributeList(prop, &attrCount);
        for (int j = 0; j < attrCount; j++) {
            objc_property_attribute_t attr = attr_arr[j];
            if ([@"T" isEqualToString:[NSString stringWithUTF8String:attr.name]]) {
                
                NSString *str = [NSString stringWithUTF8String:attr.value];
                
                if ([str rangeOfString:@"@\""].location == 0) {
                    //@"NSString"
                    //去掉 @""
                    _type = [str substringWithRange:NSMakeRange(2, str.length-3)];
                } else {
                    //q 之类的基础类型
                    _type = str;
                }
                
                break;
            }
        }
        free(attr_arr);
    }
    return self;
}

- (instancetype)initWithObjcIvar:(Ivar)ivar {
    if (self = [super init]) {
        _name = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1]; //去掉 _
        NSString *str = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        if ([str rangeOfString:@"@\""].location == 0) {
            //@"NSString"
            //去掉 @""
            _type = [str substringWithRange:NSMakeRange(2, str.length-3)];
        } else {
            //q 之类的基础类型
            _type = str;
        }
    }
    return self;
}
@end
