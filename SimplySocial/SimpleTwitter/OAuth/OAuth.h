//
//  OAuth.h
//
//  Created by Jaanus Kase on 12.01.10.
//  Copyright 2010. All rights reserved.
//

#import "SimpleHeaders.h"  // added by psholtz to support dynamic weak-linking

#import "OAuthTwitterCallbacks.h"

@interface OAuth : NSObject
{
    NSString *oauth_consumer_key;
    NSString *oauth_consumer_secret;
	NSString *oauth_signature_method;
	NSString *oauth_timestamp;
    NSString *oauth_nonce;
	NSString *oauth_version;
	
    NSString *oauth_token;
    NSString *oauth_token_secret;
    
	NSString *user_id;
	NSString *screen_name;
}

@property (nonatomic, SIMPLE_WEAK) id <OAuthTwitterCallbacks> delegate;

- (id)initWithConsumerKey:(NSString *)aConsumerKey andConsumerSecret:(NSString *)aConsumerSecret;
- (NSString *)oAuthHeaderForMethod:(NSString *)method andUrl:(NSString *)url andParams:(NSDictionary *)params;
- (void) forget;
- (void) synchronousRequestTwitterTokenWithCallbackUrl:(NSString *)callbackUrl;
- (void) synchronousAuthorizeTwitterTokenWithVerifier:(NSString *)oauth_verifier;
- (BOOL) synchronousVerifyTwitterCredentials;

- (NSString *) oAuthHeaderForMethod:(NSString *)method andUrl:(NSString *)url andParams:(NSDictionary *)params andTokenSecret:(NSString *)token_secret;
- (NSString *) oauth_signature_base:(NSString *)httpMethod withUrl:(NSString *)url andParams:(NSDictionary *)params;
- (NSString *) oauth_authorization_header:(NSString *)oauth_signature withParams:(NSDictionary *)params;
- (NSString *) sha1:(NSString *)str;
- (NSArray *) oauth_base_components;


@property (assign) BOOL oauth_token_authorized;
@property (readonly,copy) NSString *oauth_consumer_key; // added by psholtz for validation purposes
@property (copy) NSString *oauth_token;
@property (copy) NSString *oauth_token_secret;
@property (copy) NSString *user_id;
@property (copy) NSString *screen_name;

@end

