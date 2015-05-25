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


@interface XMPPSample()

@property XMPPJID *userJID;
@property NBPhoneNumberUtil *phoneUtil;

@end

@implementation XMPPSample {

}

+ (XMPPSample *)instance {
    static XMPPSample *_instance = nil;

    @synchronized (self) {
        if (_instance == nil) {
            _instance = [[self alloc] init];
            _instance.phoneUtil = [NBPhoneNumberUtil new];
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

@end