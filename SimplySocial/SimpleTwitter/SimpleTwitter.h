//
//  SimpleTwitter.h
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

#import "SimplySocial.h"
#import "SimpleHeaders.h"

#warning Don't forget to set your API Key, Secret and Callback URL!
#define _kSIMPLE_TWITTER_CONSUMER_KEY               @""
#define _kSIMPLE_TWITTER_CONSUMER_SECRET            @""
#define _kSIMPLE_TWITTER_CALLBACK_URL               @""
#define _kSIMPLE_TWITTER_DEBUG                      0
#define _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE    0

#define kSimpleTwitterHost                          @"api.twitter.com"
#define kSimpleTwitterAuthorizeURL                  @"http://api.twitter.com/oauth/authorize"
#define kSimpleTwitterTextPostURL                   @"https://api.twitter.com/1.1/statuses/update.json"
#define kSimpleTwitterTextAndImagePostURL           @"https://api.twitter.com/1.1/statuses/update_with_media.json"
#define kSimpleTwitterOAuthTokenKey                 @"oauth_token"
#define kSimpleTwitterOAuthVerifierKey              @"oauth_verifier="
#define kSimpleTwitterTimeout                       30

// Users can redefine these as desired
#define kSimpleTwitterAlertTitle                    @"Twitter"
#define kSimpleTwitterAlertLoginFail                @"Could not load login screen."
#define kSimpleTwitterAlertPostSuccess              @"Tweet Successful!"
#define kSimpleTwitterAlertPostFail                 @"Tweet failed, please try again later."
#define kSimpleTwitterAlertNoService                @"Twitter service is not available, make sure your device has an Internet connection and you have at least one Twitter account setup."

#define kSimpleTwitterExceptionAPITitle             @"SimpleTwitter: Null API Exception"
#define kSimpleTwitterExceptionAPIMsg               @"Please furnish a consumer key, a consumer secret and a callback URL!"

#pragma mark -
#pragma mark Protocol
@protocol SimpleTwitterDelegate <NSObject>

// The delegate "should" be an instance of UIViewController, or a delegate thereto.
// This allows us to display login view controllers in the delegate's frame
@required
- (UIViewController*)targetViewController;

// Option callbacks informing delegate of Twitter state
@optional
- (void)simpleTwitterDidLogin:(id)sender;
- (void)simpleTwitterDidFail:(id)sender withHeaders:(NSDictionary*)headers;
- (void)simpleTwitterDidPost:(id)sender;
- (void)simpleTwitterDidCancel:(id)sender;

@end

#pragma mark -
#pragma mark Interface
@interface SimpleTwitter : SimplySocial <NSURLConnectionDelegate>

@property (nonatomic, SIMPLE_WEAK) id <SimpleTwitterDelegate> delegate;
@property (nonatomic, assign) BOOL cacheToken;
@property (nonatomic, assign) BOOL optimize;

// Constructors
- (id)init;
- (id)initWithAPIKey:(NSString*)apiKey andSecret:(NSString*)secret andCallbackURL:(NSString*)callbackURL;

// Twitter Interface
- (void)postText:(NSString*)text;
- (void)postText:(NSString*)text withImage:(UIImage*)image;
- (void)postText:(NSString*)text withURL:(NSString*)url;
- (void)postText:(NSString*)text withImage:(UIImage*)image andURL:(NSString*)url;

// Terminate Session
- (void)cancel;

@end
