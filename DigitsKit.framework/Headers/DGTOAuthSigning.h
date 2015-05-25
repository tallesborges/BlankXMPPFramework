//
//  DGTOAuthSigning.h
//  DigitsKit
//
//  Copyright (c) 2015 Twitter Inc. All rights reserved.
//

#import <TwitterCore/TWTRCoreOAuthSigning.h>

@class TWTRAuthConfig;
@class DGTSession;

@interface DGTOAuthSigning : NSObject <TWTRCoreOAuthSigning>

/**
 *  @name Initialization
 */

/**
 *  Instantiate a `DGTOAuthSigning` object with the parameters it needs to generate the OAuth signatures.
 *
 *  @param authConfig       (required) Encapsulates credentials required to authenticate a Digits application.
 *  @param authSession      (required) Encapsulated credentials associated with a user session.
 *
 *  @return An initialized `DGTOAuthSigning` object or nil if any of the parameters are missing.
 *
 *  @see TWTRAuthConfig
 *  @see DGTSession
 */
- (instancetype)initWithAuthConfig:(TWTRAuthConfig *)authConfig authSession:(DGTSession *)authSession NS_DESIGNATED_INITIALIZER;

/**
 *  Unavailable. Use `-initWithAuthConfig:authSession:` instead.
 */
- (instancetype)init __attribute__((unavailable("Use -initWithAuthConfig:authSession: instead.")));

@end