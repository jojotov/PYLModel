//
//  TestJSON.m
//  PYLModelTests
//
//  Created by yulei pang on 2019/1/31.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Book.h"
#import "Author.h"
#import "PYLModel+JSON.h"

@interface TestJSON : XCTestCase

@end

@implementation TestJSON

- (void)testExample {
    NSDictionary *bookJSON = @{
                               @"salary":@30000,
                               @"sign":@('e'),
                               @"isSoldOut":@0,
                               @"isOkForKid":@"trUe",
                               @"id": @999999999999999999,
                               @"testShort": @([@2 shortValue]),
                               @"name":[NSNull null],
                               @"created_at": @190429809,
                               @"updated_at": @"2019-01-29",
                               @"previews":@[
                                       @"url1",
                                       @"url2"
                                       ],
                               @"authors": @[
                                       @{
                                           @"name":@"john",
                                           @"age":@27
                                           },
                                       @{
                                           @"name":@"jack",
                                           @"age":@"25"
                                           }
                                       ],
                               @"singleAuthor": @{
                                       @"name":@"smith",
                                       @"age":@30
                                       },
                               @"extraAuthDict":@{
                                       @"blacklist":@{
                                               @"name":@"lucy",
                                               @"age":@"18"
                                               }
                                       }
                               };
    Book *aBook = [[Book alloc] initWithJSON:bookJSON];
    
    [aBook setValue:@"asjoeijoae" forKey:@"key_not_exist"];
    
    XCTAssert(aBook.bookID == 999999999999999999);
    XCTAssert(aBook.testShort == 2);
    XCTAssert(sizeof(aBook.bookID) == sizeof(long long));
    XCTAssertNil(aBook.name);
    XCTAssert(aBook.created.timeIntervalSince1970 == 190429809);
    XCTAssert(aBook.updated.timeIntervalSince1970 == 1548691200);
    
    XCTAssert([aBook.salary isEqualToString:@"30000"]);
    XCTAssert([aBook.salary isKindOfClass:[NSString class]]);
    
    XCTAssert([aBook.extraAuthDict respondsToSelector:@selector(setObject:forKey:)]);
    Author *author = aBook.extraAuthDict[@"blacklist"];
    XCTAssert([author isKindOfClass:[Author class]]);
    XCTAssert([author.name isEqualToString:@"lucy"]);
    XCTAssert(author.age == 18);
    
    XCTAssert(aBook.previews.count == 2);
    XCTAssert([aBook.previews[0] isKindOfClass:[NSString class]]);
    XCTAssert([aBook.previews isKindOfClass:[NSArray class]]);
    
    XCTAssert(aBook.authors.count == 2);
    XCTAssert([aBook.authors respondsToSelector:@selector(removeObjectAtIndex:)]);
    
    author = aBook.authors[0];
    XCTAssert([author isKindOfClass:[Author class]]);
    XCTAssert([author.name isEqualToString:@"john"]);
    XCTAssert(author.age == 27);
    
    author = aBook.single;
    XCTAssert([author.name isEqualToString:@"smith"]);
    XCTAssert(author.age == 30);
    
    author = aBook.authors[1];
    XCTAssert([author.name isEqualToString:@"jack"]);
    XCTAssert(author.age == 25);
    
    XCTAssert(aBook.isSoldOut == false);
    XCTAssert(aBook.isOkForKid == YES);
    XCTAssert(aBook.sign == 'e');
}

@end
