//
//  PositionModel.h
//  stockTrack
//
//  Created by Scott Sullivan on 2/7/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SULGDataGrabber.h"

@protocol PositionUpdateDelegate <NSObject>

-(void) pingForUpdate;
-(void) pingForFailedTicker;


@end

typedef NS_ENUM(NSInteger, ScheduledFrequency) {
    kFrequencyTypeDaily,
    kFrequencyTypeWeekly,
    kFrequencyTypeBiWeekly,
    kFrequencyTypeMonthly,
    kFrequencyTypeYearly,
    kFrequencyTypeQuarterly
};
typedef NS_ENUM(NSInteger, ScheduledType) {
    kTypeShareBuy,
    kTypeDollarAmount
};

@protocol SULGDataDelegate;

@interface PositionModel : NSObject <SULGDataDelegate>

+ (instancetype) dataHandler;

/*
 each entry in the position dictionary is a dictionary with the ticker symbol as the key.
 the ticker's dictionary contains @"latestPrice", @"costBasisPennies", @"shareBasisPoints", and @"allocType"
 */
@property (nonatomic) NSMutableDictionary* positionDictionary;
@property (nonatomic) NSMutableArray* scheduleArray;
@property (nonatomic) NSMutableArray* tickerList;
@property (nonatomic) NSMutableDictionary* assetTypeDictionary;
@property (weak, nonatomic) id <PositionUpdateDelegate> delegate;
@property (strong) NSDateFormatter *dateFormatter;
@property (strong) NSDecimalNumberHandler *numberHandler;
@property (nonatomic,strong) SULGDataGrabber *dataGrabber;

-(void)saveState;
-(void)restoreState;
-(void)clearDefaults;
-(void)storePositionInTicker: (NSString *)tickerSymbol forShareBasisAmount: (NSDecimalNumber*) basisPoints andPennyCost: (NSDecimalNumber*) pennyCost;
- (void) addScheduledBuyFor: (NSString*) tickerSymbol forDate: (NSDate*) date andFrequency: (ScheduledFrequency) frequency andAmount: (NSDecimalNumber*) amount andType: (ScheduledType) type;
-(int)addPositionIn: (NSString*)tickerSymbol forAmount: (NSDecimalNumber*) amount ofType: (ScheduledType) type onDate: (NSDate*) date;
-(int)addPositionIn:(NSString *)tickerSymbol forAmount:(NSDecimalNumber *)amount ofType:(ScheduledType)type startDate:(NSDate *)date forScheduleFrequency: (ScheduledFrequency) frequency;
-(int)addPositionIn: (NSString*) tickerSymbol forPennyAmount: (NSDecimalNumber*) pennyAmount;
-(int)addPositionIn: (NSString*) tickerSymbol forDollarAmount: (NSDecimalNumber*) dollarAmount;
-(int)addPositionIn:(NSString *)tickerSymbol forShareAmount:(NSDecimalNumber*)shareCount;
-(int)addPositionIn:(NSString*)tickerSymbol forShareBasisAmount:(NSDecimalNumber*)shareBasisPoints;
-(NSDecimalNumber*) dollarValueForPositionAtIndex: (NSInteger) index;
-(NSDecimalNumber*) totalPortfolioValueDollars;
-(NSDecimalNumber*) totalPortfolioValueKiloDollars;
-(float) allocForPosition: (NSString*) tickerSymbol;
-(void)refreshAllPrices;
-(void)handleScheduledBuys;
-(void)updateAllocForPosition: (NSString*) tickerString toAmount:(NSString*) amountString;
-(void) positionIn: (NSString*) ticker shouldChangeAllocToType: (NSString*) allocationTypeString;
-(void) updateAllocations;
-(BOOL) positionIsNegative: (NSString*) tickerSymbol;

@end
