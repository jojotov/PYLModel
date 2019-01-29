//
//  PYLModel.h
//  PYLModel
//
//  Created by yulei pang on 2019/1/29.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PYLModel : NSObject
- (instancetype)initWithJSON:(NSDictionary *)json;
- (NSDictionary<NSString *, NSString *> *)propertyName_jsonKey_mapper;
- (NSDictionary<NSString *, NSString *> *)propertyName_dateFormat_mapper;
- (NSDictionary<NSString *, Class> *)propertyName_elementClass_mapper; //标明容器类型，Array, MutableArray 的元素 class，如果不标明，就不会对自定义的元素类做转换
@end

