//
// Created by RVSLabs on 15/05/15.
// Copyright (c) 2015 RVSLabs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMPPStream;
@class XMPPJID;

#define XMPP_SAMPLE_HOST @"192.168.100.12"

@interface XMPPSample : NSObject

+ (XMPPSample *)instance;

+ (XMPPJID *)currentUser;

+ (void)setCurrentUser:(XMPPJID *)userJID;

+ (XMPPStream *)currentXMPPStream;

+ (NSString *)convertNumberToUserNDCNumber:(NSString *)numberString;

+ (BOOL)isValidNumber:(NSString *)numberString;

+ (NSString *)formatedNumber:(NSString *)numberString;

+ (NSString *)jidFromNUmber:(NSString *)numberString;
@end