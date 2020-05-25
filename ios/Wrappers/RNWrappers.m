//
//  RNWrappers.m
//  RNJudo
//
//  Copyright (c) 2020 Alternative Payments Ltd
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

#import "RNWrappers.h"
#import "RNApplePayWrappers.h"
#import "RNTypes.h"
#import "NSDictionary+JudoConvert.h"
#import "UIColor+RNAdditions.h"

@implementation RNWrappers

//---------------------------------------------------
// MARK: - Public methods
//---------------------------------------------------

+ (JudoKit *)judoSessionFromProperties:(NSDictionary *)properties {
    NSString *token = [properties stringForKey:@"token"];
    NSString *secret = [properties stringForKey:@"secret"];
    BOOL isSandboxed = [properties boolForKey:@"sandboxed"];

    JudoKit *judoKit = [[JudoKit alloc] initWithToken:token secret:secret];
    judoKit.isSandboxed = isSandboxed;

    return judoKit;
}

+ (JPTransactionType)transactionTypeFromProperties:(NSDictionary *)properties {
    int type = [properties numberForKey:@"transactionType"].intValue;

    NSArray<NSNumber *> *availableTypes = @[
        @(JPTransactionTypePayment),
        @(JPTransactionTypePreAuth),
        @(JPTransactionTypeRegisterCard),
        @(JPTransactionTypeCheckCard),
        @(JPTransactionTypeSaveCard)
    ];

    return availableTypes[type].intValue;
}

+ (JPTransactionMode)transactionModeFromProperties:(NSDictionary *)properties {
    int intType = [properties numberForKey:@"transactionMode"].intValue;
    NSArray<NSNumber *> *availableModes = @[
        @(JPTransactionModePayment),
        @(JPTransactionModePreAuth),
        @(JPTransactionModeServerToServer)
    ];
    
    return availableModes[intType].intValue;
}

+ (JPConfiguration *)configurationFromProperties:(NSDictionary *)properties {

    NSDictionary *configurationDict = [properties dictionaryForKey:@"configuration"];
    
    NSString *judoId = [configurationDict stringForKey:@"judoId"];
    JPAmount *amount = [RNWrappers amountFromConfiguration:configurationDict];
    JPReference *reference = [RNWrappers referenceFromConfiguration:configurationDict];

    JPConfiguration *configuration = [[JPConfiguration alloc] initWithJudoID:judoId
                                                                      amount:amount
                                                                   reference:reference];

    configuration.siteId = [configurationDict optionalStringForKey:@"siteId"];
    configuration.uiConfiguration = [RNWrappers uiConfigurationFromConfiguration:configurationDict];
    configuration.supportedCardNetworks = [RNWrappers cardNetworksFromConfiguration:configurationDict];
    configuration.primaryAccountDetails = [RNWrappers accountDetailsFromConfiguration:configurationDict];
    configuration.cardAddress = [RNWrappers cardAddressFromConfiguration:configurationDict];
    configuration.paymentMethods = [RNWrappers paymentMethodsFromConfiguration:configurationDict];
    configuration.applePayConfiguration = [RNApplePayWrappers applePayConfigurationFromConfiguration:configurationDict];
    return configuration;
}

+ (JPCardNetworkType)cardNetworksFromConfiguration:(NSDictionary *)configuration {

    int bitmask = [configuration numberForKey:@"supportedCardNetworks"].intValue;

    if (BitmaskContains(bitmask, IOSCardNetworkAll)) {
        return JPCardNetworkTypeAll;
    }

    JPCardNetworkType networks = JPCardNetworkTypeUnknown;

    if (BitmaskContains(bitmask, IOSCardNetworkVisa)) {
        networks |= JPCardNetworkTypeVisa;
    }

    if (BitmaskContains(bitmask, IOSCardNetworkMastercard)) {
        networks |= JPCardNetworkTypeMasterCard;
    }

    if (BitmaskContains(bitmask, IOSCardNetworkMaestro)) {
        networks |= JPCardNetworkTypeMaestro;
    }

    if (BitmaskContains(bitmask, IOSCardNetworkAmex)) {
        networks |= JPCardNetworkTypeAMEX;
    }

    if (BitmaskContains(bitmask, IOSCardNetworkChinaUnionPay)) {
        networks |= JPCardNetworkTypeChinaUnionPay;
    }

    if (BitmaskContains(bitmask, IOSCardNetworkJCB)) {
        networks |= JPCardNetworkTypeJCB;
    }

    if (BitmaskContains(bitmask, IOSCardNetworkDiscover)) {
        networks |= JPCardNetworkTypeDiscover;
    }

    if (BitmaskContains(bitmask, IOSCardNetworkDinersClub)) {
        networks |= JPCardNetworkTypeDinersClub;
    }

    return networks;
}

