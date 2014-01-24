//
//  SimpleFacebook.m
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

#import "SimpleFacebook.h"
#import "SimpleFacebook+AccessToken.h"
#import "SimpleFacebookLoginViewController.h"
#import "SimpleFacebookRequest.h"

#import "SimpleQueue.h"
#import "SimpleOperation.h"

#import "MBProgressHUD.h"

#if _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#endif // _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE

// Used in parameter dictionary during construction
static const NSString *kParamFacebookApiKey     = @"fbApiKey";
static const NSString *kParamFacebookCacheToken = @"fbCacheToken";

#pragma mark -
#pragma mark Internal Interface
@interface SimpleFacebook () <SimpleFacebookLoginViewControllerDelegate>

@property (nonatomic, strong) NSString          *apiKey;
@property (nonatomic, strong) SimpleQueue       *queue;
@property (nonatomic, strong) SimpleFacebookLoginViewController *login;

// Supporting methods
- (void)configure:(NSDictionary*)params;
- (void)prepareLoginViewController;
- (void)presentLoginViewController;
- (void)process:(SimpleOperation*)op token:(NSString*)token;
- (void)processQueue:(NSString*)token;
- (void)dismissLoginViewController;

// Actual "work" method
- (void)prepareFacebookPost:(NSString*)text images:(NSArray*)images url:(NSString*)url;
- (void)performNativeFacebookPost:(NSString*)text images:(NSArray*)images url:(NSString*)url;
- (void)performSimpleFacebookPost:(NSString*)text images:(NSArray*)images url:(NSString*)url;

@end

#pragma mark - 
#pragma mark Facebook Implementation
@implementation SimpleFacebook

// Returns true when the "Loading.." HUD is onscreen
- (BOOL)preloading {
    if ( self.login != nil ) {
        return [self.login preloading];
    }
    return NO;
}

// ------------ 
// Constructors
// ------------ 
- (id)init {
    self = [super init];
    if ( self ) {
        NSDictionary *params = @{
            kParamFacebookApiKey : _kSIMPLE_FACEBOOK_API_KEY,
            kParamFacebookCacheToken : [NSNumber numberWithBool:FALSE]
        };
        [self configure:params];
    }
    return self;
}

- (id)initWithAPIKey:(NSString*)apiKey {
    self = [super init];
    if ( self ) {
        NSDictionary *params = @{
            kParamFacebookApiKey : apiKey,
            kParamFacebookCacheToken : [NSNumber numberWithBool:FALSE]
        };
        [self configure:params];
    }
    return self;
}

- (void)configure:(NSDictionary*)params {
    self.queue = [[SimpleQueue alloc] init];
    self.apiKey = [params objectForKey:kParamFacebookApiKey];
    self.cacheToken = FALSE;
    self.optimize = TRUE;
}

// ------------
// FB Interface
// ------------
- (void)postText:(NSString*)text {
    [self prepareFacebookPost:text images:nil url:nil];
}

- (void)postText:(NSString*)text withImage:(UIImage*)image {
    [self prepareFacebookPost:text images:[NSArray arrayWithObject:image] url:nil];
}

- (void)postText:(NSString*)text withURL:(NSString*)url {
    [self prepareFacebookPost:text images:nil url:url];
}

- (void)postText:(NSString*)text withImage:(UIImage*)image andURL:(NSString*)url {
    [self prepareFacebookPost:text images:[NSArray arrayWithObject:image] url:url];
}

// -----
// Close
// -----
- (void)cancel {
    self.accessToken = nil;
    [self.queue clear];
}

// ----------------
// Internal Methods
// ----------------
// Preprocessing for FB
- (void)prepareFacebookPost:(NSString*)text images:(NSArray*)images url:(NSString*)url {
    // Post to FB
#if _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE
    // Try to use native code, if avaialble
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0") ) {
        [self performNativeFacebookPost:text images:images url:url];
    } else {
        [self performSimpleFacebookPost:text images:images url:url];
    }
#else
    [self performSimpleFacebookPost:text images:images url:url];
#endif // _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE
}

//
// Native Post to FB
//
- (void)performNativeFacebookPost:(NSString*)text images:(NSArray*)images url:(NSString*)url {
#if _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE
    if ( [SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook] ) {        
        // Configure a new social controller
        SLComposeViewController *fbController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [fbController setInitialText:text];
        if ( images != nil ) {
            for ( UIImage *image in images ) {
                [fbController addImage:image];
            }
        }
        if ( url != nil ) {
            [fbController addURL:[NSURL URLWithString:url]];
        }
        
        // Configure completion handler
        [fbController setCompletionHandler:^(SLComposeViewControllerResult result) {
            // Configure output
            NSString *output = nil;
            switch ( result ) {
                case SLComposeViewControllerResultDone:
                    output = kSimpleFacebookAlertPostSuccess;
                    break;
                case SLComposeViewControllerResultCancelled:
                    break;
            }
            
            // Present output
            if ( output != nil ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleFacebookAlertTitle message:output delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            // Dismiss the view controller
            if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ){
                [self dismissViewController:[self.delegate targetViewController]];
            }
        }];
        
        // Present the controller
        if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ) {
            [self presentViewController:[self.delegate targetViewController] controller:fbController];
        } else {
            [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateConfig];
        }
    } else {
        // Signal error condition for no service
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleFacebookAlertTitle message:kSimpleFacebookAlertNoService delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
#endif // _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE
}

