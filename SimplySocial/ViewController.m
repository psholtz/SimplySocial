//
//  ViewController.m
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

#import <QuartzCore/QuartzCore.h>

#import "ViewController.h"

#import "SimpleFacebook.h"
#import "SimpleFacebook+AccessToken.h"

#import "SimpleTwitter.h"

#define kKBLabelColor1 [UIColor colorWithWhite:0.5f alpha:1.0f];
#define kKBLabelColor2 [UIColor colorWithWhite:0.5f alpha:0.6f];

static CGFloat kDurationFade = 0.2f;
static CGFloat kBorderWidth  = 1.0f;
static CGFloat kCornerRadius = 5.0f;

static NSString *kSampleURL = @"http://www.sholtz9421.com";

// Used only for UI purposes to give a slight delay when invoking view controllers.
// Not necessary for logic of social interaction.
static void (^kWrapWithDelay)(void (^block)(void),NSTimeInterval delay) = ^(void (^block)(void),NSTimeInterval delay){
    double delayInSeconds =  delay;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        block();
    });
};

static CGFloat kUIDelay = 0.12f;

// Used only for demo purposes
enum {
    kSimpleFacebookConstructorStateInit,
    kSimpleFacebookConstructorStateInitWithAPIKey,
};

enum {
    kSimpleTwitterConstructorStateInit,
    kSimpleTwitterConstructorStateInitWithApiKeyAndSecret
};

#define _kSIMPLE_FACEBOOK_CONSTRUCTOR_STATE    kSimpleFacebookConstructorStateInitWithAPIKey
#define _kSIMPLE_TWITTER_CONSTRUCTOR_STATE     kSimpleTwitterConstructorStateInitWithApiKeyAndSecret

#pragma mark -
#pragma mark Private Interface
@interface ViewController () <SimpleFacebookDelegate, SimpleTwitterDelegate>

@property (nonatomic, strong) UIImage *sampleImage1;
@property (nonatomic, strong) SimpleFacebook *facebook;
@property (nonatomic, strong) SimpleTwitter *twitter;

- (NSString*)getSampleText;

- (void)deviceOrientationDidChange:(NSNotification*)notification;
- (void)handleChangetoLandscape;
- (void)handleChangeToPortrait;

@end

@implementation ViewController

