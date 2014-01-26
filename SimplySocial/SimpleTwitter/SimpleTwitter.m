//
//  SimpleTwitter.m
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
#import "SimpleTwitter+CompletionHandlers.h"
#import "SimpleTwitterLoginViewController.h"
#import "SimpleTwitterRequest.h"

#import "SimpleOperation.h"
#import "SimpleQueue.h"

#import "OAuth.h"

#import "MBProgressHUD.h"

#if _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#endif // _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE

// Used in parameter dictionary during construction
static const NSString *kParamTwitterApiKey      = @"twitterApiKey";
static const NSString *kParamTwitterSecret      = @"twitterSecret";
static const NSString *kParamTwitterCallbackURL = @"twitterCallbackURL";

#pragma mark -
#pragma mark Internal Interface
@interface SimpleTwitter () <SimpleTwitterLoginViewControllerDelegate, OAuthTwitterCallbacks>

@property (nonatomic, strong) SimpleQueue *queue;
@property (nonatomic, strong) OAuth *oAuth;
@property (nonatomic, strong) NSString *callbackURL;
@property (nonatomic, strong) SimpleTwitterLoginViewController *login;

// Supporting methods
- (void)configure:(NSDictionary*)params;
- (void)prepareLoginViewController;
- (void)presentLoginViewController;
- (void)processQueue;
- (void)process:(SimpleOperation*)op;
- (void)dismissLoginViewController;

// Actual "work" method
- (void)prepareTwitterPost:(NSString*)text withImages:(NSArray*)images withURL:(NSString*)url;
- (void)performNativeTwitterPost:(NSString*)text withImages:(NSArray*)images withURL:(NSString*)url kind:(kSimpleSocialIOSKind)kind;
- (void)performSimpleTwitterPost:(NSString*)text withImages:(NSArray*)images withURL:(NSString*)url;

@end

@implementation SimpleTwitter

// ------------
// Constructors
// ------------
- (id)init {
    self = [super init];
    if ( self ) {
        NSDictionary *params = @{
            kParamTwitterApiKey: _kSIMPLE_TWITTER_CONSUMER_KEY,
            kParamTwitterSecret : _kSIMPLE_TWITTER_CONSUMER_SECRET,
            kParamTwitterCallbackURL : _kSIMPLE_TWITTER_CALLBACK_URL,
        };
        [self configure:params];
    }
    return self;
}

- (id)initWithAPIKey:(NSString *)apiKey andSecret:(NSString *)secret andCallbackURL:(NSString*)callbackURL {
    self = [super init];
    if ( self ) {
        NSDictionary *params = @{
            kParamTwitterApiKey: apiKey,
            kParamTwitterSecret : secret,
            kParamTwitterCallbackURL : callbackURL,
        };
        [self configure:params];
    }
    return self;
}

- (void)configure:(NSDictionary *)params {
    self.queue = [[SimpleQueue alloc] init];
    self.oAuth = [[OAuth alloc] initWithConsumerKey:[params objectForKey:kParamTwitterApiKey]
                                  andConsumerSecret:[params objectForKey:kParamTwitterSecret]];
    self.callbackURL = [params objectForKey:kParamTwitterCallbackURL];
    self.oAuth.delegate = self;
    self.cacheToken = FALSE;
    self.optimize = TRUE;
}

// -----------------
// Twitter Interface
// -----------------
- (void)postText:(NSString *)text {
    [self prepareTwitterPost:text withImages:nil withURL:nil];
}

- (void)postText:(NSString *)text withImage:(UIImage *)image {
    [self prepareTwitterPost:text withImages:[NSArray arrayWithObject:image] withURL:nil];
}

- (void)postText:(NSString*)text withURL:(NSString*)url {
    [self prepareTwitterPost:text withImages:nil withURL:url];
}

- (void)postText:(NSString*)text withImage:(UIImage*)image andURL:(NSString*)url {
    [self prepareTwitterPost:text withImages:[NSArray arrayWithObject:image] withURL:url];
}

// -----
// Close
// -----
- (void)cancel {
    self.oAuth.oauth_token_authorized = NO;
}

// ----------------
// Internal Methods
// ----------------
- (void)prepareTwitterPost:(NSString*)text withImages:(NSArray*)images withURL:(NSString*)url {
    // Post to Twitter
#if _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
    // Try to use native code, if available
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
        [self performNativeTwitterPost:text withImages:images withURL:url kind:kSimpleSocialISO6];
    }
    else if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {
        [self performNativeTwitterPost:text withImages:images withURL:url kind:kSimpleSocialIOS5];
    }
    else {
        [self performSimpleTwitterPost:text withImages:images withURL:url];
    }
#else
    [self performSimpleTwitterPost:text withImages:images withURL:url];
#endif // _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
}

