//
//  Request.m
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

#import "SimpleTwitter.h"
#import "SimpleTwitterRequest.h"
#import "SimpleOperation.h"

#import "OAuth.h"

#import "NSString+URLEncoding.h"

#pragma mark -
#pragma mark Private Interface
@interface SimpleTwitterRequest ()

@property (nonatomic, strong) NSMutableDictionary *requestHeaders;
@property (nonatomic)         BOOL requestFinished;

+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params;

@end

#pragma mark -
#pragma mark Implementation
@implementation SimpleTwitterRequest

#pragma mark -
#pragma mark Static Methods
+ (NSURLRequest*)loginRequestWithOAuth:(OAuth*)oauth {
    NSDictionary *params= @{kSimpleTwitterOAuthTokenKey : oauth.oauth_token};
    NSURL *url = [SimpleTwitterRequest generateURL:kSimpleTwitterAuthorizeURL params:params];
    
    return [NSMutableURLRequest requestWithURL:url];
}

+ (NSURLRequest*)postRequest:(SimpleOperation*)op oauth:(OAuth*)oAuth {
    // Extract arguments
    NSString *text = op.text;
    NSString *url = op.url;
    NSArray *images = op.images;
    if ( url != nil ) {
        text = [NSString stringWithFormat:@"%@ %@", text, url];
    }
    
    // Prepare content string
    NSMutableArray *array = [NSMutableArray array];
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status",@"t", @"trim_user",nil];
    for (NSString *key in [params allKeys]) {
        [array addObject:[NSString stringWithFormat:@"%@=%@", key, [(NSString *)params[key] encodedURLParameterString]]];
    }
    NSString *string = [NSString stringWithFormat:@"%@", [array componentsJoinedByString:@"&"]];
    
    // Assign the URL
    NSURL *targetURL = [NSURL URLWithString:kSimpleTwitterTextPostURL];
    if ([images count] > 0) {
        targetURL = [NSURL URLWithString:kSimpleTwitterTextAndImagePostURL];
    }
    
    // Prepare Request object
    NSString *header = nil;
    NSMutableData *data = nil;
    NSMutableURLRequest *postRequest = [NSMutableURLRequest requestWithURL:targetURL cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kSimpleTwitterTimeout];
    [postRequest setHTTPMethod:@"POST"];
    if ( [images count] > 0 ) {
        header = [oAuth oAuthHeaderForMethod:@"POST" andUrl:[targetURL absoluteString] andParams:nil];
        NSString *stringBoundary = @"dOuBlEeNcOrEbOuNdArY";
        [postRequest setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forHTTPHeaderField:@"Content-Type"];
        
        data = [NSMutableData data];
        [data appendData:[[NSString stringWithFormat:@"--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        
        for (NSString *key in [params allKeys]) {
            [data appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[[NSString stringWithFormat:@"%@", params[key]] dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
        
        for (UIImage *image in images) {
            [data appendData:[@"Content-Disposition: form-data; name=\"media[]\"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [data appendData:UIImagePNGRepresentation(image)];
            [data appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    } else {
        header = [oAuth oAuthHeaderForMethod:@"POST" andUrl:[targetURL absoluteString] andParams:params];
        [postRequest setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        data = [[string dataUsingEncoding:NSUTF8StringEncoding] mutableCopy];
        [postRequest setValue:[NSString stringWithFormat:@"%d", [data length]] forHTTPHeaderField:@"Content-Length"];
    }
    
    [postRequest setHTTPBody:data];
    [postRequest addValue:header forHTTPHeaderField:@"Authorization"];
    
    return postRequest;
}

+ (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
    if (params)
    {
        NSMutableArray* pairs = [NSMutableArray array];
        for (NSString* key in params.keyEnumerator)
        {
            NSString* value = params[key];
            NSString* escaped_value = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)value,NULL,(CFStringRef)@"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        }
        
        NSString* query = [pairs componentsJoinedByString:@"&"];
        NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
        return [NSURL URLWithString:url];
    } else {
        return [NSURL URLWithString:baseURL];
    }
}

+ (id)requestWithURL:(NSURL *)newURL {
    return [[self alloc] initWithURL:newURL];
}

#pragma mark -
#pragma mark Instance Methods
// Constructors
- (id)initWithURL:(NSURL *)newURL {
    self = [super init];
    if (self)
    {
        self.url = newURL;
        self.requestFinished = NO;
    }
    return self;
}

- (void)addRequestHeader:(NSString *)header value:(NSString *)value {
    if (!self.requestHeaders) self.requestHeaders = [NSMutableDictionary dictionary];
	(self.requestHeaders)[header] = value;
}

- (void)startSynchronous {
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:self.url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:kSimpleTwitterTimeout];
    urlRequest.HTTPMethod = self.requestMethod;
    
    [self.requestHeaders enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
         [urlRequest setValue:obj forHTTPHeaderField:key];
     }];
    
    if ([NSURLConnection canHandleRequest:urlRequest]) {
        self.urlConnection = [NSURLConnection connectionWithRequest:urlRequest delegate:self];
        [self.urlConnection start];
    }
    else {
        self.error = [NSError errorWithDomain:@"com.doubleencore.Request" code:1 userInfo:nil];
    }
    
    while (self.requestFinished == NO) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
}

#pragma mark -
#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.error = error;
    self.requestFinished = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    self.responseStatusCode = [response statusCode];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (!self.responseData) self.responseData = [NSMutableData dataWithData:data];
    else [self.responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    self.requestFinished = YES;
}

@end

