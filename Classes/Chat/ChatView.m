//
// Copyright (c) 2015 Related Code - http://relatedcode.com
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AFNetworking.h"

#import "AppDelegate.h"

#import "VideoMediaItem.h"

#import "ChatView.h"

@interface ChatView()<XMPPStreamDelegate>

@end

@implementation ChatView {
    BOOL initialized;
    XMPPStream *_xmppStream;

    JSQMessagesBubbleImage *_incomingBubbleImageData;
    JSQMessagesBubbleImage *_outgoingBubbleImageData;
    NSFetchedResultsController *_messagesController;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWith:(NSString *)userJID
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super init];
    _userJID = [XMPPJID jidWithUser:userJID domain:@"localhost" resource:nil];
    return self;
}

- (instancetype)initWithUserJID:(XMPPJID *)userJID {
    self = [super init];
    self.userJID = userJID;
    return self;
}

+ (instancetype)viewWithUserJID:(XMPPJID *)userJID {
    return [[self alloc] initWithUserJID:userJID];
}


//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    self.title = @"Chat";

    self.senderId = [XMPPSample currentUser].bare;
    self.senderDisplayName = [XMPPSample currentUser].bare;

    _xmppStream = [XMPPSample currentXMPPStream];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];

    _outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    _incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    XMPPMessageArchivingCoreDataStorage *storage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    NSManagedObjectContext *moc = [storage mainThreadManagedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject"
                                                         inManagedObjectContext:moc];

    NSFetchRequest *request = [[NSFetchRequest alloc]init];
    [request setEntity:entityDescription];
    [request setPredicate:[NSPredicate predicateWithFormat:@"(bareJidStr == %@) AND (streamBareJidStr == %@) AND (composing == %@)",_userJID.bare,[XMPPSample currentUser].bare,@(false)]];

    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp" ascending:YES];
    NSArray *sortDescriptors = @[sortDescriptor];
    [request setSortDescriptors:sortDescriptors];

    _messagesController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil];
    _messagesController.delegate = self;

    NSError *error;
    BOOL rval = [_messagesController performFetch:&error];
}

#pragma mark - JSQMessageViewControllerDelegate

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {

    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:_userJID];
    [message addBody:text];

    [_xmppStream sendElement:message];

    [self finishSendingMessageAnimated:YES];
}

#pragma mark - JSQMessageViewController DataSource

- (id <JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

    XMPPMessageArchiving_Message_CoreDataObject *message_coreDataObject = [_messagesController objectAtIndexPath:indexPath];

    NSString *sender;

    if (message_coreDataObject.isOutgoing) {
        sender = [XMPPSample currentUser].bare;
    }else {
        sender = message_coreDataObject.bareJidStr;
    }

    JSQMessage *jsqMessage = [JSQMessage messageWithSenderId:sender displayName:sender text:message_coreDataObject.message.body];

    return jsqMessage;
}


- (id <JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    XMPPMessageArchiving_Message_CoreDataObject *message_coreDataObject = [_messagesController objectAtIndexPath:indexPath];

    if (message_coreDataObject.isOutgoing) {
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
