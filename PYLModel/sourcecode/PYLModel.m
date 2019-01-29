//
//  PYLModel.m
//  PYLModel
//
//  Created by yulei pang on 2019/1/29.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import "PYLModel.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "PYLModelProperty.h"

@implementation PYLModel

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
    SEL setterSEL = [self setterSEL:property];
    if (![self respondsToSelector:setterSEL]) {
        return;
    }
    if ([@[@"s",@"l",@"C",@"I",@"S",@"L",@"Q"] containsObject:property.type] && [jsonValue isKindOfClass:[NSString class]]) {
        //转换成 NSNumber
        jsonValue = @([(NSString*)jsonValue doubleValue]);
    }
    if ([property.type isEqualToString:@"c"] && [jsonValue respondsToSelector:@selector(charValue)]) {
        ((void(*)(id,SEL,char))(void*)objc_msgSend)(self, setterSEL, [jsonValue charValue]);
        
    } else if ([property.type isEqualToString:@"i"] && [jsonValue respondsToSelector:@selector(intValue)]) {
        ((void(*)(id,SEL,int))(void*)objc_msgSend)(self, setterSEL, [jsonValue intValue]);
        
    } else if ([property.type isEqualToString:@"s"] && [jsonValue respondsToSelector:@selector(shortValue)]) {
        ((void(*)(id,SEL,short))(void*)objc_msgSend)(self, setterSEL, [jsonValue shortValue]);
        
    } else if ([property.type isEqualToString:@"l"] && [jsonValue respondsToSelector:@selector(longValue)]) {
        ((void(*)(id,SEL,long))(void*)objc_msgSend)(self, setterSEL, [jsonValue longValue]);
        
    } else if ([property.type isEqualToString:@"q"] && [jsonValue respondsToSelector:@selector(longLongValue)]) {
        ((void(*)(id,SEL,long long))(void*)objc_msgSend)(self, setterSEL, [jsonValue longLongValue]);
        
    } else if ([property.type isEqualToString:@"C"] && [jsonValue respondsToSelector:@selector(unsignedCharValue)]) {
        ((void(*)(id,SEL,unsigned char))(void*)objc_msgSend)(self, setterSEL, [jsonValue unsignedCharValue]);
        
    } else if ([property.type isEqualToString:@"I"] && [jsonValue respondsToSelector:@selector(unsignedIntValue)]) {
        ((void(*)(id,SEL,unsigned int))(void*)objc_msgSend)(self, setterSEL, [jsonValue unsignedIntValue]);
        
    } else if ([property.type isEqualToString:@"S"] && [jsonValue respondsToSelector:@selector(unsignedShortValue)]) {
        ((void(*)(id,SEL,unsigned short))(void*)objc_msgSend)(self, setterSEL, [jsonValue unsignedShortValue]);
        
    } else if ([property.type isEqualToString:@"L"] && [jsonValue respondsToSelector:@selector(unsignedLongValue)]) {
        ((void(*)(id,SEL,unsigned long))(void*)objc_msgSend)(self, setterSEL, [jsonValue unsignedLongValue]);
        
    } else if ([property.type isEqualToString:@"Q"] && [jsonValue respondsToSelector:@selector(unsignedLongLongValue)]) {
        ((void(*)(id,SEL,unsigned long long))(void*)objc_msgSend)(self, setterSEL, [jsonValue unsignedLongLongValue]);
        
    } else if ([property.type isEqualToString:@"f"] && [jsonValue respondsToSelector:@selector(floatValue)]) {
        ((void(*)(id,SEL,float))(void*)objc_msgSend)(self, setterSEL, [jsonValue floatValue]);
        
    } else if ([property.type isEqualToString:@"d"] && [jsonValue respondsToSelector:@selector(doubleValue)]) {
        ((void(*)(id,SEL,double))(void*)objc_msgSend)(self, setterSEL, [jsonValue doubleValue]);
        
    } else if ([property.type isEqualToString:@"B"] && [jsonValue respondsToSelector:@selector(boolValue)]) {
        ((void(*)(id,SEL,bool))(void*)objc_msgSend)(self, setterSEL, [jsonValue boolValue]);
        
    } else if ([property.type isEqualToString:@"NSString"] || [property.type isEqualToString:@"NSMutableString"]) {
        [self setJSONValue:jsonValue withStringProperty:property setterSEL:setterSEL];
    
    } else if ([property.type isEqualToString:@"NSDate"]) {
        [self setJSONValue:jsonValue withDateProperty:property setterSEL:setterSEL];
        
    } else if (([property.type isEqualToString:@"NSArray"] || [property.type isEqualToString:@"NSMutableArray"]) && [jsonValue isKindOfClass:[NSArray class]]) {
        [self setJSONValue:jsonValue withArrayProperty:property setterSEL:setterSEL];
        
    } else if (([property.type isEqualToString:@"NSDictionary"] || [property.type isEqualToString:@"NSMutableDictionary"]) && [jsonValue isKindOfClass:[NSDictionary class]]) {
        [self setJSONValue:jsonValue withDictionaryProperty:property setterSEL:setterSEL];
        
    } else {
        //property.type 是自定义的类
        Class cls = objc_getClass([property.type UTF8String]);
        if (cls && [jsonValue isKindOfClass:[NSDictionary class]]) {
            id object = [[cls alloc] initWithJSON:jsonValue];
            ((void(*)(id,SEL,id))(void*)objc_msgSend)(self, setterSEL, object);
        }
    }
}

- (void)setJSONValue:(id)jsonValue withStringProperty:(PYLModelProperty *)property setterSEL:(SEL)setterSEL {
    NSString *str;
    if ([jsonValue isKindOfClass:[NSString class]]) {
        str = jsonValue;
    } else if ([jsonValue isKindOfClass:[NSNumber class]]) {
        str = [jsonValue stringValue];
    }
    if (str) {
        ((void(*)(id,SEL,id))(void*)objc_msgSend)(self, setterSEL, [str mutableCopy]);
    }
}

- (void)setJSONValue:(id)jsonValue withDateProperty:(PYLModelProperty *)property setterSEL:(SEL)setterSEL {
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
        ((void(*)(id,SEL,id))(void*)objc_msgSend)(self, setterSEL, date);
    }
}

- (void)setJSONValue:(id)jsonValue withArrayProperty:(PYLModelProperty *)property setterSEL:(SEL)setterSEL {
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
                ((void(*)(id,SEL,id))(void*)objc_msgSend)(self, setterSEL, tmpArray);
            }
        } else {
            NSLog(@"元素类型也应该继承 PYLModel %s", __func__);
        }
    } else {
        //直接赋值
        ((void(*)(id,SEL,id))(void*)objc_msgSend)(self, setterSEL, [jsonValue mutableCopy]);
    }
}

- (void)setJSONValue:(id)jsonValue withDictionaryProperty:(PYLModelProperty *)property setterSEL:(SEL)setterSEL {
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
                ((void(*)(id,SEL,id))(void*)objc_msgSend)(self, setterSEL, tmpDict);
            }
        } else {
            NSLog(@"元素类型也应该继承 PYLModel %s", __func__);
        }
    } else {
        //直接赋值
        ((void(*)(id,SEL,id))(void*)objc_msgSend)(self, setterSEL, [jsonValue mutableCopy]);
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

@end
