//
//  SimplySocial.m
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

#import "SimplySocial.h"

#if _kSIMPLY_SOCIAL_USE_SOUND
#import <AudioToolbox/AudioToolbox.h>
#endif

#pragma mark -
#pragma mark Internal Interface
@interface SimplySocial ()
{
#if _kSIMPLY_SOCIAL_USE_SOUND
    SystemSoundID _sound;
#endif
}
@end

@implementation SimplySocial

- (id)init {
    self = [super init];
    if ( self ) {
#if _kSIMPLY_SOCIAL_USE_SOUND
        _sound = 0;
        NSString *path = [[NSBundle mainBundle] pathForResource:@"chime" ofType:@"caff"];
        NSURL *url = [NSURL fileURLWithPath:path];
        CFURLRef soundFileUrl = (__bridge CFURLRef)url;
        OSStatus errorCode = AudioServicesCreateSystemSoundID(soundFileUrl, &_sound);
        if ( errorCode != 0 ) {
            NSString *msg = [NSString stringWithFormat:@"%@: %@", kSimplySocialExceptionTitle, kSimplySocialExceptionLoadSound];
            NSLog(@"%@",msg);
            
            // Default to no sound
            self.useSound = FALSE;
        } else {
            // Default to use sound, if the compiler flag is set
            // (Client can always set variable to FALSE)
            self.useSound = TRUE;
        }
#endif
    }
    return self;
}

- (void)presentViewController:(UIViewController*)parent controller:(UIViewController*)controller {
    if ( [parent respondsToSelector:@selector(presentViewController:animated:completion:)] ) {
        [parent presentViewController:controller animated:YES completion:nil];
    } else if ( [parent respondsToSelector:@selector(presentModalViewController:animated:)] ) {
        [parent presentModalViewController:controller animated:YES];
    } else {
        [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateDisplay];
    }
}

- (void)dismissViewController:(UIViewController*)parent {
    if ( [parent respondsToSelector:@selector(dismissViewControllerAnimated:completion:)] ) {
        [parent dismissViewControllerAnimated:YES completion:nil];
    } else if ( [parent respondsToSelector:@selector(dismissModalViewControllerAnimated:)] ) {
        [parent dismissModalViewControllerAnimated:YES];
    } else {
        [NSException raise:kSimplySocialExceptionTitle format:kSimplySocialExceptionDelegateDismiss];
    }
}

#if _kSIMPLY_SOCIAL_USE_SOUND
// ------
// Sounds
// ------
- (void)playSound {
    if ( self.useSound ) {
        AudioServicesPlaySystemSound(_sound);
    }
}
#endif

@end