#pragma mark -
#pragma mark View Lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Prepare the sample image(s)
    self.sampleImage1 = [[UIImage alloc] initWithData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Saturn1" ofType:@"jpg"]]];
    
    // Switch used just for testing/demo purposes
    switch ( _kSIMPLE_FACEBOOK_CONSTRUCTOR_STATE ) {
        case kSimpleFacebookConstructorStateInit:
            self.facebook = [[SimpleFacebook alloc] init];
            self.facebook.delegate = self;
            break;
            
        case kSimpleFacebookConstructorStateInitWithAPIKey:
            self.facebook = [[SimpleFacebook alloc] initWithAPIKey:_kSIMPLE_FACEBOOK_API_KEY];
            self.facebook.delegate = self;
            break;
    }
    
    // Switch used just for testing/demo purposes
    switch ( _kSIMPLE_TWITTER_CONSTRUCTOR_STATE ) {
        case kSimpleTwitterConstructorStateInit:
            self.twitter = [[SimpleTwitter alloc] init];
            self.twitter.delegate = self;
            break;
            
        case kSimpleTwitterConstructorStateInitWithApiKeyAndSecret:
            self.twitter = [[SimpleTwitter alloc] initWithAPIKey:_kSIMPLE_TWITTER_CONSUMER_KEY andSecret:_kSIMPLE_TWITTER_CONSUMER_SECRET andCallbackURL:_kSIMPLE_TWITTER_CALLBACK_URL];
            self.twitter.delegate = self;
            break;
    }
    
    // The token caches are set to false initially
    [self updateFacebookButtonState:NO];
    [self updateTwitterButtonState:NO];
    
    // Configure the scroll views
    CGRect f1 = self.scrollView.frame;
    CGRect f2 = self.facebookPanel.frame;
    CGRect f3 = self.twitterPanel.frame;
    
    self.scrollView.contentSize = CGSizeMake(f1.size.width * 2, f1.size.height);
    self.facebookPanel.frame = CGRectMake(0, 0, f2.size.width, f2.size.height);
    self.twitterPanel.frame = CGRectMake(f1.size.width, 0, f3.size.width, f3.size.height);
    [self.scrollView addSubview:self.facebookPanel];
    [self.scrollView addSubview:self.twitterPanel];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    
    // Begin listen for rotations (use Observer, since we can have more than one 1 VC onscreen at a time)
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    // Slight hack for iOS7
    if ( SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0") ) {
        // Facebook Buttons
        [self adjustButtonColor:self.buttonFacebookText];
        [self adjustButtonColor:self.buttonFacebookURL];
        [self adjustButtonColor:self.buttonFacebookImage];
        [self adjustButtonColor:self.buttonFacebookImageURL];
        [self adjustButtonColor:self.buttonFacebookCancel];
        
        // Twitter Buttons
        [self adjustButtonColor:self.buttonTwitterText];
        [self adjustButtonColor:self.buttonTwitterURL];
        [self adjustButtonColor:self.buttonTwitterImage];
        [self adjustButtonColor:self.buttonTwitterImageURL];
        [self adjustButtonColor:self.buttonTwitterCancel];
        
        // Slider
        [self adjustSwitchColor:self.switchFacebook];
        [self adjustSwitchColor:self.switchTwitter];
    
        // The one button is incorrectly positioned
        self.buttonFacebookImageURL.frame = CGRectMake(self.buttonFacebookURL.frame.origin.x,
                                                       self.buttonFacebookImage.frame.origin.y,
                                                       self.buttonFacebookImage.frame.size.width,
                                                       self.buttonFacebookImage.frame.size.height);
        
        self.buttonTwitterImageURL.frame = CGRectMake(self.buttonTwitterURL.frame.origin.x,
                                                       self.buttonTwitterImage.frame.origin.y,
                                                       self.buttonTwitterImage.frame.size.width,
                                                       self.buttonTwitterImage.frame.size.height);
        
        // Adjust the cancel buttons down a bit
        CGFloat margin1 = 10.0f;
        [self adjustViewPosition:self.buttonFacebookCancel withMargin:margin1];
        [self adjustViewPosition:self.buttonTwitterCancel withMargin:margin1];
    }
}

- (void)viewDidUnload {
    self.scrollView = nil;
    self.facebookPanel = nil;
    self.twitterPanel = nil;
    self.buttonFacebookCancel = nil;
    self.buttonTwitterCancel = nil;
    self.pageControl = nil;
    [super viewDidUnload];
}

// Hacks for iOS7 position
- (void)adjustViewPosition:(UIView*)view1 withMargin:(CGFloat)margin {
    CGRect tmp = view1.frame;
    view1.frame = CGRectMake(tmp.origin.x, tmp.origin.y + margin, tmp.size.width, tmp.size.height);
}

// Hacks for iOS7 colors
- (void)adjustButtonColor:(UIButton*)button {
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.backgroundColor = kKBLabelColor1;
    button.layer.borderColor = [UIColor blackColor].CGColor;
    button.layer.borderWidth = kBorderWidth;
    button.layer.cornerRadius = kCornerRadius;
}

- (void)adjustSwitchColor:(UISwitch*)slider {
    slider.backgroundColor = kKBLabelColor2;
    slider.layer.cornerRadius = 16.0f;
}

// For pre-iOS6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
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
    if ( UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ) {
        [self handleChangeToPortrait];
    }
    if ( UIInterfaceOrientationIsLandscape(toInterfaceOrientation) ) {
        [self handleChangetoLandscape];
    }
}

