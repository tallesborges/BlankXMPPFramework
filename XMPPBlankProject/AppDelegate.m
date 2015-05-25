//
//  AppDelegate.m
//  XMPPBlankProject
//
//  Created by RVSLabs on 11/05/15.
//  Copyright (c) 2015 RVSLabs. All rights reserved.
//

#import "AppDelegate.h"
#import "DDTTYLogger.h"
#import "DDASLLogger.h"
#import "AppConstant.h"
#import "NavigationController.h"
#import "SettingsView.h"
#import "PeopleView.h"
#import "GroupsView.h"
#import "RecentView.h"
#import "XMPPSample.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <DigitsKit/DigitsKit.h>


#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

@interface AppDelegate ()

@property RecentView *recentView;
@property GroupsView *groupsView;
@property PeopleView *peopleView;
@property SettingsView *settingsView;

@property UITabBarController *tabBarController;

@end

@implementation AppDelegate {
    NSString *_password;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [Fabric with:@[CrashlyticsKit, DigitsKit]];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [self setupStream];
//    [self connect];

    //-------------------------------------------------------------------------------------------------------------------------------------------------
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    self.recentView = [[RecentView alloc] init];
    self.groupsView = [[GroupsView alloc] init];
    self.peopleView = [[PeopleView alloc] init];
    self.settingsView = [[SettingsView alloc] init];

    NavigationController *navController1 = [[NavigationController alloc] initWithRootViewController:self.recentView];
    NavigationController *navController2 = [[NavigationController alloc] initWithRootViewController:self.groupsView];
    NavigationController *navController3 = [[NavigationController alloc] initWithRootViewController:self.peopleView];
    NavigationController *navController4 = [[NavigationController alloc] initWithRootViewController:self.settingsView];

    self.tabBarController = [[UITabBarController alloc] init];
    self.tabBarController.viewControllers = @[navController1, navController2, navController3, navController4];
    self.tabBarController.tabBar.translucent = NO;
    self.tabBarController.selectedIndex = DEFAULT_TAB;

    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    //-------------------------------------------------------------------------------------------------------------------------------------------------


    return YES;
}


- (void)setupStream {
    NSAssert(_xmppStream == nil, @"Method setupStream invoked multiple times");

    // Setup xmpp stream
    //
    // The XMPPStream is the base class for all activity.
    // Everything else plugs into the xmppStream, such as modules/extensions and delegates.

    _xmppStream = [[XMPPStream alloc] init];
    _xmppStream.enableBackgroundingOnSocket = YES;


    // Setup reconnect
    _xmppReconnect = [[XMPPReconnect alloc] init];


    //XMPPRoster
    _xmppRosterStorage = [XMPPRosterCoreDataStorage sharedInstance];
    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];

    _xmppRoster.autoFetchRoster = YES;
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

    // Setup vCard support
    _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];

    // XMPPCapabilities
    _xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesStorage];

    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    _xmppCapabilities.autoFetchNonHashedCapabilities = NO;

    // XMPPMessageArchiving
    _xmppMessageArchivingStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _xmppMessageArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_xmppMessageArchivingStorage];

    [_xmppMessageArchiving setClientSideMessageArchivingOnly:YES];

//   XMPPRoom
    _xmppRoomCoreDataStorage = [XMPPRoomCoreDataStorage sharedInstance];
    
//   XMPPMuc
    _xmppmuc = [[XMPPMUC alloc] init];

    // Activate xmpp modules
    [_xmppReconnect activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppvCardTempModule activate:_xmppStream];
    [_xmppvCardAvatarModule activate:_xmppStream];
    [_xmppCapabilities activate:_xmppStream];
    [_xmppMessageArchiving activate:_xmppStream];
    [_xmppmuc activate:_xmppStream];

    // Add ourself as a delegate to anything we may be interested in
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppMessageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppmuc addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [_xmppStream setHostName:XMPP_SAMPLE_HOST];
    [_xmppStream setHostPort:5222];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"user"]) {
        [self connect:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"]];
    }
}

- (BOOL)connect:(NSString *)user {
    [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"user"];

    if (![_xmppStream isDisconnected]) {
        return YES;
    }

    NSString *myPassword = @"123456";

    _password = myPassword;

    if (user == nil || myPassword == nil) {
        return NO;
    }

    [_xmppStream setMyJID:[XMPPJID jidWithUser:user domain:@"localhost" resource:@"xmppBlank"]];

    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        DDLogError(@"Error connecting: %@", error);
        return NO;
    }

    return YES;
}


#pragma mark - XMPPStreamDelegate
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {

}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {

}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error {
    DDLogVerbose(@"%@ : %@ :%@", THIS_FILE, THIS_METHOD, error);
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    // The delegate method should likely have code similar to this,
    // but will presumably perform some extra security code stuff.
    // For example, allowing a specific self-signed certificate that is known to the app.

    dispatch_queue_t bgQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(bgQueue, ^{

        SecTrustResultType result = kSecTrustResultDeny;
        OSStatus status = SecTrustEvaluate(trust, &result);

        completionHandler(status == noErr && (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified));
    });
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    [self authenticate];
}
- (void)authenticate {
    NSError *error = nil;
    if (![[self xmppStream] authenticateWithPassword:@"123456" error:&error]) {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    [self goOnline];
    [XMPPSample setCurrentUser:sender.myJID];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    [self register];
}

- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    DDLogVerbose(@"%@ : %@", THIS_FILE, THIS_METHOD);
    [self authenticate];
}


-(void) register {
    NSError *error = nil;
    if (![_xmppStream registerWithPassword:@"123456" error:&error]) {
        DDLogError(@"Error registering: %@", error);
    }
}

- (void)goOnline {
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit

    NSString *domain = [_xmppStream.myJID domain];

    //Google set their presence priority to 24, so we do the same to be compatible.

    if ([domain isEqualToString:@"gmail.com"]
            || [domain isEqualToString:@"gtalk.com"]
            || [domain isEqualToString:@"talk.google.com"]) {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }

    [[self xmppStream] sendElement:presence];
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error {
    DDLogError(@"%@ : %@ : %@", THIS_FILE, THIS_METHOD, error);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error {
    DDLogError(@"%@ : %@ : %@", THIS_FILE, THIS_METHOD, error);
}

- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error {
    DDLogError(@"%@ : %@ : %@", THIS_FILE, THIS_METHOD, error);
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    DDLogError(@"%@ : %@ : %@", THIS_FILE, THIS_METHOD, error);
    [XMPPSample setCurrentUser:nil];
}

#pragma mark - XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence {
    [_xmppRoster acceptPresenceSubscriptionRequestFrom:[presence from] andAddToRoster:YES];
}

#pragma mark - XMPPMUC
- (void)xmppMUC:(XMPPMUC *)sender roomJID:(XMPPJID *)roomJID didReceiveInvitation:(XMPPMessage *)message {

}


@end
