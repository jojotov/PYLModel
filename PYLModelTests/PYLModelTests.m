//
//  PYLModelTests.m
//  PYLModelTests
//
//  Created by yulei pang on 2019/1/29.
//  Copyright © 2019 pangyulei. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Book.h"
#import "Author.h"
#import "ajiojesad.h"

@interface PYLModelTests : XCTestCase

@end

@implementation PYLModelTests

- (void)testExample {
    NSDictionary *bookJSON = @{
                               @"isSoldOut":@0,
                               @"isOkForKid":@"trUe",
                               @"id": @1,
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
                                       }
                               };
    Book *aBook = [[Book alloc] initWithJSON:bookJSON];
    XCTAssert(aBook.bookID == 1);
    XCTAssert(sizeof(aBook.bookID) == sizeof(long long));
    XCTAssertNil(aBook.name);
    XCTAssert(aBook.created.timeIntervalSince1970 == 190429809);
    XCTAssert(aBook.updated.timeIntervalSince1970 == 1548691200);
    XCTAssert(aBook.previews.count == 2);
    XCTAssert([aBook.previews[0] isKindOfClass:[NSString class]]);
    XCTAssert(aBook.authors.count == 2);
    Author *author = aBook.authors[0];
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
}


@end