// Support Rotations on iPhone
- (void)deviceOrientationDidChange:(NSNotification*)notification {
    // Obtain orientation
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    
    // Ignoring specific orientations
    if ( orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown ) {
        return;
    }
    
    if ( UIDeviceOrientationIsPortrait(orientation) ) {
        [self handleChangeToPortrait];
    }
    if ( UIDeviceOrientationIsLandscape(orientation) ) {
        [self handleChangetoLandscape];
    }
}

//
// Handle Landscape
//
- (void)handleChangetoLandscape {
    CGRect f = self.twitterPanel.frame;
    if IS_IPHONE_5 {
        self.twitterPanel.frame = CGRectMake(548, 0, f.size.width, f.size.height);
        self.scrollView.contentSize = CGSizeMake(2 * 548, 266);
        self.scrollView.contentOffset = CGPointMake(self.pageControl.currentPage * 548, 0);
    }
    if IS_IPHONE_4 {
        self.twitterPanel.frame = CGRectMake(460, 0, f.size.width, f.size.height);
        self.scrollView.contentSize = CGSizeMake(2 * 460, 268);
        self.scrollView.contentOffset = CGPointMake(self.pageControl.currentPage * 460, 0);
    }
}

//
// Handle Portrait
//
- (void)handleChangeToPortrait {
    CGRect f = self.twitterPanel.frame;
    if IS_IPHONE_5 {
        self.twitterPanel.frame = CGRectMake(300, 0, f.size.width, f.size.height);
        self.scrollView.contentSize = CGSizeMake(2 * 300, 514);
        self.scrollView.contentOffset = CGPointMake(self.pageControl.currentPage * 300, 0);
    }
    if IS_IPHONE_4 {
        self.twitterPanel.frame = CGRectMake(300, 0, f.size.width, f.size.height);
        self.scrollView.contentSize = CGSizeMake(2 * 300, 428);
        self.scrollView.contentOffset = CGPointMake(self.pageControl.currentPage * 300, 0);
    }
}

#pragma mark -
#pragma mark UIScrollView Delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scroller {
    self.pageControl.currentPage = (scroller.contentOffset.x / (scroller.contentSize.width / self.pageControl.numberOfPages));
}

- (IBAction)changePage:(id)sender {
    CGFloat pageWidth = self.scrollView.contentSize.width / self.pageControl.numberOfPages;
    CGFloat x = self.pageControl.currentPage * pageWidth;
    [self.scrollView scrollRectToVisible:CGRectMake(x, 0, pageWidth, self.scrollView.frame.size.height) animated:YES];
}

#pragma mark -
#pragma mark IBAction Methods
//
// Facebook
//
- (IBAction)pressFacebookText:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.facebook postText:[self getSampleText]];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)pressFacebookImage:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.facebook postText:[self getSampleText] withImage:self.sampleImage1];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)pressFacebookImageURL:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.facebook postText:[self getSampleText] withImage:self.sampleImage1 andURL:kSampleURL];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)pressFacebookURL:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.facebook postText:[self getSampleText] withURL:kSampleURL];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)cancelFacebook:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        // Clear token
        [self.facebook cancel];
        
        // Signal to user 
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Token" message:@"Facebook access token cleared." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    };
    kWrapWithDelay(block, kUIDelay);
}

//
// Twitter
//
- (IBAction)pressTwitterText:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.twitter postText:[self getSampleText]];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)pressTwitterImage:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.twitter postText:[self getSampleText] withImage:self.sampleImage1];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)pressTwitterURL:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.twitter postText:[self getSampleText] withURL:kSampleURL];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)pressTwitterImageUrl:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        [self.twitter postText:[self getSampleText] withImage:self.sampleImage1 andURL:kSampleURL];
    };
    kWrapWithDelay(block, kUIDelay);
}

