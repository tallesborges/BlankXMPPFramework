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

//#import <Parse/Parse.h>
#import <CoreData/CoreData.h>
#import <AddressBook/AddressBook.h>
#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import <libPhoneNumber-iOS/NBPhoneNumber.h>
#import "ProgressHUD.h"

//#import "AppConstant.h"
#import "common.h"
#import "recent.h"

#import "PeopleView.h"
#import "ChatView.h"
#import "SelectSingleView.h"
#import "SelectMultipleView.h"
#import "AddressBookView.h"
#import "FacebookFriendsView.h"
#import "NavigationController.h"
#import "UIAlertView+AFNetworking.h"
#import "DDLog.h"
#import "AppDelegate.h"
#import "XMPPSample.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface PeopleView () {
    NSMutableArray *users;
}
@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation PeopleView

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    {
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_people"]];
        self.tabBarItem.title = @"People";
    }
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    self.title = @"People";
    //---------------------------------------------------------------------------------------------------------------------------------------------
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
                                                                                           action:@selector(actionAdd)];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    users = [[NSMutableArray alloc] init];

    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, nil);
    ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) [self loadAddressBook];
        });
    });
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionChat:(NSString *)groupId
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    ChatView *chatView = [[ChatView alloc] initWith:groupId];
    chatView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionAdd
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Informe o numero que deseja adicionar" delegate:self cancelButtonTitle:@"Cancelar" otherButtonTitles:@"Adicionar", nil];
    alertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alertView show];
}

#pragma mark - UIAlertDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != alertView.cancelButtonIndex) {
        [users addObject:[alertView textFieldAtIndex:0].text];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 1;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [users count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    NSDictionary *user = users[indexPath.row];

    cell.textLabel.text = user[@"name"];
    cell.detailTextLabel.text = [XMPPSample formatedNumber:user[@"phones"][0]];

//    NSString *possibleNumber = [phoneUtil extractPossibleNumber:[[phoneNumber nationalNumber] stringValue]];
//
//    if (![phoneUtil isValidNumber:phoneNumber]) {
//        NBPhoneNumber *myPhoneNumber = [phoneUtil parseWithPhoneCarrierRegion:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] error:nil];
//        int ndcLength = [phoneUtil getLengthOfNationalDestinationCode:myPhoneNumber error:nil];
//        NSString *myNDC = [[[myPhoneNumber nationalNumber] stringValue] substringToIndex:ndcLength];
//
//        NSString *newNumber = [NSString stringWithFormat:@"%@%@", myNDC, possibleNumber];
//
//        NBPhoneNumber *newPhoneNumber = [phoneUtil parseWithPhoneCarrierRegion:newNumber error:nil];
//        cell.detailTextLabel.text = [phoneUtil format:newPhoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil];
//    }

    return cell;
}

#pragma mark - Table view delegate
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    NSString *phoneNumber = users[indexPath.row][@"phones"][0];
    [self actionChat:[XMPPSample jidFromNUmber:phoneNumber]];
}

#pragma mark - Load Users

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadAddressBook
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        CFErrorRef *error = NULL;
        ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, error);
        ABRecordRef sourceBook = ABAddressBookCopyDefaultSource(addressBook);
        CFArrayRef allPeople = ABAddressBookCopyArrayOfAllPeopleInSourceWithSortOrdering(addressBook, sourceBook, kABPersonFirstNameProperty);
        CFIndex personCount = CFArrayGetCount(allPeople);

        [users removeAllObjects];
        for (int i = 0; i < personCount; i++) {
            ABMultiValueRef tmp;
            ABRecordRef person = CFArrayGetValueAtIndex(allPeople, i);

            NSString *first = @"";
            tmp = ABRecordCopyValue(person, kABPersonFirstNameProperty);
            if (tmp != nil) first = [NSString stringWithFormat:@"%@", tmp];

            NSString *last = @"";
            tmp = ABRecordCopyValue(person, kABPersonLastNameProperty);
            if (tmp != nil) last = [NSString stringWithFormat:@"%@", tmp];

            NSMutableArray *emails = [[NSMutableArray alloc] init];
            ABMultiValueRef multi1 = ABRecordCopyValue(person, kABPersonEmailProperty);
            for (CFIndex j = 0; j < ABMultiValueGetCount(multi1); j++) {
                tmp = ABMultiValueCopyValueAtIndex(multi1, j);
                if (tmp != nil) [emails addObject:[NSString stringWithFormat:@"%@", tmp]];
            }

            NSMutableArray *phones = [[NSMutableArray alloc] init];
            ABMultiValueRef multi2 = ABRecordCopyValue(person, kABPersonPhoneProperty);
            for (CFIndex j = 0; j < ABMultiValueGetCount(multi2); j++) {
                tmp = ABMultiValueCopyValueAtIndex(multi2, j);
                if (tmp != nil){
                    NSString *number = [NSString stringWithFormat:@"%@", tmp];
                    if (![XMPPSample isValidNumber:number]) {
                        number = [XMPPSample convertNumberToUserNDCNumber:number];
                    }
                    if ([XMPPSample isValidNumber:number]) {
                        [phones addObject:number];
                    }
                }
            }

            NSString *name = [NSString stringWithFormat:@"%@ %@", first, last];
            if (phones.count > 0) {
                [users addObject:@{@"name" : name, @"emails" : emails, @"phones" : phones}];
            }
        }
        CFRelease(allPeople);
        CFRelease(addressBook);
        [self.tableView reloadData];
    }
}
@end
