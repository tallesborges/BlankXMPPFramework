//
//  AppDelegate.h
//  XMPPBlankProject
//
//  Created by RVSLabs on 11/05/15.
//  Copyright (c) 2015 RVSLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate,XMPPStreamDelegate,XMPPRosterDelegate>

#pragma mark - Window
@property (strong, nonatomic) UIWindow *window;

#pragma mark - XMPP
@property (nonatomic, strong, readonly) XMPPStream *xmppStream;
@property (nonatomic, strong, readonly) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong, readonly) XMPPRoster *xmppRoster;
@property (nonatomic, strong, readonly) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong, readonly) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic, strong, readonly) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic, strong, readonly) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic, strong, readonly) XMPPCapabilities *xmppCapabilities;
@property (nonatomic, strong, readonly) XMPPCapabilitiesCoreDataStorage *xmppCapabilitiesStorage;


@end

