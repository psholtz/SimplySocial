SimplySocial
============ 

![http://farm9.staticflickr.com/8394/8608208252_b2a908b226.jpg](http://farm9.staticflickr.com/8394/8608208252_b2a908b226.jpg)

SimplySocial is a brutally simple collection of classes for connecting to Facebook and Twitter.

SimplySocial only connects with Facebook and Twitter, and it does not provide full API support for either of these services. Rather, the design philosophy behind SimplySocial is KISS -- keep things as brutally simple as possible. SimplySocial accordingly provides its own OAuth implementation which (only) allows users to post text, URLs and images to the two major social networking sites. The posting of text, URLs and images to the two major social networking sites is the only "social networking requirement" for probably over 90% of all mobile projects. Consequently, additional API support is unnecessary for the majority of mobile users and programmers, would needlessly clutter and bloat Xcode projects by forcing linking with otherwise unused Frameworks, and runs contrary to KISS. The full social APIs are therefore deliberately left unimplemented.

Use Cases
--------- 

It's true that since iOS 6, Apple has provided native implementations for connecting to Facebook and Twitter directly in iOS.

So why would anyone actually want to use SimplySocial?

One good reason would be to provide support for social networking on iOS versions back to 4.3 and earlier.

For instance, if you want to provide support for Facebook on iOS 5 and earlier, or support for Twitter on iOS 4, you'll still have to get your hands dirty with OAuth anyway. SimplySocial is a "quick and easy" way to provide your own social connection services without adding all the unnecessary bulk and bloat to your codebase or memory footprint that other popular libraries frequently require.

Or perhaps your app runs entirely on iOS 6 and above, but you're deploying it on iPads at a trade show. You want users to post to the social sites, but they're never going to want to actually save their authentication credentials in the settings panel on the physical device itself, as required by the native iOS implementations (since hundreds of users will be interacting with the same device throughout the day). SimplySocial is again a "quick" way to get your own OAuth implementation up and running with the least amount of hassle.

You can probably think of more use cases on your own.

In fact, if you're reading this, chances are you already have something similar in mind.

Dynamic Support for Native iOS Social Networking
------------------------------------------------ 

Using SimplySocial, it's easy to fall back on the native iOS implementations of OAuth when those are available on the device.

Simply search for the appropriate compiler flag and set it to true:

<pre>
#define _kSIMPLE_FACEBOOK_USE_NATIVE_IF_AVAILABLE   1
</pre>

This way, you can write your social networking code once and use it to post safely to Facebook and Twitter regardless of whether your app is running on iOS 4 or iOS 6+ (or anything in between). If the native iOS OAuth implementations are available on the device, they'll be used. Otherwise, the app will fall back on the SimplySocial implementations of OAuth.

If you follow this path, you'll almost certainly want to weakly-link the required iOS Frameworks into your Xcode project:

![http://farm9.staticflickr.com/8116/8608804950_0d642b34c3_c.jpg](http://farm9.staticflickr.com/8116/8608804950_0d642b34c3_c.jpg)

Otherwise, without those (weakly-linked, i.e., "Optional") Frameworks, the native implementations obviously won't work on iOS 6, but -- by the same token -- if those same Frameworks are "hard-linked" into the Xcode project, you'll get a nasty crash when trying to run on iOS 4.

Remember (again): **SimplySocial is designed to be brutally simple(!)**

Out of the box, no additional Frameworks are required to run SimplySocial other than the "big three" that ship with every iOS app: Foundation, UIKit, and CoreGraphics. Just remember to appropriately link whatever additional frameworks you may need, if you'll be providing social services over and above that which SimplySocial offers.

SimplySocial Tutorial
--------------------- 

Using SimplySocial to post to Facebook and Twitter is pretty darn simple.

First, create your SimplySocial Facebook (or Twitter) object:

<pre>
SimpleFacebook *facebook = [[SimpleFacebook alloc] initWithAPIKey:@"YOUR-FACEBOOK-API-KEY"];
</pre>

If you want to set the following compiler flag, you can construct your SimplySocial Facebook object even more simply:

<pre>
#define _kSIMPLE_FACEBOOK_API_KEY @"YOUR-FACEBOOK-API-KEY"

SimpleFacebook *facebook = [[SimpleFacebook alloc] init];
</pre>

Note that the Twitter API requires three authentication tokens for initialization (consumer key, consumer secret and callback URL):

<pre>
#define _kSIMPLE_TWITTER_CONSUMER_KEY               @"YOUR-TWITTER-CONSUMER-KEY"
#define _kSIMPLE_TWITTER_CONSUMER_SECRET            @"YOUR-TWITTER-CONSUMER-SECRET"
#define _kSIMPLE_TWITTER_CALLBACK_URL               @"YOUR-TWITTER-CALLBACK-URL"

SimpleTwitter *twitter = [[SimpleTwitter alloc] init];
</pre> 

If you feel your attention wavering (already), fear not! You're already halfway done with the tutorial!

Posting to Facebook is almost as hard as constructing the Facebook object to begin with:

<pre>
[facebook postText:@"Hello, world!"];
</pre>

And... that's about it... SimplySocial takes care of all the rest!

There are (of course) a couple pretty straightforward protocol delegates that you can implement, if you care to listen for callbacks from the remote Web services (most people usually do). 

I'll gloss over that here, assuming that most people reading this know what they're doing when they program a protocol delegate.

The one thing about the delegates worth pointing out here is that they both have a required attribute called "targetViewController" -- it's important that you furnish the delegate with a target UIViewController in which to render the OAuth login screens sent by Facebook and Twitter. Otherwise, we have no way to display these login screens to the user, and consequently there is no way for your users to authenticate themselves to Facebook and Twitter.

Running the Sample Code
-----------------------

The quickest way to get the sample code in this project to compile and run is to configure the compiler flags listed above with those corresponding to your own social apps:

<pre>
#define _kSIMPLE_FACEBOOK_API_KEY                   @"YOUR-FACEBOOK-API-KEY"

#define _kSIMPLE_TWITTER_CONSUMER_KEY               @"YOUR-TWITTER-CONSUMER-KEY"
#define _kSIMPLE_TWITTER_CONSUMER_SECRET            @"YOUR-TWITTER-CONSUMER-SECRET"
#define _kSIMPLE_TWITTER_CALLBACK_URL               @"YOUR-TWITTER-CALLBACK-URL"
</pre>

This was mentioned above, but just in case people are skimming and not reading, there it is again.

Self-Indulgent SoundFX
------------------------

The native iOS implementations of Facebook and Twitter make a cool "door hinge" noise whenever the target media is finally uploaded to the remote Web service.

iOS also does this when sending email.

This has inspired us to include a gratuitous sound effect that plays whenever the posting of target media to the remote Web service is successful. Feel free to replace our gratuitous sound effect with another of your liking, possibly with the iconic iOS "door hinge" sound itself, or just turn this feature off completely if you find it to be incredibly, obtrusively obnoxious and annoying.

To enable the gratuitous sound effect, make sure the following compiler flag is set to true:

<pre>
#define _kSIMPLY_SOCIAL_USE_SOUND                 1
</pre>

and be sure that the boolean "useSound" attribute on your SimplySocial object is set to true.

To turn the gratuitous sound effect feature off, just set the compiler flag above to 0.

Version History
--------------- 

**Version 1.0** @ April 2, 2013
<ul>
<li>Initial release.</li>
</ul>

*Produced in cooperation with [Dae Myung](https://github.com/myung).*