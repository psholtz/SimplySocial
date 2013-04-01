//
//  SimpleTwitterLoginViewController.h
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

@class OAuth;

#pragma mark -
#pragma mark Protocol
@protocol SimpleTwitterLoginViewControllerDelegate <NSObject>

@required
- (void)loginViewControllerDidSucceed:(id)sender;
- (void)loginViewControllerDidLoad:(id)sender;
- (void)loginViewControllerDidFail:(id)sender;
- (void)loginViewControllerDidCancel:(id)sender;

@end

#pragma mark -
#pragma mark Interface
@interface SimpleTwitterLoginViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, SIMPLE_WEAK) id<SimpleTwitterLoginViewControllerDelegate> delegate;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIWebView *webView;
@property (nonatomic, SIMPLE_WEAK) IBOutlet UIView *headerView;
@property (nonatomic, strong) OAuth *oAuth;

@property (nonatomic, assign) BOOL usePreloading;
@property (nonatomic, assign) BOOL preloading;
@property (nonatomic, strong) NSString *callbackURL;

#pragma mark -
#pragma mark IBAction Methods
- (IBAction)pressClose:(id)sender;

#pragma mark -
#pragma mark Custom Methods
- (void)prepareRequest;

@end