//
// Native Implementation
//
- (void)performNativeTwitterPost:(NSString*)text withImages:(NSArray*)images withURL:(NSString*)url kind:(kSimpleSocialIOSKind)kind {
#if _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
    // Determine whether to proceed
    BOOL proceed = FALSE;
    switch ( kind ) {
        case kSimpleSocialIOS5:
            proceed = [TWTweetComposeViewController canSendTweet];
            break;
        case kSimpleSocialISO6:
            proceed = [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
            break;
    }
    
    if ( proceed ) {
        // Configure the tweet sheet
        id tweet = nil;
        switch ( kind ) {
            case kSimpleSocialIOS5:
                tweet = [[TWTweetComposeViewController alloc] init];
                break;
            case kSimpleSocialISO6:
                tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                break;
        }
        if ( tweet != nil ) {
            // Basic configuration
            [tweet setInitialText:text];
            if ( images != nil ) {
                for ( UIImage *image in images ) {
                    switch ( kind ) {
                        case kSimpleSocialIOS5:
                            [(TWTweetComposeViewController*)tweet addImage:image];
                            break;
                        case kSimpleSocialISO6:
                            [(SLComposeViewController*)tweet addImage:image];
                            break;
                    }
                }
            }
            if ( url != nil ) { [tweet addURL:[NSURL URLWithString:url]]; }
            
            // Configure completion handlers
            void (^completionBlock)(void) = ^{
                if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ) {
                    [self dismissViewController:[self.delegate targetViewController]];
                }
            };
            [SimpleTwitter setCompletionHandler:tweet kind:kind completion:completionBlock delegate:self.delegate];
            
            // Get handle to view controller, and display it
            if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ) {
                [self presentViewController:[self.delegate targetViewController] controller:tweet];
            } else {
                [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateConfig];
            }
        }
    } else {
        // Signal error condition for no service
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleTwitterAlertTitle message:kSimpleTwitterAlertNoService delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
#endif   // _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
}

//
// Simple Implementation
//
- (void)performSimpleTwitterPost:(NSString*)text withImages:(NSArray*)images withURL:(NSString*)url {
    // Make sure you can post(!!)
    if ( isNSStringEmpty(self.oAuth.oauth_consumer_key) ) {
        [NSException raise:kSimpleTwitterExceptionAPITitle format:kSimpleTwitterExceptionAPIMsg];
    }
    
    // Put the operation in the queue
    SimpleOperation *op = [[SimpleOperation alloc] init];
    op.text = text;
    op.url = url;
    op.images = (images == nil) ? nil : [NSMutableArray arrayWithArray:images];
    [self.queue enqueueObj:op];
    
    // Post to Twitter
    if ( self.oAuth.oauth_token_authorized ) {
        [self processQueue];
    } else {
        [self prepareLoginViewController];
    }
}

#pragma mark -
#pragma mark Internal Methods
- (void)prepareLoginViewController {
    // Must have a delegate to proceed
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ) {
        // Prepare the view controller
        if ( self.login != nil ) { [self setLogin:nil]; }
        self.login = [[SimpleTwitterLoginViewController alloc] init];
        self.login.delegate = self;
        self.login.oAuth = self.oAuth;
        self.login.callbackURL = self.callbackURL;
        
        // Use a HUD if we are on iOS 5 or higher
        if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[self.delegate targetViewController].view animated:YES];
            hud.labelText = @"Loading";
            hud.dimBackground = YES;
        
            // Prepare the URL Request and Display
            // (Give a slight delay, otherwise UI might hang in a wierd way)
            double delayInSeconds =  0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                self.login.usePreloading = YES;
                [self.login prepareRequest];
            });
        } else {
            // (Give a slight delay, otherwise UI might hang in a wierd way)
            double delayInSeconds = 0.1f;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                // Configure the request with no HUD
                self.login.usePreloading = NO;
                [self.login prepareRequest];
                
                // Post the modal controller
                [self presentLoginViewController];
            });
        }
    } else {
        // Cannot connect with delegate
        [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateConfig];
    }
}

- (void)presentLoginViewController {
    if ( self.delegate != nil && [self.delegate targetViewController] ) {
        // Configure the controller
        UIViewController *controller = [self.delegate targetViewController];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.login.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        // Present the controller
        [self presentViewController:controller controller:self.login];
    } else {
        // Cannot connect with delegate
        [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateConfig];
    }
}

- (void)processQueue {
    if ( [self.queue size] > 0 ) {
        while ( [self.queue size] > 0 ) {
            SimpleOperation *op = (SimpleOperation*)[self.queue dequeueObj];
            [self process:op];
        }
    }
}

