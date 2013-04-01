//
//  SimplySocialTests.m
//  SimplySocialTests
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without restriction,
//  including without limitation the rights to use, copy, modify, merge,
//  publish, distribute, sublicense, and/or sell copies of the Software,
//  and to permit persons to whom the Software is furnished to do so,
//  subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//  Created by Paul Sholtz on 2/26/13.
//

#import "SimplySocialTests.h"

#import "SimpleHeaders.h"
#import "SimpleOperation.h"
#import "SimpleQueue.h"

#import "Base64.h"
#import "NSString+URLEncoding.h"

#define _kSIMPLE_LABEL_QUEUE_CHECK_SIZE                 @"[Check Queue -> Size]"
#define _kSIMPLE_LABEL_QUEUE_CHECK_PEEK                 @"[Check Queue -> Peek]"
#define _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE              @"[Check Queue -> Dequeue]"
#define _kSIMPLE_LABEL_QUEUE_CHECK_FAST_ENUMERATION     @"[Check Queue -> NSFastEnumeration]"

#define _kSIMPLE_LABEL_OPERATION_CHECK_READY            @"[Check Operation -> Ready]"
#define _kSIMPLE_LABEL_OPERATION_CHECK_KIND             @"[Check Operation -> Kind]"
#define _kSIMPLE_LABEL_OPERATION_CHECK_TEXT             @"[Check Operation -> Text]"
#define _kSIMPLE_LABEL_OPERATION_CHECK_IMAGE            @"[Check Operation -> Image]"

#define _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY         @"[Check Functions -> IsEmpty]"
#define _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY    @"[Check Functions -> isNSStringEmpty]"

#define _kSIMPLE_LABEL_BASE64_DATA_1_CHECK              @"[Check Base64] -> NSData+dataWithBase64EncodedString"
#define _kSIMPLE_LABEL_BASE64_DATA_2_CHECK              @"[Check Base64] -> NSData+base64EncodedString"
#define _kSIMPLE_LABEL_BASE64_STRING_1_CHECK            @"[Check Base64] -> NSString+stringWithBase64EncodedString"
#define _kSIMPLE_LABEL_BASE64_STRING_2_CHECK            @"[Check Base64] -> NSString+base64EncodedString"
#define _kSIMPLE_LABEL_BASE64_STRING_3_CHECK            @"[Check Base64] -> NSString+base64DecodedString"

#define _kSIMPLE_LABEL_URLENCODING_STRING_CHECK         @"[Check URLEncoding] -> NSString+URLEncoding"

@implementation SimplySocialTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