//
// Simple Post to FB
//
- (void)performSimpleFacebookPost:(NSString*)text images:(NSArray*)images url:(NSString*)url {
    // Make sure you can post(!!)
    if ( isNSStringEmpty(self.apiKey) ) {
        [NSException raise:kSimpleFacebookExceptionAPITitle format:kSimpleFacebookExceptionAPIMsg];
    }
    
    // Put the operation into the queue
    SimpleOperation *op = [[SimpleOperation alloc] init];
    op.text = text;
    op.url = url;
    op.images = (images == nil) ? nil : [NSMutableArray arrayWithArray:images];
    [self.queue enqueueObj:op];
    
    // Perform the actual posting
    if ( self.accessToken != nil ) {
        [self processQueue:self.accessToken];
    } else {
        [self prepareLoginViewController];
    }
}

#pragma mark -
#pragma mark Internal Methods
- (void)prepareLoginViewController {
    // Must have a delegate to proceed
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ) {
        // Prepare the URL Request and Display
        NSURLRequest *request = [SimpleFacebookRequest loginRequestWithAPIKey:self.apiKey];
        if ( self.login != nil ) { [self setLogin:nil]; }
        self.login = [[SimpleFacebookLoginViewController alloc] init];
        self.login.delegate = self;
    
        // Use a HUD if we are iOS 5 or higher
        if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0") ) {
            // Prepare the HUD
            MBProgressHUD * hud = [MBProgressHUD showHUDAddedTo:[self.delegate targetViewController].view animated:YES];
            hud.labelText = @"Loading";
            hud.dimBackground = YES;

            // Start loading the login screen
            self.login.usePreloading = YES; 
            [self.login prepareWithRequest:request];
        } else {
            // Configure the request with no HUD
            self.login.usePreloading = NO;
            [self.login prepareWithRequest:request];
            
            // Post the modal controller
            [self presentLoginViewController];
        }
    } else {
        // Cannot connect with delegate
        [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateConfig];
    }
}

- (void)presentLoginViewController {
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(targetViewController)] ) {
        // Configure the controller
        UIViewController *controller = [self.delegate targetViewController];
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) {
            self.login.modalPresentationStyle = UIModalPresentationFormSheet;
        }
        
        // Present the controller
        [self presentViewController:controller controller:self.login];
    }
}

- (void)process:(SimpleOperation*)op token:(NSString*)token {
    // Attemp to make the post
    if ( op != nil ) {
        NSURLRequest *request = [SimpleFacebookRequest postRequest:op token:token];
        if ( request ) {
            // Only logging to NSLog to prevent compiler warnings
            NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
            NSLog(@"++ SimpleFacebook posting with connection: %@", conn);
            return;
        }
    }
    
    // Signal failure condition to delegates
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleFacebookDidFail:withHeaders:)] ) {
        [self.delegate simpleFacebookDidFail:self withHeaders:@{@"SimpleFacebookError" : @"Could not form NSURLRequest"}];
    }
}

- (void)processQueue:(NSString*)token {
    if ( [self.queue size] > 0 ) {
        while ( [self.queue size] > 0 ) {
            SimpleOperation *op = (SimpleOperation*)[self.queue dequeueObj];
            [self process:op token:token];
        }
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
#pragma mark Facebook Web Delegate
- (void)loginViewControllerDidFinish:(UIViewController*)controller withToken:(NSString*)token {
    // Signal to delegate
    self.accessToken = self.cacheToken ? token : nil;
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleFacebookDidLogin:)]) {
        [self.delegate simpleFacebookDidLogin:self];
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
    [self processQueue:token];
}

- (void)loginViewControllerDidLoad:(id)sender {
    // Remove the HUDs
    [MBProgressHUD hideAllHUDsForView:[self.delegate targetViewController].view animated:YES];
    
    // Prepare the login controller
    if ( self.login.preloading ) {
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
        if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleFacebookDidFail:withHeaders:)] ) {
            NSDictionary *params = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObject:@"Preloading failed"] forKeys:[NSArray arrayWithObject:@"error"]];
            [self.delegate simpleFacebookDidFail:self withHeaders:params];
        }
    }
}

- (void)loginViewControllerDidCancel:(id)sender {
    // Clear out the queue
    [self.queue clear];
    
    // Signal to delegate
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleFacebookDidCancel:)]) {
        [self.delegate simpleFacebookDidCancel:self];
    }
    
    // ** Dismiss the Controller **
    // Again, as above, some users may prefer to let the delegate perform this dismissal.
    if ( self.optimize ) {
        [self dismissLoginViewController];
    }
}

#pragma mark -
#pragma mark NSURLConnection Delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    switch (response.statusCode) {
        // GOOD
        case 200:
            if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleFacebookDidPost:)] ) {
                [self.delegate simpleFacebookDidPost:self];
            }
#if _kSIMPLY_SOCIAL_USE_SOUND
            [self playSound];
#endif
            break;
            
        // NEED AUTHORIZATION
        case 400:
        case 403:
        case 458:
        default:
            [self.queue clear];
            if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(simpleFacebookDidFail:withHeaders:)] ) {
                [self.delegate simpleFacebookDidFail:self withHeaders:response.allHeaderFields];
            }
            break;
    }
}

@end