- (void)process:(SimpleOperation*)op {
    // Attempt to make the post
    if ( op != nil ){
        NSURLRequest *request = [SimpleTwitterRequest postRequest:op oauth:self.oAuth];
        if ( request != nil ) {
            // Only logging to NSLog to prevent compiler warnings
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            NSLog(@"++ SimpleTwitter posting with connection: %@", conn);
            return;
        }
    }
    
    // Signal failure condition to delegates
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleTwitterDidFail:withHeaders:)] ) {
        [self.delegate simpleTwitterDidFail:self withHeaders:@{@"SimpleTwitterError" : @"Could not formulate NSURLRequest"}];
    }
}

- (void)dismissLoginViewController {
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ) {
        [self dismissViewController:[self.delegate targetViewController]];
    } else {
        [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateConfig];
    }
}

#pragma mark -
#pragma mark Twitter Web/Login Delegate
- (void)loginViewControllerDidSucceed:(id)sender {    
    // Signal to delegate
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleTwitterDidLogin:)] )  {
        [self.delegate simpleTwitterDidLogin:self];
    }
    
    // ** Dismiss the Controller **
    // Some may prefer to dismiss the modal view controller in the delegate,
    // but this software is designed to be "simple", so that clients can implement
    // the social services with the minimal amount of hassle, and that includes
    // handling view controllers, ui components, etc. If you desire to handle the
    // dismissal in the delegate, simply comment out this portion, and/or deactivate
    // the "optimization" flag, and then implement the dismissal in the callback which
    // is invoked above.
    if ( self.optimize ) {
        [self dismissLoginViewController];
    }
    
    // Process the queue
    [self processQueue];
}

- (void)loginViewControllerDidLoad:(id)sender {
    // Remove the HUDs
    [MBProgressHUD hideAllHUDsForView:[self.delegate targetViewController].view animated:YES];
    
    if ( self.login.usePreloading ) {
        self.login.preloading = NO;
        [self presentLoginViewController];
    }
}

- (void)loginViewControllerDidFail:(id)sender {
    // Remove the HUDs
    [MBProgressHUD hideAllHUDsForView:[self.delegate targetViewController].view animated:YES];
    
    // Clear out queue and signal delegate
    if ( self.login.preloading ) {
        self.login.preloading = NO;
        [self.queue clear];
        
        // Signal to delegate
        if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleTwitterDidFail:withHeaders:)] ) {
            NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:@"Preloading failed"] forKeys:[NSArray arrayWithObject:@"error"]];
            [self.delegate simpleTwitterDidFail:self withHeaders:params];
        }
    }
}

- (void)loginViewControllerDidCancel:(id)sender {
    // Clear out the queue
    [self.queue clear];
    
    // Signal to delegate
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleTwitterDidCancel:)]) {
        [self.delegate simpleTwitterDidCancel:self];
    }
    
    // ** Dismiss the Controller **
    // Again, as above, some users may prefer to let the delegate perform this dismissal.
    if ( self.optimize ) {
        [self dismissLoginViewController];
    }
}

#pragma mark - 
#pragma mark Twitter OAuth Callbacks
- (void) requestTwitterTokenDidSucceed:(OAuth *)oAuth {
#if _kSIMPLE_TWITTER_DEBUG
    NSLog(@"++ Twitter Request Token did succeed");
#endif
}

- (void) requestTwitterTokenDidFail:(OAuth *)oAuth {
#if _kSIMPLE_TWITTER_DEBUG
    NSLog(@"++ Twitter Request Token did fail");
#endif
}

- (void) authorizeTwitterTokenDidSucceed:(OAuth *)oAuth {
#if _kSIMPLE_TWITTER_DEBUG
    NSLog(@"++ Twitter Authorize Token did succeed");
#endif 
}

- (void) authorizeTwitterTokenDidFail:(OAuth *)oAuth {
#if _kSIMPLE_TWITTER_DEBUG
    NSLog(@"++ Twitter Authorize Token did fail");
#endif
}

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    // Manage the cache
    if ( !self.cacheToken ) { self.oAuth.oauth_token_authorized = NO; }
    
    // Signal to delegate
    NSDictionary *params;
    switch ( response.statusCode ) {
        case 200:
            // Good
            if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleTwitterDidPost:)] ) {
                [self.delegate simpleTwitterDidPost:self];
            }
#if _kSIMPLY_SOCIAL_USE_SOUND
            [self playSound];
#endif
            break;
        default:
            // Error
            if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleTwitterDidFail:withHeaders:)] ) {
                params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:[NSHTTPURLResponse localizedStringForStatusCode:response.statusCode]] forKeys:[NSArray arrayWithObject:@"error"]];
                [self.delegate simpleTwitterDidFail:self withHeaders:params];
            }
            break;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // Signal to delegate
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleTwitterDidFail:withHeaders:)] ) {
        NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:error.localizedDescription] forKeys:[NSArray arrayWithObject:@"error"]];
        [self.delegate simpleTwitterDidFail:self withHeaders:params];
    }
}

@end
