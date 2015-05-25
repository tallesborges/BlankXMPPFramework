//
// Created by RVSLabs on 21/05/15.
// Copyright (c) 2015 RVSLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "JSQMessagesViewController.h"

@class XMPPJID;


@interface MucChatView : JSQMessagesViewController <NSFetchedResultsControllerDelegate>

@property(nonatomic, strong) XMPPJID *roomJID;

- (instancetype)initWithUserJID:(XMPPJID *)userJID;
@end