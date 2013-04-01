//
//  SimpleFacebookRequest.m
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
//  Created by Paul Sholtz on 2/27/13.
//

#import "SimpleFacebook.h"
#import "SimpleFacebookRequest.h"
#import "SimpleOperation.h"

@implementation SimpleFacebookRequest

+ (NSURLRequest*)loginRequestWithAPIKey:(NSString*)key {
    NSString *path = [kSimpleFacebookLoginURL stringByAppendingString:key];
    NSURL *url = [NSURL URLWithString:path];
    return [[NSURLRequest alloc] initWithURL:url];
}

+ (NSURLRequest*)postRequest:(SimpleOperation*)op token:(NSString*)token {
    // Extract arguments
    NSString *text = op.text;
    NSString *url = op.url;
    NSArray *images = op.images;
    if ( url != nil ) {
        text = [NSString stringWithFormat:@"%@ %@", text, url];
    }
    
    // Construct the request
    NSDictionary *params = @{@"message":text, @"access_token": token};
    NSString *boundary = @"AEAEAEAEAEAEAEAEAEAJKHGJKBJHBJHHGFGHVCHGVHGVGFDDFSXFDGCHGVJHBJHVHGCVHG";
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:@"POST"];
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request setValue:contentType forHTTPHeaderField: @"Content-Type"];
    NSMutableData *body = [NSMutableData data];
    [params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", obj] dataUsingEncoding:NSUTF8StringEncoding]];
    }];
    
    // Image Data here
    if ( images != nil ) {
        for ( int i=0; i < images.count; ++i ) {
            NSData *imageData = UIImageJPEGRepresentation([images objectAtIndex:i], 1.0);
            NSString *tagName = [NSString stringWithFormat:@"picture%d",i]; // was @"picture"
            NSString *imageName = [NSString stringWithFormat:@"image%d.jpg",i];
            if ( imageData ) {
                [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", tagName, imageName] dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
                [body appendData:imageData];
                [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    NSString *postLength = [NSString stringWithFormat:@"%d", [body length]];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    request.URL = [NSURL URLWithString:(images) ? kSimpleFacebookPostImage : kSimpleFacebookPostText];
    
    return request;
}

@end
