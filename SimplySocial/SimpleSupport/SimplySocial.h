//
//  SimplySocial.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define _kSIMPLY_SOCIAL_USE_SOUND                 1

#define kSimplySocialExceptionTitle                 @"SimplySocialException"
#define kSimplySocialExceptionDelegateConfig        @"UIViewController delegate is not configured properly!"
#define kSimplySocialExceptionDelegateDisplay       @"Unable to present UIViewController for display!"
#define kSimplySocialExceptionDelegateDismiss       @"Unable to dimiss UIViewController!"
#define kSimplySocialExceptionLoadSound             @"Unable to load sound!"

// =================================================
// Base class for SimpleFacebook and SimpleTwitter.
// =================================================
@interface SimplySocial : NSObject

#if _kSIMPLY_SOCIAL_USE_SOUND
@property (nonatomic, assign) BOOL useSound;
#endif

- (void)presentViewController:(UIViewController*)parent controller:(UIViewController*)controller;
- (void)dismissViewController:(UIViewController*)parent;

#if _kSIMPLY_SOCIAL_USE_SOUND
- (void)playSound;
#endif

@end
