//
// Created by RVSLabs on 15/05/15.
// Copyright (c) 2015 RVSLabs. All rights reserved.
//

#import <libPhoneNumber-iOS/NBPhoneNumberUtil.h>
#import <libPhoneNumber-iOS/NBPhoneNumber.h>
#import "XMPPSample.h"
#import "XMPPStream.h"
#import "UIKit/UIKit.h"
#import "AppDelegate.h"
#import "XMPPJID.h"
@import CoreLocation;

#import <CoreLocation/CoreLocation.h>


@interface XMPPSample() <CLLocationManagerDelegate>

@property XMPPJID *userJID;
@property NBPhoneNumberUtil *phoneUtil;
@property CLLocationManager *locationManager;
@property CLLocation *location;

@end

@implementation XMPPSample {

}

+ (XMPPSample *)instance {
    static XMPPSample *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.phoneUtil = [NBPhoneNumberUtil new];
            [_instance startStandardUpdates];
        }
    }

    return _instance;
}

+(XMPPJID *) currentUser {
    if (![self instance].userJID) {
        return [XMPPJID jidWithUser:[[NSUserDefaults standardUserDefaults] objectForKey:@"user"] domain:@"localhost" resource:nil];
    }
    return [self instance].userJID;
}

+(void) setCurrentUser:(XMPPJID *)userJID {
    [self instance].userJID = userJID;
}

+(XMPPStream *) currentXMPPStream {
    AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
    return appDelegate.xmppStream;
}

+(NBPhoneNumber *) myNBPhoneNumber {
    NSString *userNumber = [[NSUserDefaults standardUserDefaults] objectForKey:@"user"];
    NBPhoneNumber *myPhoneNumber = [[self instance].phoneUtil parseWithPhoneCarrierRegion:userNumber error:nil];
    return myPhoneNumber;
}

+(NSString *) convertNumberToUserNDCNumber:(NSString *) numberString {
    NBPhoneNumberUtil *phoneUtil = [self instance].phoneUtil;
    NBPhoneNumber *myNumber = [self myNBPhoneNumber];

    NSUInteger ndcLength = (NSUInteger) [phoneUtil getLengthOfNationalDestinationCode:myNumber error:nil];
    NSString *myNDC = [[[myNumber nationalNumber] stringValue] substringToIndex:ndcLength];

    return [NSString stringWithFormat:@"%@%@",myNDC,numberString];
}

+(BOOL) isValidNumber:(NSString *)numberString {
    NBPhoneNumberUtil *phoneUtil = [self instance].phoneUtil;
    return [phoneUtil isValidNumber:[phoneUtil parseWithPhoneCarrierRegion:numberString error:nil]];
}

+(NSString *) formatedNumber:(NSString *) numberString {
    NBPhoneNumberUtil *phoneUtil = [self instance].phoneUtil;
    NBPhoneNumber *phoneNumber = [phoneUtil parseWithPhoneCarrierRegion:numberString error:nil];
    return [phoneUtil format:phoneNumber numberFormat:NBEPhoneNumberFormatINTERNATIONAL error:nil];
}

+(NSString *) jidFromNUmber:(NSString *) numberString {
    NSString *formattedNumber = [self formatedNumber:numberString];
    NSString *newString = [[formattedNumber componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
    return newString;
}

#pragma mark - CoreLocation

// Start Update
- (void)startStandardUpdates
{
    if (nil == _locationManager)
        _locationManager = [[CLLocationManager alloc] init];

    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;

    [self.locationManager requestWhenInUseAuthorization];

    // Set a movement threshold for new events.
    _locationManager.distanceFilter = 500; // meters

    [_locationManager startUpdatingLocation];
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",
                location.coordinate.latitude,
                location.coordinate.longitude);

        _location = location;
        [self sendLocationToServer];
    }
}

-(void) sendLocationToServer {
    if(!_location) return;

    NSXMLElement *item = [NSXMLElement elementWithName:@"item"];
    [item addAttributeWithName:@"user" stringValue:[XMPPSample currentUser].user];
    [item addAttributeWithName:@"lat" stringValue:[NSString stringWithFormat:@"%f",_location.coordinate.latitude]];
    [item addAttributeWithName:@"lon" stringValue:[NSString stringWithFormat:@"%f",_location.coordinate.longitude]];

    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"com.nodexy.im.openfire.location"];
    [query addChild:item];

    XMPPStream *xmppStream = [XMPPSample currentXMPPStream];
    XMPPIQ *xmppiq = [XMPPIQ iqWithType:@"set" elementID:[xmppStream generateUUID] child:query];
    [xmppiq addAttributeWithName:@"from" stringValue:[XMPPSample currentUser].full];
    [xmppStream sendElement:xmppiq];
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error {
    DDLogError(@"%@",error);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    DDLogError(@"%@",error);
}

@end