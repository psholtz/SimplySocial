//
//  SimpleQueue.m
//  SimplySocial
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

#import "SimpleQueue.h"

#pragma mark -
#pragma mark Private Interface
@interface SimpleQueue()

@property (nonatomic, strong) NSMutableArray *queue;

- (void)configure:(NSArray*)array;

@end

#pragma mark -
#pragma mark Implementation
@implementation SimpleQueue

// Constructors
#pragma mark -
#pragma mark Constructors
- (id)init {
    self = [super init];
    if ( self ) {
        [self configure:nil];
    }
    return self;
}

- (id)initWithArray:(NSArray*)array {
    self = [super init];
    if ( self ) {
        [self configure:array];
    }
    return self;
}

- (void)configure:(NSArray*)array {
    _queue = [[NSMutableArray alloc] initWithArray:array];
}

// Stack operations
#pragma mark -
#pragma mark Stack Operations
- (void)enqueueObj:(id)obj {
    if ( obj ) {
        [_queue addObject:obj];
    }
}

- (void)enqueueObjects:(NSArray*)array {
    for ( id obj in array ) {
        if ( obj ) {
            [_queue addObject:obj];
        }
    }
}

- (id)dequeueObj {
    if ( _queue.count > 0 ) {
        id obj = [_queue objectAtIndex:0];
        [_queue removeObjectAtIndex:0];
        return obj;
    }
    return nil;
}

- (id)peekObj {
    if ( _queue.count > 0 ) {
        return [_queue objectAtIndex:0];
    }
    return nil;
}

- (void)clear {
    if ( _queue.count > 0 ) {
        [_queue removeAllObjects];
    }
}

// Size
- (int)size {
    return [_queue count];
}

#pragma mark -
#pragma mark NSFastEnumeration
// Not really necessary, but fun to have
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
    return [_queue countByEnumeratingWithState:state objects:buffer count:len];
}

@end
