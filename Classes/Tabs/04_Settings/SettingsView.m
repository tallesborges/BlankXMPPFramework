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

#import "ProgressHUD.h"

#import "camera.h"
#import "common.h"

#import "SettingsView.h"
#import "PrivacyView.h"
#import "TermsView.h"
#import "XMPPSample.h"
#import "XMPPStream.h"
#import "XMPPJID.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
@interface SettingsView ()

@property(strong, nonatomic) IBOutlet UIView *viewHeader;
//@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property(strong, nonatomic) IBOutlet UILabel *labelName;

@property(strong, nonatomic) IBOutlet UITableViewCell *cellPrivacy;
@property(strong, nonatomic) IBOutlet UITableViewCell *cellTerms;

@property(strong, nonatomic) IBOutlet UITableViewCell *cellLogout;

@end
//-------------------------------------------------------------------------------------------------------------------------------------------------

@implementation SettingsView

@synthesize viewHeader, labelName;
@synthesize cellPrivacy, cellTerms, cellLogout;

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self.tabBarItem setImage:[UIImage imageNamed:@"tab_settings"]];
        self.tabBarItem.title = @"Settings";
    }
    return self;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidLoad
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [super viewDidLoad];
    self.title = @"Settings";
    //---------------------------------------------------------------------------------------------------------------------------------------------
    self.tableView.tableHeaderView = viewHeader;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)viewDidAppear:(BOOL)animated
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self loadUser];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[XMPPSample instance] sendLocationToServer];
}


#pragma mark - Backend actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadUser {
    labelName.text = [XMPPSample currentUser].bare;
}

#pragma mark - User actions

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionPrivacy
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PrivacyView *privacyView = [[PrivacyView alloc] init];
    privacyView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:privacyView animated:YES];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionTerms
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    TermsView *termsView = [[TermsView alloc] init];
    termsView.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:termsView animated:YES];
}

- (void)actionCleanup {
    labelName.text = nil;
}

- (void)actionLogout {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:@"Log out" otherButtonTitles:nil];
    [action showFromTabBar:[[self tabBarController] tabBar]];
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        [[XMPPSample currentXMPPStream] disconnect];
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"user"];
        LoginUser(self);
    }
}

- (IBAction)actionPhoto:(id)sender {
    PresentPhotoLibrary(self, YES);
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) return 2;
    if (section == 1) return 1;
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0) && (indexPath.row == 0)) return cellPrivacy;
    if ((indexPath.section == 0) && (indexPath.row == 1)) return cellTerms;
    if ((indexPath.section == 1) && (indexPath.row == 0)) return cellLogout;
    return nil;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ((indexPath.section == 0) && (indexPath.row == 0)) [self actionPrivacy];
    if ((indexPath.section == 0) && (indexPath.row == 1)) [self actionTerms];
    if ((indexPath.section == 1) && (indexPath.row == 0)) [self actionLogout];
}

@end
