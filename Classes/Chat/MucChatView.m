//
// Created by RVSLabs on 21/05/15.
// Copyright (c) 2015 RVSLabs. All rights reserved.
//

#import "MucChatView.h"

#import "AppDelegate.h"
#import "JSQMessages.h"
#import "XMPPSample.h"
#import "XMPPJID.h"


@implementation MucChatView {
    BOOL initialized;
    XMPPStream *_xmppStream;

    JSQMessagesBubbleImage *_incomingBubbleImageData;
    JSQMessagesBubbleImage *_outgoingBubbleImageData;
    NSFetchedResultsController *_messagesController;
    XMPPRoom *_xmppRoom;
}


- (instancetype)initWithUserJID:(XMPPJID *)userJID {
    self = [super init];
    self.roomJID = userJID;
    return self;
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    self.title = @"Chat";

    self.senderId = [XMPPSample currentUser].bare;
    self.senderDisplayName = [XMPPSample currentUser].bare;

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];

    _outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    _incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    _xmppStream = [XMPPSample currentXMPPStream];

    XMPPRoomCoreDataStorage *xmppRoomCoreDataStorage = [XMPPRoomCoreDataStorage sharedInstance];
    _xmppRoom = [[XMPPRoom alloc] initWithRoomStorage:xmppRoomCoreDataStorage jid:_roomJID];
    [_xmppRoom activate:[XMPPSample currentXMPPStream]];

    [_xmppRoom joinRoomUsingNickname:[XMPPSample currentUser].bare history:nil];

    NSManagedObjectContext *moc = [xmppRoomCoreDataStorage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPRoomMessageCoreDataStorageObject"
                                                         inManagedObjectContext:moc];

    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"roomJIDStr == %@", _roomJID.bare]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"localTimestamp" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    _messagesController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    _messagesController.delegate = self;

    [_messagesController performFetch:nil];
}

#pragma mark - JSQMessageViewControllerDelegate

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {

    [_xmppRoom sendMessageWithBody:text];

    [self finishSendingMessageAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_xmppRoom deactivate];
}


#pragma mark - JSQMessageViewController DataSource
- (id <JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

    XMPPRoomMessageCoreDataStorageObject *message_coreDataObject = [_messagesController objectAtIndexPath:indexPath];

    NSString *sender;

    if (message_coreDataObject.isFromMe) {
        sender = [XMPPSample currentUser].bare;
    } else {
        sender = message_coreDataObject.jidStr;
    }

    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:sender displayName:sender text:message_coreDataObject.message.body];

    return jsqMessage;
}


- (id <JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    XMPPRoomMessageCoreDataStorageObject *message_coreDataObject = [_messagesController objectAtIndexPath:indexPath];

    if (message_coreDataObject.isFromMe) {
        return _outgoingBubbleImageData;
    }

    return _incomingBubbleImageData;
}

- (id <JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView DataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [_messagesController sections][section];
    return [sectionInfo numberOfObjects];
}


#pragma mark - XMPPStream Delegate
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self finishReceivingMessageAnimated:YES];
}

@end