//---------------------------------------------------
// MARK: - Helper methods
//---------------------------------------------------

+ (JPAmount *)amountFromConfiguration:(NSDictionary *)configuration {
    NSDictionary *dictionary = [configuration dictionaryForKey:@"amount"];
    NSString *amount = [dictionary stringForKey:@"value"];
    NSString *currency = [dictionary stringForKey:@"currency"];
    return [JPAmount amount:amount currency:currency];
}

+ (JPReference *)referenceFromConfiguration:(NSDictionary *)configuration {
    NSDictionary *dictionary = [configuration dictionaryForKey:@"reference"];
    NSString *consumerReference = [dictionary stringForKey:@"consumerReference"];
    NSString *paymentReference = [dictionary stringForKey:@"paymentReference"];

    JPReference *reference = [[JPReference alloc] initWithConsumerReference:consumerReference
                                                           paymentReference:paymentReference];

    reference.metaData = [dictionary optionalDictionaryForKey:@"metadata"];
    return reference;
}

+ (NSArray<JPPaymentMethod *> *)paymentMethodsFromConfiguration:(NSDictionary *)configuration {
    int bitmask = [configuration numberForKey:@"paymentMethods"].intValue;

    if (BitmaskContains(bitmask, IOSPaymentMethodAll)) {
        return @[JPPaymentMethod.card, JPPaymentMethod.applePay, JPPaymentMethod.iDeal];
    }

    NSMutableArray<JPPaymentMethod *> *paymentMethods = [NSMutableArray new];

    if (BitmaskContains(bitmask, IOSPaymentMethodCard)) {
        [paymentMethods addObject:JPPaymentMethod.card];
    }

    if (BitmaskContains(bitmask, IOSPaymentMethodApplePay)) {
        [paymentMethods addObject:JPPaymentMethod.applePay];
    }

    if (BitmaskContains(bitmask, IOSPaymentMethodIDEAL)) {
        [paymentMethods addObject:JPPaymentMethod.iDeal];
    }

    return paymentMethods;
}

+ (JPAddress *)cardAddressFromConfiguration:(NSDictionary *)configuration {
    NSDictionary *addressDictionary = [configuration optionalDictionaryForKey:@"cardAddress"];
    return [[JPAddress alloc] initWithLine1:[addressDictionary optionalStringForKey:@"line1"]
                                      line2:[addressDictionary optionalStringForKey:@"line2"]
                                      line3:[addressDictionary optionalStringForKey:@"line3"]
                                       town:[addressDictionary optionalStringForKey:@"town"]
                                countryCode:[addressDictionary optionalNumberForKey:@"countryCode"]
                                   postCode:[addressDictionary optionalStringForKey:@"postCode"]];
}

