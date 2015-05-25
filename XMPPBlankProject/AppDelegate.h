//
//  AppDelegate.h
//  XMPPBlankProject
//
//  Created by RVSLabs on 11/05/15.
//  Copyright (c) 2015 RVSLabs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"


static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate : UIResponder <UIApplicationDelegate,XMPPStreamDelegate,XMPPRosterDelegate,XMPPMUCDelegate>

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
@property (nonatomic, strong, readonly) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingStorage;
@property (nonatomic, strong, readonly) XMPPMessageArchiving *xmppMessageArchiving;
@property (nonatomic, strong, readonly) XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage;



- (BOOL)connect:(NSString *)user;

//----------------------------------------------------------------------------------------------------------------------
@property bool userIsLogged;

@property(nonatomic, strong) XMPPMUC *xmppmuc;
@end

