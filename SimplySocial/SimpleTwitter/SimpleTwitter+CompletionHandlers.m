//
//  SimpleTwitter+CompletionHandlers.m
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
//  Created by Paul Sholtz on 3/29/13.
//

#import "SimpleTwitter+CompletionHandlers.h"

#if _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
#import <Twitter/Twitter.h>
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#endif // _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE

@implementation SimpleTwitter (CompletionHandlers)

+ (void)setCompletionHandler:(id)tweet kind:(kSimpleSocialIOSKind)kind completion:(void (^)(void))completionBlock delegate:(id<SimpleTwitterDelegate>)delegate {
#if _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
    if ( kind == kSimpleSocialIOS5 )
    {
        [(TWTweetComposeViewController*)tweet setCompletionHandler:^(TWTweetComposeViewControllerResult result) {
            // Determine message
            NSString *output = nil;
            switch ( result ) {
                case TWTweetComposeViewControllerResultDone:
                    output = kSimpleTwitterAlertPostSuccess;
                    break;
                case TWTweetComposeViewControllerResultCancelled:
                    break;
            }
            
            // Present message
            if ( output != nil ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleTwitterAlertTitle message:output delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            // Dismiss the view controller
            completionBlock();
         }];
    }
    
    if ( kind == kSimpleSocialISO6 )
    {
        [(SLComposeViewController*)tweet setCompletionHandler:^(SLComposeViewControllerResult result) {
            // Determine message
            NSString *output = nil;
            switch ( result ) {
                case SLComposeViewControllerResultDone:
                    output = kSimpleTwitterAlertPostSuccess;
                    break;
                case SLComposeViewControllerResultCancelled:
                    break;
            }
            
            // Present message
            if ( output != nil ) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:kSimpleTwitterAlertTitle message:output delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
            // Dismiss the view controller
            completionBlock();
        }];
    }
#endif // _kSIMPLE_TWITTER_USE_NATIVE_IF_AVAILABLE
}

@end
