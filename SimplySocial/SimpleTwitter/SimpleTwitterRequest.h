//
//  Request.h
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
//  Created by Paul Sholtz on 3/21/13.
//

@class OAuth; 

@class SimpleOperation;

@interface SimpleTwitterRequest : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL           *url;
@property (nonatomic, strong) NSString        *requestMethod;
@property (nonatomic, strong) NSError         *error;
@property (nonatomic, assign) int              responseStatusCode;
@property (nonatomic, strong) NSString        *responseStatusMessage;
@property (nonatomic, strong) NSString        *responseString;
@property (nonatomic, strong) NSMutableData   *responseData;
@property (nonatomic, strong) NSURLConnection *urlConnection;

// Static Methods
+ (NSURLRequest*)loginRequestWithOAuth:(OAuth*)oauth;
+ (NSURLRequest*)postRequest:(SimpleOperation*)op oauth:(OAuth*)oauth;
+ (id)requestWithURL:(NSURL *)newURL;

// Instance Methods
- (id)initWithURL:(NSURL *)newURL;
- (void)addRequestHeader:(NSString *)header value:(NSString *)value;
- (void)startSynchronous;

@end
