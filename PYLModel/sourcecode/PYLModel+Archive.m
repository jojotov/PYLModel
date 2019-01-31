//
//  PYLModel+Archive.m
//  PYLModel
//
//  Created by yulei pang on 2019/1/31.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import "PYLModel+Archive.h"
#import "PYLModelProperty.h"

@implementation PYLModel (Archive)

- (void)encodeWithCoder:(NSCoder *)aCoder {
    unsigned int count;
    objc_property_t *prop_arr = class_copyPropertyList(object_getClass(self), &count);
    for (int i = 0; i < count; i++) {
        objc_property_t prop = prop_arr[i];
        PYLModelProperty *property = [[PYLModelProperty alloc] initWithObjcProperty:prop];
        [aCoder encodeObject:[self valueForKey:property.name] forKey:property.name];
    }
    free(prop_arr);
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int count;
        objc_property_t *prop_arr = class_copyPropertyList(object_getClass(self), &count);
        for (int i = 0; i < count; i++) {
            objc_property_t prop = prop_arr[i];
            PYLModelProperty *property = [[PYLModelProperty alloc] initWithObjcProperty:prop];
            id value = [aDecoder decodeObjectForKey:property.name];
            [self setValue:value forKey:property.name];
        }
        free(prop_arr);
    }
    return self;
}

@end