+ (JPUIConfiguration *)uiConfigurationFromConfiguration:(NSDictionary *)configuration {
    JPUIConfiguration *uiConfiguration = [JPUIConfiguration new];

    NSDictionary *dictionary = [configuration optionalDictionaryForKey:@"uiConfiguration"];

    if (!dictionary) {
        // Keep the default configurations
        return uiConfiguration;
    }

    NSNumber *isAVSEnabled = [dictionary boolForKey:@"isAVSEnabled"];
    NSNumber *isPayButtonAmountVisible = [dictionary boolForKey:@"isPayButtonAmountVisible"];
    NSNumber *shouldDisplayAmount = [dictionary boolForKey:@"shouldDisplayAmount"];

    uiConfiguration.isAVSEnabled = isAVSEnabled.boolValue;
    uiConfiguration.shouldDisplayAmount = shouldDisplayAmount.boolValue;

    //TODO: Add once native side is finished
    //uiConfiguration.isPayButtonAmountVisible = isPayButtonAmountVisible.boolValue;

    uiConfiguration.theme = [self themeFromUIConfiguration:dictionary];

    return uiConfiguration;
}

+ (JPTheme *)themeFromUIConfiguration:(NSDictionary *)uiConfiguration {
    JPTheme *theme = [JPTheme new];

    NSDictionary *dictionary = [uiConfiguration optionalDictionaryForKey:@"theme"];

    if (!dictionary) {
        return theme;
    }

    theme.largeTitle = [UIFont fontWithName:[dictionary stringForKey:@"largeTitleFont"]
                                       size:[[dictionary numberForKey:@"largeTitleSize"] doubleValue]];

    theme.title = [UIFont fontWithName:[dictionary stringForKey:@"titleFont"]
                                  size:[[dictionary numberForKey:@"titleSize"] doubleValue]];

    theme.headline = [UIFont fontWithName:[dictionary stringForKey:@"headlineFont"]
                                     size:[[dictionary numberForKey:@"headlineSize"] doubleValue]];

    theme.headlineLight = [UIFont fontWithName:[dictionary stringForKey:@"headlineLightFont"]
                                          size:[[dictionary numberForKey:@"headlineLightSize"] doubleValue]];

    theme.body = [UIFont fontWithName:[dictionary stringForKey:@"bodyFont"]
                                 size:[[dictionary numberForKey:@"bodySize"] doubleValue]];

    theme.bodyBold = [UIFont fontWithName:[dictionary stringForKey:@"bodyBoldFont"]
                                     size:[[dictionary numberForKey:@"bodyBoldSize"] doubleValue]];

    theme.caption = [UIFont fontWithName:[dictionary stringForKey:@"captionFont"]
                                    size:[[dictionary numberForKey:@"captionSize"] doubleValue]];

    theme.captionBold = [UIFont fontWithName:[dictionary stringForKey:@"captionBoldFont"]
                                        size:[[dictionary numberForKey:@"captionBoldSize"] doubleValue]];
    
    theme.jpBlackColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"jpBlackColor"]];
    theme.jpDarkGrayColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"jpDarkGrayColor"]];
    theme.jpGrayColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"jpGrayColor"]];
    theme.jpLightGrayColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"jpLightGrayColor"]];
    theme.jpRedColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"jpRedColor"]];
    theme.jpWhiteColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"jpWhiteColor"]];
    theme.buttonColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"buttonColor"]];
    theme.buttonTitleColor = [UIColor colorFromHexString:[dictionary hexColorForKey:@"buttonTitleColor"]];
    theme.backButtonImage = [UIImage imageNamed:[dictionary stringForKey:@"backButtonImage"]];
    theme.buttonCornerRadius = [[dictionary numberForKey:@"buttonCornerRadius"] doubleValue];
    
    return theme;
}

+ (JPPrimaryAccountDetails *)accountDetailsFromConfiguration:(NSDictionary *)configuration {
    NSDictionary *accountDetailsDictionary = [configuration optionalDictionaryForKey:@"primaryAccountDetails"];
    
    JPPrimaryAccountDetails *details = [JPPrimaryAccountDetails new];
    details.name = [accountDetailsDictionary optionalStringForKey:@"name"];
    details.accountNumber = [accountDetailsDictionary optionalStringForKey:@"accountNumber"];
    details.dateOfBirth = [accountDetailsDictionary optionalStringForKey:@"dateOfBirth"];
    details.postCode = [accountDetailsDictionary optionalStringForKey:@"postCode"];
    
    return details;
}

@end
