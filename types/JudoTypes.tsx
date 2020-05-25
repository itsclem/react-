import { JudoApplePayConfiguration } from './JudoApplePayTypes'
import { JudoGooglePayConfiguration } from './JudoGooglePayTypes'

export interface JudoConfiguration {
    judoId: string,
    amount: JudoAmount,
    reference: JudoReference,
    siteId?: string,
    cardAddress?: JudoAddress,
    uiConfiguration?: JudoUIConfiguration,
    paymentMethods?: JudoPaymentMethod,
    supportedCardNetworks?: JudoCardNetwork,
    primaryAccountDetails?: JudoAccountDetails,
    applePayConfiguration?: JudoApplePayConfiguration,
    googlePayConfiguration?: JudoGooglePayConfiguration,
}

export enum JudoTransactionType {
    Payment,
    PreAuth,
    RegisterCard,
    CheckCard,
    SaveCard,
}

export enum JudoTransactionMode {
    Payment,
    PreAuth,
    ServerToServer,
}

export interface JudoAmount {
    value: string,
    currency: string,
}

export interface JudoReference {
    consumerReference: string,
    paymentReference?: string,
    metadata?: Record<string, string>,
}

export interface JudoAddress {
    line1?: string,
    line2?: string,
    line3?: string,
    postCode?: string,
    town?: string,
    countryCode?: string,
}

export interface JudoUIConfiguration {
    isAVSEnabled: boolean,
    isPayButtonAmountVisible: boolean,
    shouldDisplayAmount: boolean,
    theme?: JudoTheme,
}

export interface JudoTheme {
    largeTitleFont: string,
    largeTitleSize: number,
    titleFont: string,
    titleSize: number,
    headlineFont: string,
    headlineSize: number,
    headlineLightFont: string,
    headlineLightSize: number,
    bodyFont: string,
    bodySize: number,
    bodyBoldFont: string,
    bodyBoldSize: number,
    captionFont: string,
    captionSize: number,
    captionBoldFont: string,
    captionBoldSize: number,
    jpBlackColor: string,
    jpDarkGrayColor: string,
    jpGrayColor: string,
    jpLightGrayColor: string,
    jpRedColor: string,
    jpWhiteColor: string,
    buttonColor: string,
    buttonTitleColor: string,
    backButtonImage: string,
    buttonCornerRadius: number
}

export enum JudoPaymentMethod {
    Card = 1 << 0,
    ApplePay = 1 << 1,
    GooglePay = 1 << 2,
    iDEAL = 1 << 3,
    All = 1 << 4,
}

export enum JudoCardNetwork {
    Visa = 1 << 0,
    Mastercard = 1 << 1,
    Maestro = 1 << 2,
    Amex = 1 << 3,
    ChinaUnionPay = 1 << 4,
    JCB = 1 << 5,
    Discover = 1 << 6,
    DinersClub = 1 << 7,
    All = 1 << 8,
}

export interface JudoAccountDetails {
    name?: string,
    accountNumber?: string,
    dateOfBirth?: string,
    postCode?: string,
}

export interface JudoResponse {
    receiptId: string,
    yourPaymentReference: string,
    type: string,
    createdAt: string,
    result: string,
    message?: string,
    judoId: string,
    siteId: string,
    merchantName: string,
    appearsOnStatementAs: string,
    originalAmount?: string,
    netAmount?: string,
    amount?: string,
    currency?: string,
    cardDetails?: any,
    consumer?: any,
    risks?: any,
    device?: any,
    paymentToken?: any
};
