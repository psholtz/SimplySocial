//
//  SimpleFacebookLoginViewController.m
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
#import "SimpleFacebookLoginViewController.h"

#pragma mark -
#pragma mark Private Interface
@interface SimpleFacebookLoginViewController ()

@property (nonatomic, strong) NSURLRequest *loginRequest;
@property (nonatomic, strong) UIWebView *loadedWebView;

- (void)fetchPreloadedRequest;
- (void)fetchStandardRequest;
- (NSString*)getStringFromURL:(NSURL*)url forKey:(NSString*)key;    // slightly different logic than in Twitter

@end

#pragma mark -
#pragma mark Implementation
@implementation SimpleFacebookLoginViewController

- (id)init {
    // Determine the context
    NSString *nibName = nil;
    if IS_IPAD {
        nibName = @"SimpleFacebookLoginViewController_iPad";
    } else if IS_IPHONE_5 {
        nibName = @"SimpleFacebookLoginViewController_iPhone5";
    } else {
        nibName = @"SimpleFacebookLoginViewController_iPhone4";
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
    
    // Light blue color is: (167, 184, 216)
    CGFloat bgAlpha = 0.4f;
    self.view.backgroundColor = [UIColor colorWithRed:bgAlpha green:bgAlpha blue:bgAlpha alpha:1.0f];
    self.headerView.backgroundColor = [UIColor colorWithRed:(108.0f/255.0f) green:(130.0f/255.0f) blue:(181.0f/255.0f) alpha:1.0f];
    
    // Shuffled the UIWebViews (hack when we are using the HUD and preloading)
    // f1.origin.x happens to correspond to the "buffer", so use it that way:
    if ( self.usePreloading ) {
        CGRect f1 = self.webView.frame;
        CGRect f2 = ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ) ? self.view.frame : [UIScreen mainScreen].bounds;
        self.loadedWebView.frame = CGRectMake(f1.origin.x,f1.origin.y,f1.size.width, f2.size.height - f1.origin.y - f1.origin.x);
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
    if ( self.loadedWebView != nil ) {
        [self.loadedWebView stopLoading];
        [self.loadedWebView setDelegate:nil];
        [self setLoadedWebView:nil];
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

// Support Rotations on iPhone
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark Custom Methods
- (void)prepareWithRequest:(NSURLRequest*)theRequest {
    self.loginRequest = theRequest;
    if ( self.usePreloading ) {
        [self fetchPreloadedRequest];
    }
}

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

#pragma mark -
#pragma mark IBAction Methods
- (IBAction)pressClose:(id)sender {
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidCancel:)]) {
        [self.delegate loginViewControllerDidCancel:self];
    }
}

#pragma mark -
#pragma mark Private Methods
- (NSString*)getStringFromURL:(NSURL*)url forKey:(NSString*)key {
    NSString *absoluteString = url.absoluteString;
    NSString * str = nil;
    NSRange start = [absoluteString rangeOfString:key];
    
    if ( start.location != NSNotFound ) {
        unichar c = '?';
        if (start.location != 0)
        {
            c = [absoluteString characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#')
        {
            NSRange end = [[absoluteString substringFromIndex:start.location+start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location+start.length;
            str = end.location == NSNotFound ?
            [absoluteString substringFromIndex:offset] :
            [absoluteString substringWithRange:NSMakeRange(offset, end.location)];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    
    return str;
}

#pragma mark -
#pragma mark Web Delegate
- (BOOL)webView:(UIWebView *)theView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    // Branch 1
    if ( [request.URL.scheme isEqualToString:@"fbconnect"] ) {
        NSString *token = [self getStringFromURL:request.URL forKey:@"access_token="];
        if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidFinish:withToken:)] ) {
            [self.delegate loginViewControllerDidFinish:self withToken:token];
        }
        [self.webView stopLoading];
        [self.loadedWebView stopLoading];
        return NO;
    }
    
    // Branch 2
    else if ( [request.URL.relativeString rangeOfString:@"m.facebook.com/dialog/permissions.request"].location != NSNotFound ) {
        // UI CONSIDERATION? HIDE THE CLOSE BUTTON HERE?
    }

    // Branch 3
    else if ( [request.URL.absoluteString rangeOfString:@"login.php"].location != NSNotFound ) {
        // UI CONSIDERATION? HIDE THE CLOSE BUTTON HERE??
    }

    // Branch 4
    else if ( [request.URL.absoluteString rangeOfString:@"error_reason=user_denied"].location != NSNotFound ) {        
        // Stop the loading
        [self.webView stopLoading];
        [self.loadedWebView stopLoading];

        // Signal to the delegate
        if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidCancel:)]) {
            [self.delegate loginViewControllerDidCancel:self];

        }
        return NO; 
    }
    
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidLoad:)]) {
        [self.delegate loginViewControllerDidLoad:self];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {    
    // This collision can happen when preloading, ignore it
    if ( error.code == -999 ) return;
    
    // Otherwise, signal delegate
    if( self.delegate != nil && [self.delegate respondsToSelector:@selector(loginViewControllerDidFail:)] ) {
        [self.delegate loginViewControllerDidFail:self];
    }
}

@end
