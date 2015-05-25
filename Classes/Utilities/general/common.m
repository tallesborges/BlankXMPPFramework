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

#import "common.h"
#import "WelcomeView.h"
#import "PremiumView.h"
#import "NavigationController.h"
#import "AppDelegate.h"
#import "XMPPSample.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
void LoginUser(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	NavigationController *navigationController = [[NavigationController alloc] initWithRootViewController:[[WelcomeView alloc] init]];
	[target presentViewController:navigationController animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
bool UserLogged()
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [XMPPSample currentUser] != nil;
}
//-------------------------------------------------------------------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PresentPremium(id target)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[target presentViewController:[[PremiumView alloc] init] animated:YES completion:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
void PostNotification(NSString *notification)
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
	[[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

//- (iPhoneXMPPAppDelegate *)appDelegate
//{
//return (iPhoneXMPPAppDelegate *)[[UIApplication sharedApplication] delegate];
//}