#pragma mark -
#pragma mark Test Queues
// Test the "enqueueObj" method 
- (void)testQueue1
{
    // start the queue
    SimpleQueue *queue = [[SimpleQueue alloc] init];
    STAssertEquals(0, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);

    // we have one objs
    [queue enqueueObj:@"one"];
    STAssertEquals(1, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // we have two objs
    [queue enqueueObj:@"two"];
    STAssertEquals(2, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // only have one left!
    STAssertEqualObjects(@"one", [queue peekObj], _kSIMPLE_LABEL_QUEUE_CHECK_PEEK);
    STAssertEqualObjects(@"one", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEquals(1, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // add on two more
    [queue enqueueObj:@"three"];
    [queue enqueueObj:@"four"];
    STAssertEquals(3, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // dequeue all remaining objs
    STAssertEqualObjects(@"two", [queue peekObj], _kSIMPLE_LABEL_QUEUE_CHECK_PEEK);
    STAssertEqualObjects(@"two", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEqualObjects(@"three", [queue peekObj], _kSIMPLE_LABEL_QUEUE_CHECK_PEEK);
    STAssertEqualObjects(@"three", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEquals(1, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    STAssertEqualObjects(@"four", [queue peekObj], _kSIMPLE_LABEL_QUEUE_CHECK_PEEK);
    STAssertEqualObjects(@"four", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEquals(0, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // pop just one more time, to test
    STAssertEqualObjects(nil, [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEquals(0, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
}

// Test the "enqueueObjects" method
- (void)testQueue2
{
    // start the queue
    SimpleQueue *queue = [[SimpleQueue alloc] init];
    STAssertEquals(0, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // add an entire array
    NSArray *objs = [NSArray arrayWithObjects:@"one", @"two", @"three", @"four", nil];
    [queue enqueueObjects:objs];
    STAssertEquals(4, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // dequeue some objs
    STAssertEqualObjects(@"one", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEqualObjects(@"two", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEqualObjects(@"three", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEquals(1, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // add some more objs
    [queue enqueueObj:@"five"];
    [queue enqueueObj:@"six"];
    STAssertEquals(3, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // dequeue everything
    STAssertEqualObjects(@"four", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEqualObjects(@"five", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEqualObjects(@"six", [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEquals(0, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // pop just one more time, to test
    STAssertEqualObjects(nil, [queue dequeueObj], _kSIMPLE_LABEL_QUEUE_CHECK_DEQUEUE);
    STAssertEquals(0, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
}

// Test the fast enumeration feature
- (void)testQueue3
{
    // start the queue
    SimpleQueue *queue = [[SimpleQueue alloc] init];
    STAssertEquals(0, queue.size, _kSIMPLE_LABEL_QUEUE_CHECK_SIZE);
    
    // add an entire array
    NSArray *objs = [NSArray arrayWithObjects:@"one", @"two", @"three", @"four", @"five", @"six", nil];
    [queue enqueueObjects:objs];
    
    // test the fast enumeration
    int count = 0;
    for ( id obj in queue ) {
        switch ( count ) {
            case 0:
                STAssertEqualObjects(@"one", obj, _kSIMPLE_LABEL_QUEUE_CHECK_FAST_ENUMERATION);
                break;
            case 1:
                STAssertEqualObjects(@"two", obj, _kSIMPLE_LABEL_QUEUE_CHECK_FAST_ENUMERATION);
                break;
            case 2:
                STAssertEqualObjects(@"three", obj, _kSIMPLE_LABEL_QUEUE_CHECK_FAST_ENUMERATION);
                break;
            case 3:
                STAssertEqualObjects(@"four", obj, _kSIMPLE_LABEL_QUEUE_CHECK_FAST_ENUMERATION);
                break;
            case 4:
                STAssertEqualObjects(@"five", obj, _kSIMPLE_LABEL_QUEUE_CHECK_FAST_ENUMERATION);
                break;
            case 5:
                STAssertEqualObjects(@"six", obj, _kSIMPLE_LABEL_QUEUE_CHECK_FAST_ENUMERATION);
                break;
        }
        count++;
    }
}

#pragma mark -
#pragma mark Test Operations
// Check the "isEmpty" Macro
- (void)testFunctions1 {
    STAssertTrue(isEmpty(nil), _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY);
    STAssertTrue(isEmpty([NSNull null]), _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY);
    STAssertTrue(isEmpty([[NSData alloc] init]), _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY);
    STAssertTrue(isEmpty(@""), _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY);
    STAssertFalse(isEmpty(@" "), _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY);  // <- this is the use case that we designed isNSStringEmpty for
    STAssertFalse(isEmpty(@"  "), _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY); // <- this is the use case that we designed isNSStringEmpty for
    STAssertFalse(isEmpty(@"test"), _kSIMPLE_LABEL_FUNCTION_CHECK_OBJ_EMPTY);
}

// Check the "isNSStringEmpty" Macro
- (void)testFunctions2 {
    STAssertTrue(isNSStringEmpty(@""), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertTrue(isNSStringEmpty(@" "), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertTrue(isNSStringEmpty(@"  "), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertTrue(isNSStringEmpty(@"\t"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertTrue(isNSStringEmpty(@"\n"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertTrue(isNSStringEmpty(@"\r"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertTrue(isNSStringEmpty(@"\r\n"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertTrue(isNSStringEmpty(@" \t\r\n"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertFalse(isNSStringEmpty(@"test"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertFalse(isNSStringEmpty(@"  test  "), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertFalse(isNSStringEmpty(@"test this"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertFalse(isNSStringEmpty(@"  test this  "), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertFalse(isNSStringEmpty(@"x"), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
    STAssertFalse(isNSStringEmpty(@"  x  "), _kSIMPLE_LABEL_FUNCTION_CHECK_NSSTRING_EMPTY);
}

// NSData 1 (Base64)
- (void)testBase64_1 {
    // test
    NSString *sample1a = @"dGVzdA==";
    NSData *data1 = [NSData dataWithBase64EncodedString:sample1a];
    NSString *sample1b = [[NSString alloc] initWithData:data1 encoding:NSASCIIStringEncoding];
    STAssertEqualObjects(@"test", sample1b, _kSIMPLE_LABEL_BASE64_DATA_1_CHECK);
    
    //this is a test
    NSString *sample2a = @"dGhpcyBpcyBhIHRlc3Q=";
    NSData *data2 = [NSData dataWithBase64EncodedString:sample2a];
    NSString *sample2b = [[NSString alloc] initWithData:data2 encoding:NSASCIIStringEncoding];
    STAssertEqualObjects(@"this is a test", sample2b, _kSIMPLE_LABEL_BASE64_DATA_1_CHECK);
}

// NSData 2 (Base64) 
- (void)testBase64_2 {
    // test
    NSString *test1a = @"test";
    NSData *data1a = [test1a dataUsingEncoding:NSASCIIStringEncoding];
    NSString *test1b = [data1a base64EncodedString];
    NSData *data1b = [NSData dataWithBase64EncodedString:test1b];
    NSString *test1c = [[NSString alloc] initWithData:data1b encoding:NSASCIIStringEncoding];
    STAssertEqualObjects(test1a, test1c, _kSIMPLE_LABEL_BASE64_DATA_2_CHECK);
    
    // this is a test
    NSString *test2a = @"this is a test";
    NSData *data2a = [test2a dataUsingEncoding:NSASCIIStringEncoding];
    NSString *test2b = [data2a base64EncodedString];
    NSData *data2b = [NSData dataWithBase64EncodedString:test2b];
    NSString *test2c = [[NSString alloc] initWithData:data2b encoding:NSASCIIStringEncoding];
    STAssertEqualObjects(test2a, test2c, _kSIMPLE_LABEL_BASE64_DATA_2_CHECK);
}

// NSString 1 (Base64)
- (void)testBase64_3 {
    //test
    NSString *sample1a = @"dGVzdA==";
    NSString *sample1b = [NSString stringWithBase64EncodedString:sample1a];
    STAssertEqualObjects(@"test", sample1b, _kSIMPLE_LABEL_BASE64_STRING_1_CHECK);
    
    //this is a test
    NSString *sample2a = @"dGhpcyBpcyBhIHRlc3Q=";
    NSString *sample2b = [NSString stringWithBase64EncodedString:sample2a];
    STAssertEqualObjects(@"this is a test", sample2b, _kSIMPLE_LABEL_BASE64_STRING_1_CHECK);
}

// NSString 2 (Base64)
- (void)testBase64_4 {
    //test
    NSString *sample1a = @"test";
    NSString *sample1b = @"dGVzdA==";
    STAssertEqualObjects(sample1b, [sample1a base64EncodedString], _kSIMPLE_LABEL_BASE64_STRING_2_CHECK);
    
    //this is a test
    NSString *sample2a = @"this is a test";
    NSString *sample2b = @"dGhpcyBpcyBhIHRlc3Q=";
    STAssertEqualObjects(sample2b, [sample2a base64EncodedString], _kSIMPLE_LABEL_BASE64_STRING_2_CHECK);
}

// NSString 3 (Base64)
- (void)testBase64_5 {
    //test
    NSString *sample1a = @"test";
    NSString *sample1b = @"dGVzdA==";
    STAssertEqualObjects(sample1a, [sample1b base64DecodedString], _kSIMPLE_LABEL_BASE64_STRING_3_CHECK);
    
    //this is a test
    NSString *sample2a = @"this is a test";
    NSString *sample2b = @"dGhpcyBpcyBhIHRlc3Q=";
    STAssertEqualObjects(sample2a, [sample2b base64DecodedString], _kSIMPLE_LABEL_BASE64_STRING_3_CHECK);
}

// NSString1 (URLEncoding)
- (void)testURLEncoding1 {
    // test
    NSString *sample1a = @"\"Aardvarks lurk, OK?\"";
    NSString *sample1b = @"%22Aardvarks%20lurk,%20OK%3F%22";
    NSString *sample1c = @"%22Aardvarks%20lurk%2C%20OK%3F%22";
    
    STAssertEqualObjects([sample1a encodedURLString], sample1b, _kSIMPLE_LABEL_URLENCODING_STRING_CHECK);
    STAssertEqualObjects([sample1a encodedURLParameterString], sample1c, _kSIMPLE_LABEL_URLENCODING_STRING_CHECK);
    STAssertEqualObjects([sample1b decodedURLString], sample1a, _kSIMPLE_LABEL_URLENCODING_STRING_CHECK);
    STAssertEqualObjects([sample1c decodedURLString], sample1a, _kSIMPLE_LABEL_URLENCODING_STRING_CHECK);
}

@end