- (IBAction)cancelTwitter:(id)sender {
    // Slight delay (for UI purposes)
    void (^block)(void) = ^{
        // Clear token
        [self.twitter cancel];
        
        // Signal to user
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Clear Token" message:@"Twitter access token cleared." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    };
    kWrapWithDelay(block, kUIDelay);
}

// Supporting Methods
- (IBAction)toggleFacebookToken:(id)sender {
    [self updateFacebookButton:sender];
}

- (IBAction)toggleTwitterToken:(id)sender {
    [self updateTwitterButton:sender] ;
}

- (void)updateFacebookButton:(id)sender {
    if ( [sender isKindOfClass:UISwitch.class] ) {
        UISwitch *tmp = (UISwitch*)sender;
        self.facebook.cacheToken = tmp.on;
        [self updateFacebookButtonState:tmp.on];
        if ( !tmp.on ) {
            [self.facebook cancel];
        }
    }
}

- (void)updateFacebookButtonState:(BOOL)value {
    self.buttonFacebookCancel.enabled = value;
    [UIView animateWithDuration:kDurationFade
                     animations:^(void) {
                         self.buttonFacebookCancel.alpha = value ? 1.0f : 0.6f;
                     }];
    
}

- (void)updateTwitterButton:(id)sender {
    if ( [sender isKindOfClass:UISwitch.class] ) {
        UISwitch *tmp = (UISwitch*)sender;
        self.twitter.cacheToken = tmp.on;
        [self updateTwitterButtonState:tmp.on];
        if ( !tmp.on ) {
            [self.twitter cancel];
        }
    }
}

- (void)updateTwitterButtonState:(BOOL)value {
    self.buttonTwitterCancel.enabled = value;
    [UIView animateWithDuration:kDurationFade
                     animations:^(void) {
                         self.buttonTwitterCancel.alpha = value ? 1.0f : 0.6f;
                     }];
}

#pragma mark -
#pragma mark Private Methods
- (NSString*)getSampleText {
    return [NSString stringWithFormat:@"Test message: %f", [[NSDate date] timeIntervalSince1970]];
}

#pragma mark -
#pragma mark Simple Facebook Delegate
////////////////////////////////////////////////////////
// Required Simple Facebook and Twitter Delegates
- (UIViewController*)targetViewController {
    return self;
}

////////////////////////////////////////////////////////
// Optional Simple Facebook Delegates
- (void)simpleFacebookDidPost:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleFacebookAlertTitle message:kSimpleFacebookAlertPostSuccess delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)simpleFacebookDidFail:(id)sender withHeaders:(NSDictionary *)headers {
    // Notify user
    if ( self.facebook.preloading ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleFacebookAlertTitle message:kSimpleFacbeookAlertLoginFail delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        // Standard error coming from FB
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleFacebookAlertTitle message:kSimpleFacebookAlertPostFail delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
#if _kSIMPLE_FACEBOOK_DEBUG
    // Log the error
    NSLog(@"++ Facebook did fail: %@",headers);
#endif
}

- (void)simpleFacebookDidLogin:(id)sender {
#if _kSIMPLE_FACEBOOK_DEBUG
    NSLog(@"++ Facebook did login");
#endif
}

- (void)simpleFacebookDidCancel:(id)sender {
#if _kSIMPLE_FACEBOOK_DEBUG
    NSLog(@"++ Facebook did cancel");
#endif
}

///////////////////////////////////////////////////////////
// Optional Simple Twitter Delegates
#pragma mark -
#pragma mark Simple Twitter Delegate
- (void)simpleTwitterDidLogin:(id)sender {
#if _kSIMPLE_TWITTER_DEBUG
    NSLog(@"++ Twitter did login");
#endif
}

- (void)simpleTwitterDidFail:(id)sender withHeaders:(NSDictionary*)headers {
    // Notify user
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleTwitterAlertTitle message:kSimpleTwitterAlertPostFail delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
    
#if _kSIMPLE_TWITTER_DEBUG
    // Log the error
    NSLog(@"++ Twitter did fail: %@", headers);
#endif
}

- (void)simpleTwitterDidPost:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleTwitterAlertTitle message:kSimpleTwitterAlertPostSuccess delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)simpleTwitterDidCancel:(id)sender {
#if _kSIMPLE_TWITTER_DEBUG
    NSLog(@"++ Twitter did cancel");
#endif
}

@end
