//
//  ViewController.h
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

#import <UIKit/UIKit.h>

#import "SimpleHeaders.h"

@interface ViewController : UIViewController <UIScrollViewDelegate>

@property (nonatomic, SIMPLE_WEAK) IBOutlet UIScrollView *scrollView;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIView *facebookPanel;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIView *twitterPanel;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIPageControl *pageControl;

@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonFacebookText;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonFacebookURL;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonFacebookImage;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonFacebookImageURL;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonFacebookCancel;

@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonTwitterText;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonTwitterURL;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonTwitterImage;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonTwitterImageURL;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIButton * buttonTwitterCancel;

@property (nonatomic, SIMPLE_WEAK) IBOutlet UISwitch * switchFacebook;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UISwitch * switchTwitter;

#pragma mark -
#pragma mark IBAction Methods
// Facebook
- (IBAction)pressFacebookText:(id)sender;
- (IBAction)pressFacebookURL:(id)sender;
- (IBAction)pressFacebookImage:(id)sender;
- (IBAction)pressFacebookImageURL:(id)sender;
- (IBAction)cancelFacebook:(id)sender;

// Twitter
- (IBAction)pressTwitterText:(id)sender;
- (IBAction)pressTwitterURL:(id)sender;
- (IBAction)pressTwitterImage:(id)sender;
- (IBAction)pressTwitterImageUrl:(id)sender;
- (IBAction)cancelTwitter:(id)sender;

// Supporting Methods
- (IBAction)toggleFacebookToken:(id)sender;
- (IBAction)toggleTwitterToken:(id)sender;

- (void)updateFacebookButton:(id)sender;
- (void)updateFacebookButtonState:(BOOL)value;
- (void)updateTwitterButton:(id)sender;
- (void)updateTwitterButtonState:(BOOL)value;

// UIPageControl
- (IBAction)changePage:(id)sender;

@end
