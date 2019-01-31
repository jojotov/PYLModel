//
//  PYLModel+JSON.h
//  PYLModel
//
//  Created by yulei pang on 2019/1/31.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import "PYLModel.h"



@interface PYLModel (JSON)
- (instancetype)initWithJSON:(NSDictionary *)json;
- (NSDictionary<NSString *, NSString *> *)propertyName_jsonKey_mapper;
- (NSDictionary<NSString *, NSString *> *)propertyName_dateFormat_mapper;

/*
 * 当要给数组或字典类型赋值时，会查询这个mapper有没有指明元素的class，如果有，会把元素转成相应class,如果没有，字典或数组会直接赋值给self
 */
- (NSDictionary<NSString *, Class> *)propertyName_elementClass_mapper;
@end

