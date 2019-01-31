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
    Ivar *ivar_arr = class_copyIvarList(object_getClass(self), &count);
    for (int i = 0; i < count; i++) {
        Ivar ivar = ivar_arr[i];
        PYLModelProperty *property = [[PYLModelProperty alloc] initWithObjcIvar:ivar];
        if ([self isPropertySupportArchive:property]) {
            [aCoder encodeObject:[self valueForKey:property.name] forKey:property.name];
        }
    }
    free(ivar_arr);
}

+ (BOOL)supportsSecureCoding {
    return YES;
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        unsigned int count;
        Ivar *ivar_arr = class_copyIvarList(object_getClass(self), &count);
        for (int i = 0; i < count; i++) {
            Ivar ivar = ivar_arr[i];
            PYLModelProperty *property = [[PYLModelProperty alloc] initWithObjcIvar:ivar];
            if (![self isPropertySupportArchive:property]) {
                continue;
            }
            id value;
            if ([[@"c,i,s,l,q,C,I,S,L,Q,f,d,B" componentsSeparatedByString:@","] containsObject:property.type]) {
                value = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:property.name];
                
            } else if ([property.type isEqualToString:@"NSString"]) {
                value = [aDecoder decodeObjectOfClass:[NSString class] forKey:property.name];
            } else if ([property.type isEqualToString:@"NSMutableString"]) {
                value = [aDecoder decodeObjectOfClass:[NSMutableString class] forKey:property.name];
            } else if ([property.type isEqualToString:@"NSArray"]) {
                value = [aDecoder decodeObjectOfClass:[NSArray class] forKey:property.name];
            } else if ([property.type isEqualToString:@"NSMutableArray"]) {
                value = [aDecoder decodeObjectOfClass:[NSMutableArray class] forKey:property.name];
            } else if ([property.type isEqualToString:@"NSDictionary"]) {
                value = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:property.name];
            } else if ([property.type isEqualToString:@"NSMutableDictionary"]) {
                value = [aDecoder decodeObjectOfClass:[NSMutableDictionary class] forKey:property.name];
            } else if ([property.type isEqualToString:@"NSDate"]) {
                value = [aDecoder decodeObjectOfClass:[NSDate class] forKey:property.name];
            } else {
                value = [aDecoder decodeObjectForKey:property.name];
            }
            if (value) {
                [self setValue:value forKey:property.name];
            }
        }
        free(ivar_arr);
    }
    return self;
}

- (BOOL)isPropertySupportArchive:(PYLModelProperty *)property {
    return ![[@"#,:" componentsSeparatedByString:@","] containsObject:property.type];
}

@end
