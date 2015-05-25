//
//  Digits.h
//
//  Copyright (c) 2015 Twitter. All rights reserved.
//

#import "DGTAppearance.h"
#import "DGTAuthenticateButton.h"
#import "DGTContactAccessAuthorizationStatus.h"
#import "DGTSession.h"
#import <TwitterCore/TWTRAuthConfig.h>

@class UIViewController;
@class TWTRAuthConfig;

/**
 *  The `Digits` class contains the main methods to implement the Digits authentication flow.
 *
 *  @warning You must first properly initialize the Twitter kit in order to use Digits. Consult the Twitter kit documentation for more information.
 */
@interface Digits : NSObject

/**
 *  Returns the unique Digits object (singleton).
 *
 *  @return The Digits singleton.
 */
+ (Digits *)sharedInstance;

/**
 *  Start Digits with your consumer key and secret. These will override any credentials
 *  present in your applications Info.plist.
 *
 *  You do not need to call this method unless you wish to provide credentials other than those
 *  in your Info.plist.
 *
 *  @param consumerKey    Your Digits application's consumer key.
 *  @param consumerSecret Your Digits application's consumer secret.
 */
- (void)startWithConsumerKey:(NSString *)consumerKey consumerSecret:(NSString *)consumerSecret;

/**
 *
 *  @return The Digits user session or nil if there's no authenticated user.
 */
- (DGTSession *)session;

/**
 *  Authentication configuration details. Encapsulates the `consumerKey` and `consumerSecret` credentials required to authenticate a Twitter application.
 */
@property (nonatomic, strong, readonly) TWTRAuthConfig *authConfig;

/**
 *  Starts the authentication flow UI with the standard appearance. The UI is presented as a modal off of the top-most view controller. The modal title is the application name.
 *
 *  @param completion Block called after the authentication flow has ended.
 */
- (void)authenticateWithCompletion:(DGTAuthenticationCompletion)completion;

/**
 *  Starts the authentication flow UI with the standard appearance. The UI is presented as a modal off of the top-most view controller.
 *
 *  @param title      Title for the modal screens. Pass `nil` to use default app name.
 *  @param completion Block called after the authentication flow has ended.
 */
- (void)authenticateWithTitle:(NSString *)title completion:(DGTAuthenticationCompletion)completion;

/**
 *  Starts the authentication flow UI with the standard appearance.
 *
 *  @param viewController    View controller used to present the modal authentication controller. Pass `nil` to use default top-most view controller.
 *  @param title             Title for the modal screens. Pass `nil` to use default app name.
 *  @param completion        Block called after the authentication flow has ended.
 */
- (void)authenticateWithViewController:(UIViewController *)viewController title:(NSString *)title completion:(DGTAuthenticationCompletion)completion;

/**
 *  Starts the authentication flow UI.
 *
 *  @param appearance        Appearance of the authentication flow views. Pass `nil` to use the default appearance.
 *  @param viewController    View controller used to present the modal authentication controller. Pass `nil` to use default top-most view controller.
 *  @param title             Title for the modal screens. Pass `nil` to use default app name.
 *  @param completion        Block called after the authentication flow has ended.
 */
- (void)authenticateWithDigitsAppearance:(DGTAppearance *)appearance viewController:(UIViewController *)viewController title:(NSString *)title completion:(DGTAuthenticationCompletion)completion;

/**
 *  Deletes the local Twitter user session from this app. This will not remove the system Twitter account nor make a network request to invalidate the session. Subsequent calls to `authenticateWith` methods will start a new Digits authentication flow.
 */
- (void)logOut;

@end
