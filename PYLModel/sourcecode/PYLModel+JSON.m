//
//  PYLModel+JSON.m
//  PYLModel
//
//  Created by yulei pang on 2019/1/31.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import "PYLModel+JSON.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PYLModelProperty.h"

@implementation PYLModel (JSON)
- (instancetype)initWithJSON:(NSDictionary *)json {
    self = [super init];
    if (self) {
        unsigned int count;
        objc_property_t *prop_arr = class_copyPropertyList(object_getClass(self), &count);
        for (int i = 0; i < count; i++) {
            objc_property_t prop = prop_arr[i];
            PYLModelProperty *property = [[PYLModelProperty alloc] initWithObjcProperty:prop];
            NSString *jsonKey = self.propertyName_jsonKey_mapper[property.name];
            if (!jsonKey.length) {
                jsonKey = property.name;
            }
            id jsonValue = json[jsonKey];
            [self setJSONValue:jsonValue withProperty:property];
        }
        free(prop_arr);
    }
    return self;
}

- (SEL)setterSEL:(PYLModelProperty *)property {
    NSString *str = property.name;
    NSString *capitalLetter = [[str substringToIndex:1] capitalizedString];
    return sel_registerName([NSString stringWithFormat:@"set%@%@:", capitalLetter, [str substringFromIndex:1]].UTF8String);
}

- (void)setJSONValue:(id)jsonValue withProperty:(PYLModelProperty *)property {
    if (!jsonValue) {
        return;
    }
    
    if ([[@"c,i,s,l,q,C,I,S,L,Q,f,d,B" componentsSeparatedByString:@","] containsObject:property.type]) {
        if ([[@"s,l,C,I,S,L,Q" componentsSeparatedByString:@","] containsObject:property.type] && [jsonValue isKindOfClass:[NSString class]]) {
            //转换成 NSNumber
            jsonValue = @([(NSString*)jsonValue doubleValue]);
        }
        [self setValue:jsonValue forKey:property.name];
    
    } else if ([property.type isEqualToString:@"NSString"] || [property.type isEqualToString:@"NSMutableString"]) {
        [self setJSONValue:jsonValue withStringProperty:property];
        
    } else if ([property.type isEqualToString:@"NSDate"]) {
        [self setJSONValue:jsonValue withDateProperty:property];
        
    } else if (([property.type isEqualToString:@"NSArray"] || [property.type isEqualToString:@"NSMutableArray"]) && [jsonValue isKindOfClass:[NSArray class]]) {
        [self setJSONValue:jsonValue withArrayProperty:property];
        
    } else if (([property.type isEqualToString:@"NSDictionary"] || [property.type isEqualToString:@"NSMutableDictionary"]) && [jsonValue isKindOfClass:[NSDictionary class]]) {
        [self setJSONValue:jsonValue withDictionaryProperty:property];
        
    } else {
        //property.type 是自定义的类
        Class cls = objc_getClass([property.type UTF8String]);
        if (cls && [jsonValue isKindOfClass:[NSDictionary class]]) {
            id object = [[cls alloc] initWithJSON:jsonValue];
            [self setValue:object forKey:property.name];
        }
    }
}

- (void)setJSONValue:(id)jsonValue withStringProperty:(PYLModelProperty *)property {
    NSString *str;
    if ([jsonValue isKindOfClass:[NSString class]]) {
        str = jsonValue;
    } else if ([jsonValue isKindOfClass:[NSNumber class]]) {
        str = [jsonValue stringValue];
    }
    if (str) {
        [self setValue:[str mutableCopy] forKey:property.name];
    }
}

- (void)setJSONValue:(id)jsonValue withDateProperty:(PYLModelProperty *)property {
    NSString *dateFormat = self.propertyName_dateFormat_mapper[property.name];
    NSDate *date;
    if (dateFormat.length) {
        //使用 format 处理
        NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
        fmt.dateFormat = dateFormat;
        date = [fmt dateFromString:jsonValue];
    } else if ([jsonValue respondsToSelector:@selector(longLongValue)]) {
        //使用时间戳处理
        date = [NSDate dateWithTimeIntervalSince1970:[jsonValue longLongValue]];
    }
    if (date) {
        [self setValue:date forKey:property.name];
    }
}

- (void)setJSONValue:(id)jsonValue withArrayProperty:(PYLModelProperty *)property {
    Class elementClass = self.propertyName_elementClass_mapper[property.name];
    if (elementClass) {
        //元素是另一个类
        if ([elementClass isSubclassOfClass:[PYLModel class]]) {
            NSMutableArray *tmpArray = @[].mutableCopy;
            for (id elementJSON in jsonValue) {
                if ([elementJSON isKindOfClass:[NSDictionary class]]) {
                    id element = [[elementClass alloc] initWithJSON:elementJSON];
                    [tmpArray addObject:element];
                }
            }
            if (tmpArray.count) {
                [self setValue:tmpArray forKey:property.name];
            }
        } else {
            NSLog(@"元素类型也应该继承 PYLModel %s", __func__);
        }
    } else {
        //直接赋值
        [self setValue:[jsonValue mutableCopy] forKey:property.name];
    }
}

- (void)setJSONValue:(id)jsonValue withDictionaryProperty:(PYLModelProperty *)property {
    Class elementClass = self.propertyName_elementClass_mapper[property.name];
    if (elementClass) {
        //元素是另一个类
        if ([elementClass isSubclassOfClass:[PYLModel class]]) {
            NSMutableDictionary *tmpDict = @{}.mutableCopy;
            [jsonValue enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull elementJSON, BOOL * _Nonnull stop) {
                if ([elementJSON isKindOfClass:[NSDictionary class]]) {
                    id element = [[elementClass alloc] initWithJSON:elementJSON];
                    tmpDict[key] = element;
                }
            }];
            if (tmpDict.allKeys.count) {
                [self setValue:tmpDict forKey:property.name];
            }
        } else {
            NSLog(@"元素类型也应该继承 PYLModel %s", __func__);
        }
    } else {
        //直接赋值
        [self setValue:[jsonValue mutableCopy] forKey:property.name];
    }
}

- (NSDictionary<NSString *, NSString *> *)propertyName_jsonKey_mapper {
    return @{};
}

- (NSDictionary<NSString *,NSString *> *)propertyName_dateFormat_mapper {
    return @{};
}

- (NSDictionary<NSString *,Class> *)propertyName_elementClass_mapper {
    return @{};
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"set value for undefine key: %@ %s", key, __func__);
}

@end
