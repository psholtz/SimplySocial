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

#import <Foundation/Foundation.h>

#import "SimplySocial.h"
#import "SimpleHeaders.h"

#pragma mark - Defines

#warning Don't forget to set your API Key!
#define _kSIMPLE_FACEBOOK_API_KEY                   @""
#define _kSIMPLE_FACEBOOK_DEBUG                     0
#define _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE   0

#define kSimpleFacebookLoginURL                     @"https://m.facebook.com/dialog/oauth?type=user_agent&display=touch&redirect_uri=fbconnect%3A%2F%2Fsuccess&sdk=ios&scope=publish_stream&client_id="
#define kSimpleFacebookPostText                     @"https://graph.facebook.com/me/feed"
#define kSimpleFacebookPostImage                    @"https://graph.facebook.com/me/photos"

// Users can redefine these as desired
#define kSimpleFacebookAlertTitle                   NSLocalizedString(@"Facebook", nil)
#define kSimpleFacbeookAlertLoginFail               NSLocalizedString(@"Could not load login screen.", nil)
#define kSimpleFacebookAlertPostSuccess             NSLocalizedString(@"Post Successful!", nil)
#define kSimpleFacebookAlertPostFail                NSLocalizedString(@"Post failed, please try again later.", nil)
#define kSimpleFacebookAlertNoService               NSLocalizedString(@"Facebook Service is not available, make sure your device has an Internet connection and you have at least one Twitter account setup.", nil)
#define kSimpleFacebookExceptionAPITitle            NSLocalizedString(@"SimpleFacebook: Null API Exception", nil)
#define kSimpleFacebookExceptionAPIMsg              NSLocalizedString(@"Please furnish an API key!", nil)

#pragma mark - SimpleFacebook Protocol

@protocol SimpleFacebookDelegate <NSObject>

#pragma mark - Required 

// The delegate "should" be an instance of UIViewController, or a delegate thereto.
// This allows us to display login view controllers in the delegate's frame
@required
- (UIViewController*)targetViewController;

#pragma mark - Optional 

// Option callbacks informing delegate of FB state
@optional
- (void)simpleFacebookDidLogin:(id)sender;
- (void)simpleFacebookDidFail:(id)sender withHeaders:(NSDictionary*)headers;
- (void)simpleFacebookDidPost:(id)sender;
- (void)simpleFacebookDidCancel:(id)sender;

@end

#pragma mark - Class Interface

@interface SimpleFacebook : SimplySocial <NSURLConnectionDelegate>

#pragma mark - Properties

@property (nonatomic, SIMPLE_WEAK) id <SimpleFacebookDelegate> delegate;
@property (nonatomic, assign) BOOL cacheToken;      // Do we save access tokens and reuse the ViewController?
@property (nonatomic, assign) BOOL optimize;        // Setting to TRUE makes things easier for client
@property (nonatomic, readonly) BOOL preloading;    // Returns TRUE when the "Loading.." HUD is onscreen

#pragma mark - Constructors

// Constructors
- (id)init;
- (id)initWithAPIKey:(NSString*)apiKey;

#pragma mark - Facebook Interface 

// FB Interface
- (void)postText:(NSString*)text;
- (void)postText:(NSString*)text withImage:(UIImage*)image;
- (void)postText:(NSString*)text withURL:(NSString*)url;
- (void)postText:(NSString*)text withImage:(UIImage*)image andURL:(NSString*)url;

#pragma mark - Terminate Session

// Terminate Session
- (void)cancel;

@end
