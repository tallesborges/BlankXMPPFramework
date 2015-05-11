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

static const int ddLogLevel = LOG_LEVEL_VERBOSE;

@interface AppDelegate ()

@end

@implementation AppDelegate {
    NSString *_password;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLogLevel:XMPP_LOG_FLAG_SEND_RECV];

    [self setupStream];
    [self connect];

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

    // Setup roster
    //
    // The XMPPRoster handles the xmpp protocol stuff related to the roster.
    // The storage for the roster is abstracted.
    // So you can use any storage mechanism you want.
    // You can store it all in memory, or use core data and store it on disk, or use core data with an in-memory store,
    // or setup your own using raw SQLite, or create your own storage mechanism.
    // You can do it however you like! It's your application.
    // But you do need to provide the roster with some storage facility.

    _xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
//	xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc] initWithInMemoryStore];

    _xmppRoster = [[XMPPRoster alloc] initWithRosterStorage:_xmppRosterStorage];

    _xmppRoster.autoFetchRoster = YES;
    _xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;

    // Setup vCard support
    //
    // The vCard Avatar module works in conjuction with the standard vCard Temp module to download user avatars.
    // The XMPPRoster will automatically integrate with XMPPvCardAvatarModule to cache roster photos in the roster.
    _xmppvCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _xmppvCardTempModule = [[XMPPvCardTempModule alloc] initWithvCardStorage:_xmppvCardStorage];
    _xmppvCardAvatarModule = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_xmppvCardTempModule];

//    // Setup capabilities
//    //
//    // The XMPPCapabilities module handles all the complex hashing of the caps protocol (XEP-0115).
//    // Basically, when other clients broadcast their presence on the network
//    // they include information about what capabilities their client supports (audio, video, file transfer, etc).
//    // But as you can imagine, this list starts to get pretty big.
//    // This is where the hashing stuff comes into play.
//    // Most people running the same version of the same client are going to have the same list of capabilities.
//    // So the protocol defines a standardized way to hash the list of capabilities.
//    // Clients then broadcast the tiny hash instead of the big list.
//    // The XMPPCapabilities protocol automatically handles figuring out what these hashes mean,
//    // and also persistently storing the hashes so lookups aren't needed in the future.
//    //
//    // Similarly to the roster, the storage of the module is abstracted.
//    // You are strongly encouraged to persist caps information across sessions.
//    //
//    // The XMPPCapabilitiesCoreDataStorage is an ideal solution.
//    // It can also be shared amongst multiple streams to further reduce hash lookups.
//
    _xmppCapabilitiesStorage = [XMPPCapabilitiesCoreDataStorage sharedInstance];
    _xmppCapabilities = [[XMPPCapabilities alloc] initWithCapabilitiesStorage:_xmppCapabilitiesStorage];

    _xmppCapabilities.autoFetchHashedCapabilities = YES;
    _xmppCapabilities.autoFetchNonHashedCapabilities = NO;

    // Activate xmpp modules

    [_xmppReconnect activate:_xmppStream];
    [_xmppRoster activate:_xmppStream];
    [_xmppvCardTempModule activate:_xmppStream];
    [_xmppvCardAvatarModule activate:_xmppStream];
    [_xmppCapabilities      activate:_xmppStream];

    // Add ourself as a delegate to anything we may be interested in

    [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];

    [_xmppStream setHostName:@"localhost"];
//    [_xmppStream setHostPort:5222];
}

- (BOOL)connect {
    if (![_xmppStream isDisconnected]) {
        return YES;
    }

    NSString *myJID = @"talles@localhost/xmppFramework";
    NSString *myPassword = @"123456";

    _password = myPassword;

    if (myJID == nil || myPassword == nil) {
        return NO;
    }

    [_xmppStream setMyJID:[XMPPJID jidWithString:myJID]];

    NSError *error = nil;
    if (![_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        DDLogError(@"Error connecting: %@", error);
        return NO;
    }

    return YES;
}


#pragma mark - XMPPStreamDelegate

- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq {
    DDLogVerbose(@"%@ : %@ :%@", THIS_FILE, THIS_METHOD, iq);
    return NO;
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    DDLogVerbose(@"%@ : %@ :%@", THIS_FILE, THIS_METHOD, message);
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    DDLogVerbose(@"%@ : %@ :%@", THIS_FILE, THIS_METHOD, presence);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error {
    DDLogVerbose(@"%@ : %@ :%@", THIS_FILE, THIS_METHOD, error);
}

- (void)xmppStream:(XMPPStream *)sender socketDidConnect:(GCDAsyncSocket *)socket {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStream:(XMPPStream *)sender didReceiveTrust:(SecTrustRef)trust
 completionHandler:(void (^)(BOOL shouldTrustPeer))completionHandler {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

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

- (void)xmppStreamDidSecure:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);

    NSError *error = nil;

    if (![[self xmppStream] authenticateWithPassword:_password error:&error]) {
        DDLogError(@"Error authenticating: %@", error);
    }
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
    [self goOnline];
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    DDLogVerbose(@"%@: %@", THIS_FILE, THIS_METHOD);
}

- (void)goOnline
{
    XMPPPresence *presence = [XMPPPresence presence]; // type="available" is implicit

    NSString *domain = [_xmppStream.myJID domain];

    //Google set their presence priority to 24, so we do the same to be compatible.

    if([domain isEqualToString:@"gmail.com"]
            || [domain isEqualToString:@"gtalk.com"]
            || [domain isEqualToString:@"talk.google.com"])
    {
        NSXMLElement *priority = [NSXMLElement elementWithName:@"priority" stringValue:@"24"];
        [presence addChild:priority];
    }

    [[self xmppStream] sendElement:presence];
}

@end
