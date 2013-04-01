//
//  SimpleTwitterLoginViewController.m
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
#import "SimpleTwitterLoginViewController.h"
#import "SimpleTwitterRequest.h"

#import "OAuth.h"

#pragma mark -
#pragma mark Private Interface
@interface SimpleTwitterLoginViewController ()

@property (nonatomic, strong) NSURLRequest *loginRequest;

@property (nonatomic, strong) UIWebView *loadedWebView;

- (void)getAccessToken;
- (void)fetchPreloadedRequest;
- (void)fetchStandardRequest;
- (NSString*)getStringFromURL:(NSURL*)url forKey:(NSString*)key; // slightly different logic than in FB

@end

#pragma mark -
#pragma mark Implementation
@implementation SimpleTwitterLoginViewController

- (id)init {
    // Determine the context
    NSString *nibName = nil;
    if IS_IPAD {
        nibName = @"SimpleTwitterLoginViewController_iPad";
    } else if IS_IPHONE_5 {
        nibName = @"SimpleTwitterLoginViewController_iPhone5";
    } else {
        nibName = @"SimpleTwitterLoginViewController_iPhone4";
    }
    
    // Load the nib
    self = [super initWithNibName:nibName bundle:nil];
    if ( self ) {
        self.usePreloading = YES;
        self.preloading = NO;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // To support iOS 4.3 and before
    if ( !self.usePreloading ) {
        [self fetchStandardRequest];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGFloat bgAlpha1 = 0.4f, bgAlpha2 = 0.17f;
    self.view.backgroundColor = [UIColor colorWithRed:bgAlpha1 green:bgAlpha1 blue:bgAlpha1 alpha:1.0f];
    self.headerView.backgroundColor = [UIColor colorWithRed:bgAlpha2 green:bgAlpha2 blue:bgAlpha2 alpha:1.0f];
    
    // Shuffled the UIWebViews (hack when we are using the HUD and preloading)
    // f1.origin.x happens to correspond to the "buffer", so use it that way:
    if ( self.usePreloading ) {
        CGRect f1 = self.webView.frame;
        CGRect f2 = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) ? self.view.frame : [UIScreen mainScreen].bounds;
        self.loadedWebView.frame = CGRectMake(f1.origin.x, f1.origin.y, f1.size.width, f2.size.height - f1.origin.y - f1.origin.x);
        self.loadedWebView.autoresizingMask = self.webView.autoresizingMask;
        [self.webView removeFromSuperview];
        [self setWebView:nil];
        [self.view addSubview:self.loadedWebView];
    }
}

- (void)viewDidUnload {
    if ( self.webView != nil ) {
        [self.webView stopLoading];
        [self.webView setDelegate:nil];
        [self setWebView:nil];
    }
    [self setHeaderView:nil];
    
    [super viewDidUnload];
}

// For pre-iOS6
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

// For iOS6+
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}

// For iOS6+
- (BOOL)shouldAutorotate {
    return YES;
}

#pragma mark -
#pragma mark Custom Methods
- (void)prepareRequest {
    [self getAccessToken];
    
    self.loginRequest = [SimpleTwitterRequest loginRequestWithOAuth:self.oAuth];
    if ( self.usePreloading ) {
        [self fetchPreloadedRequest];
    }
}

#pragma mark -
#pragma mark IBAction Methods
- (IBAction)pressClose:(id)sender{
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidCancel:)] ) {
        [self.delegate loginViewControllerDidCancel:self];
    }
}

#pragma mark -
#pragma mark Private Methods
- (void)fetchPreloadedRequest {
    // Configure the proxy web view
    self.preloading = YES;
    self.loadedWebView = [[UIWebView alloc] init];
    self.loadedWebView.delegate = self;
    
    // Clear out the cookies
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [storage.cookies copy];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {[storage deleteCookie:cookie];}];
    
    // Load the request
    [self.loadedWebView loadRequest:self.loginRequest];
}

- (void)fetchStandardRequest {
    // Clear out the cookies
    NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray *cookies = [storage.cookies copy];
    [cookies enumerateObjectsUsingBlock:^(NSHTTPCookie *cookie, NSUInteger idx, BOOL *stop) {[storage deleteCookie:cookie];}];
    
    // Load the request
    [self.webView loadRequest:self.loginRequest];
}

- (void)getAccessToken {
    if ( isNSStringEmpty(self.callbackURL) ) {
        [NSException raise:@"Null callback URL Exception" format:@"Please furnish a valid callback URL!"];
    }
    
    [self.oAuth synchronousRequestTwitterTokenWithCallbackUrl:self.callbackURL];
}

- (NSString*)getStringFromURL:(NSURL*)url forKey:(NSString*)key {
    NSString *str;
    NSString *target = [url absoluteString];
    
    NSRange start = [target rangeOfString:key];
    if ( start.location != NSNotFound ) {
        NSRange end = [[target substringFromIndex:(start.location + start.length)] rangeOfString:@"&"];
        NSUInteger offset = start.location + start.length;
        str = end.location == NSNotFound ? [target substringFromIndex:offset] : [target substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
    }
    
    return str;
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    // callback url, in which case we want to close
    if ( [request.URL.host isEqualToString:[[NSURL URLWithString:self.callbackURL] host]] ) {
        if ( [request.URL.resourceSpecifier rangeOfString:@"?denied="].location != NSNotFound ) {
            // Failure
            if  ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidFail:)] ) {
                [self.delegate loginViewControllerDidFail:self];
            }
        } else {
            // Success
            NSString *token = [self getStringFromURL:request.URL forKey:kSimpleTwitterOAuthVerifierKey];
            [self.oAuth synchronousAuthorizeTwitterTokenWithVerifier:token];
            if  ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidSucceed:)] ) {
                [self.delegate loginViewControllerDidSucceed:self];
            }
        }
        return NO; 
    }
    
    // If they click a link, take them outside the app
    if ( navigationType == UIWebViewNavigationTypeLinkClicked ) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return NO;
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    // Only need to handle this case if we are preloading w/ loadedWebView
    if ( webView == self.loadedWebView && self.preloading ) {
        if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidLoad:)] ) {
            [self.delegate loginViewControllerDidLoad:self];
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidFail:)] ) {
        [self.delegate loginViewControllerDidFail:self];
    }
}

@end
