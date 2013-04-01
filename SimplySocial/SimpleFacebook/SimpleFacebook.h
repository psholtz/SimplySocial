//
//  SimpleFacebook.h
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

#import "SimplySocial.h"
#import "SimpleHeaders.h"

#warning Don't forget to set your API Key!
#define _kSIMPLE_FACEBOOK_API_KEY                   @""
#define _kSIMPLE_FACEBOOK_DEBUG                     0
#define _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE   0

#define kSimpleFacebookLoginURL                     @"https://m.facebook.com/dialog/oauth?type=user_agent&display=touch&redirect_uri=fbconnect%3A%2F%2Fsuccess&sdk=ios&scope=publish_stream&client_id="
#define kSimpleFacebookPostText                     @"https://graph.facebook.com/me/feed"
#define kSimpleFacebookPostImage                    @"https://graph.facebook.com/me/photos"

// Users can redefine these as desired
#define kSimpleFacebookAlertTitle                   @"Facebook"
#define kSimpleFacbeookAlertLoginFail               @"Could not load login screen."
#define kSimpleFacebookAlertPostSuccess             @"Post Successful!"
#define kSimpleFacebookAlertPostFail                @"Post failed, please try again later."
#define kSimpleFacebookAlertNoService               @"Facebook Service is not available, make sure your device has an Internet connection and you have at least one Twitter account setup."

#define kSimpleFacebookExceptionAPITitle            @"SimpleFacebook: Null API Exception"
#define kSimpleFacebookExceptionAPIMsg              @"Please furnish an API key!"

#pragma mark -
#pragma mark Protocol
@protocol SimpleFacebookDelegate <NSObject>

// The delegate "should" be an instance of UIViewController, or a delegate thereto.
// This allows us to display login view controllers in the delegate's frame
@required
- (UIViewController*)targetViewController;

// Option callbacks informing delegate of FB state
@optional
- (void)simpleFacebookDidLogin:(id)sender;
- (void)simpleFacebookDidFail:(id)sender withHeaders:(NSDictionary*)headers;
- (void)simpleFacebookDidPost:(id)sender;
- (void)simpleFacebookDidCancel:(id)sender;

@end

#pragma mark -
#pragma mark Interface
@interface SimpleFacebook : SimplySocial <NSURLConnectionDelegate>

@property (nonatomic, SIMPLE_WEAK) id <SimpleFacebookDelegate> delegate;
@property (nonatomic, assign) BOOL cacheToken;      // Do we save access tokens and reuse the ViewController?
@property (nonatomic, assign) BOOL optimize;        // Setting to TRUE makes things easier for client
@property (nonatomic, readonly) BOOL preloading;    // Returns TRUE when the "Loading.." HUD is onscreen

// Constructors
- (id)init;
- (id)initWithAPIKey:(NSString*)apiKey;

// FB Interface
- (void)postText:(NSString*)text;
- (void)postText:(NSString*)text withImage:(UIImage*)image;
- (void)postText:(NSString*)text withURL:(NSString*)url;
- (void)postText:(NSString*)text withImage:(UIImage*)image andURL:(NSString*)url;

// Terminate Session
- (void)cancel;

@end
