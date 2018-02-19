//
//  PositionModel.m
//  stockTrack
//
//  Created by Scott Sullivan on 2/7/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "PositionModel.h"

#import "SULGDataGrabber.h"



@implementation PositionModel

@synthesize positionDictionary, scheduleArray;
@synthesize tickerList;

@synthesize dateFormatter;
@synthesize numberHandler;
@synthesize dataGrabber;
@synthesize delegate;

+ (instancetype) dataHandler
{
    
    static PositionModel *handler = nil;
    
    if (!handler) {
        handler = [[self alloc] initPrivate];
    }
    
    return handler;
}

- (instancetype) init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[PositionModel dataHandler]" userInfo:nil];
}

- (instancetype) initPrivate
{
    self = [super init];
    
    //truly initialize the data handler here. going to want to pull saved positions from defaults or core data
    // Init YQL
    self.dataGrabber = [[SULGDataGrabber alloc] initWithDelegate:self];
    self.positionDictionary = [NSMutableDictionary dictionary];
    self.scheduleArray = [NSMutableArray array];
    self.tickerList = [NSMutableArray array];
    self.assetTypeDictionary = [NSMutableDictionary dictionaryWithDictionary:@{
                                                                               @"Domestic Equities":[NSMutableDictionary dictionaryWithCapacity:3],
                                                                               @"International Equities":[NSMutableDictionary dictionaryWithCapacity:3],
                                                                               @"Bonds":[NSMutableDictionary dictionaryWithCapacity:3],
                                                                               @"REIT":[NSMutableDictionary dictionaryWithCapacity:3],
                                                                               @"Commodities":[NSMutableDictionary dictionaryWithCapacity:3]}];
    
    //key-values will be targetAlloc and actualAlloc.
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"yyyy-MM-dd"];
    self.numberHandler = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundPlain scale:2 raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    [self restoreState];
    
    
    return self;
}

#pragma mark -- data operations
#warning implement edit case

- (void) addScheduledBuyFor: (NSString*) tickerSymbol forDate: (NSDate*) date andFrequency: (ScheduledFrequency) frequency andAmount: (NSDecimalNumber*) amount andType: (ScheduledType) type
{
    NSDictionary *newScheduler =@{@"ticker":tickerSymbol,
                                @"date":date,
                                @"frequency":[NSNumber numberWithLong:frequency],
                                  @"type":[NSNumber numberWithInteger:type],
                                  @"amount":[NSString stringWithFormat:@"%@",amount]};
    [self.scheduleArray addObject:newScheduler];
}

- (void) handleScheduledBuys
{
    // OK, loop through and update the sharenumber and costnumber, don't edit latest price. will refresh all prices at the end. This way it is tickerCount + 1 API calls maximum.
    
    for (NSDictionary *schedule in self.scheduleArray) {
        //check for dates that are today or in the past, then execute the buys with the appropriate method.
        // then UPDATE the date based on the frequency.
               // NSLog(@"time interval %lf", timeInterval);
        NSLog(@"handling scheduled: %@",schedule);
        if ([[schedule objectForKey:@"date"] timeIntervalSinceNow] < 0.0) {
            // Date has passed, make the buy
           #warning implement the scheduled buy, but maybe multiple buys on one API call. check if multiple dates have passed first
            [self addPositionIn: [schedule objectForKey:@"ticker"] forAmount: [NSDecimalNumber decimalNumberWithString:[schedule objectForKey:@"amount"]] ofType: [[schedule objectForKey:@"type"] integerValue] startDate: [schedule objectForKey:@"date"] forScheduleFrequency:[[schedule objectForKey:@"frequency"] integerValue]];
        }
    }
}

- (int) addPositionIn:(NSString *)tickerSymbol forAmount:(NSDecimalNumber *)amount ofType:(ScheduledType)type startDate:(NSDate *)date forScheduleFrequency: (ScheduledFrequency) frequency
{ int outCome = 0;
        return outCome;
}

-(NSTimeInterval) timeIntervalForFrequency: (ScheduledFrequency) frequency
{
#warning implement all the possible frequencies... incomplete!
    NSTimeInterval timeInterval;
    switch (frequency) { //finish this
        case kFrequencyTypeDaily:
            timeInterval = 24*60*60;
            break;
        case kFrequencyTypeWeekly:
            timeInterval = 7*24*60*60;
            break;
        case kFrequencyTypeMonthly:
            timeInterval = 31*7*24*60*60;
            break;
        case kFrequencyTypeBiWeekly:
            timeInterval = 14*24*60*60;
            break;
        case kFrequencyTypeQuarterly:
            timeInterval = 3*31*7*24*60*60;
            break;
        case kFrequencyTypeYearly:
            timeInterval = 365*7*24*60*60;
            break;
        default:
            timeInterval = 24*60*60;
            break;
    }

    return timeInterval;
}

- (NSArray*) dateArrayFromDate: (NSDate*) startDate forScheduleFrequency: (ScheduledFrequency) frequency
{
    NSMutableArray *buildArray = [NSMutableArray arrayWithCapacity:3];
    NSDate *today = [NSDate date];
    NSTimeInterval timeInterval = [self timeIntervalForFrequency:frequency];
    
    
    NSDate *loopDate = startDate;
    while ([loopDate timeIntervalSinceDate:today]<0) {
        // add loopDate to output array and bump to next date.
        [buildArray addObject:loopDate];
        loopDate = [NSDate dateWithTimeInterval:timeInterval sinceDate:loopDate];
    }

    return [NSArray arrayWithArray:buildArray];
}


- (void) storePositionInTicker: (NSString *)tickerSymbol forShareBasisAmount: (NSDecimalNumber*) basisPoints andPennyCost: (NSDecimalNumber*) pennyCost // basic crud
{ // this is for edit mode, just updates the shares and cost, leave the price untouched. always refresh prices shortly after doing this
    
            BOOL positiveBasis = [basisPoints compare:[NSNumber numberWithInt:0]]==NSOrderedDescending;
            BOOL positiveCost = [pennyCost compare:[NSNumber numberWithInt:0]]==NSOrderedDescending;
    NSString *allocString = @"None";
    if (self.positionDictionary[tickerSymbol][@"allocType"]) {
        allocString = self.positionDictionary[tickerSymbol][@"allocType"];
    }
            
            if (positiveCost&&positiveBasis) {
                NSString* sharePriceDollars;
                if (!self.positionDictionary[tickerSymbol]) {
                    //add to tickerlist
                    [self.tickerList addObject:tickerSymbol];
                    sharePriceDollars = @"30.00";
                }else{
                    //already has a price.
                    sharePriceDollars = self.positionDictionary[tickerSymbol][@"latestPrice"];
                }
                
                NSDictionary *updatedPos =@{@"costBasisPennies":[NSString stringWithFormat:@"%@",pennyCost],
                                            @"shareBasisPoints":[NSString stringWithFormat:@"%@",basisPoints],
                                            @"latestPrice":sharePriceDollars,
                                            @"allocType":allocString};
                [self.positionDictionary setObject:updatedPos forKey:tickerSymbol];
                
            }
}

- (int) addPositionIn: (NSString*)tickerSymbol forAmount: (NSDecimalNumber*) amount ofType: (ScheduledType) type onDate: (NSDate*) date
{
    
    return 0; // no results at all, network error
    
}
//dispatch transaction for share buy scheduled
- (int) addPositionIn:(NSString *)tickerSymbol forPennyAmount:(NSDecimalNumber*)pennyAmount
{// fundamentally work in pennies to avoid floating point issues.

    [self.dataGrabber getPriceForTicker:tickerSymbol onOrNearDate:[NSDate date] forTransaction:@{@"type":@"buyPennies",@"amount":pennyAmount}];
    

    return 0;
}

- (int) addPositionIn:(NSString *)tickerSymbol forDollarAmount:(NSDecimalNumber*)dollarAmount
{// fundamentally work in pennies to avoid floating point issues. so convert dollars to pennies then call the penny method...
    
    //int dollarsInCents = roundf(100*dollarAmount);
    
   int outCome = [self addPositionIn:tickerSymbol forPennyAmount:dollarAmount];
    return outCome;
    
}

- (int) addPositionIn:(NSString *)tickerSymbol forShareAmount:(NSDecimalNumber*)shareCount
{// work in basis points
    
 //   int shareBasisPoints = roundf(100*shareCount);
    
   int outCome = [self addPositionIn:tickerSymbol forShareBasisAmount:shareCount];
    return outCome;
    
}

-(int) addPositionIn:(NSString*)tickerSymbol forShareBasisAmount:(NSDecimalNumber*)shareBasisPoints
{
    [self.dataGrabber getPriceForTicker:tickerSymbol onOrNearDate:[NSDate date] forTransaction:@{@"type":@"buySharePoints",@"amount":shareBasisPoints}];

    return 0;
}
// this one should dispatch
- (void) refreshAllPrices
{
  
    NSString *tickers = [self.tickerList componentsJoinedByString:@","];

    //dispatch query for tickers!

    [self.dataGrabber getLatestPriceForTicker:tickers];
    
    [self updateAllocations];
}

-(NSDecimalNumber*) dollarValueForPositionAtIndex: (NSInteger) index{
    
    NSString *tickLabel = [self.tickerList objectAtIndex:index];
    NSDecimalNumber* shareCount = [NSDecimalNumber decimalNumberWithString:self.positionDictionary[tickLabel][@"shareBasisPoints"]];
    NSDecimalNumber* sharePrice = [NSDecimalNumber decimalNumberWithString:self.positionDictionary[tickLabel][@"latestPrice"]];
    NSDecimalNumber* totalValue = [sharePrice decimalNumberByMultiplyingBy:shareCount withBehavior:self.numberHandler];
    
    return totalValue;
}

-(NSDecimalNumber*) totalPortfolioValueDollars{
    NSDecimalNumber* totVal = [NSDecimalNumber zero];
    for (NSString *tickLabel in self.tickerList) {
        NSDecimalNumber* shareCount = [NSDecimalNumber decimalNumberWithString:self.positionDictionary[tickLabel][@"shareBasisPoints"]];
        NSDecimalNumber* sharePrice = [NSDecimalNumber decimalNumberWithString:self.positionDictionary[tickLabel][@"latestPrice"]];
        NSDecimalNumber* totalValue = [sharePrice decimalNumberByMultiplyingBy:shareCount];
        totVal= [totVal decimalNumberByAdding:totalValue];
    }
   
    return totVal;
}

-(float) allocForPosition:(NSString *)tickerSymbol
{
    NSDecimalNumber* shareCount = [NSDecimalNumber decimalNumberWithString:self.positionDictionary[tickerSymbol][@"shareBasisPoints"]];
    NSDecimalNumber* sharePrice = [NSDecimalNumber decimalNumberWithString:self.positionDictionary[tickerSymbol][@"latestPrice"]];
    NSDecimalNumber* totalValue = [sharePrice decimalNumberByMultiplyingBy:shareCount withBehavior:self.numberHandler];
    NSDecimalNumber *fraction = [totalValue decimalNumberByDividingBy:[self totalPortfolioValueDollars] withBehavior:self.numberHandler];
    
    
    return 100*[fraction floatValue];
}

-(void)updateAllocForPosition: (NSString*) tickerString toAmount:(NSString*) amountString
{
       self.positionDictionary[tickerString] = [self appendedDictWithKey:@"targetAlloc" andObject:amountString toDictionary:self.positionDictionary[tickerString]];
    
    [self updateAllocations];
}



-(void) updateAllocations   {
 //loop over the alloc types and sum the individual contributions.
    
    for (NSString *key  in [[[PositionModel dataHandler] assetTypeDictionary] allKeys]) {
        float typeContrib = 0;
        for (NSString* ticker in [[PositionModel dataHandler] tickerList]) {
            //sum sum
            if ([[[PositionModel dataHandler] positionDictionary][ticker][@"allocType"] isEqualToString:key]) {
                typeContrib+=[self allocForPosition:ticker];
            }
        }
       // NSLog(@"%@",self.assetTypeDictionary[key]);
        NSMutableDictionary *updatedAllocs = [NSMutableDictionary dictionaryWithDictionary:[self appendedDictWithKey:@"actualAlloc" andObject:[NSNumber numberWithFloat:typeContrib] toDictionary:self.assetTypeDictionary[key]]];
        self.assetTypeDictionary[key] = updatedAllocs;
        typeContrib = 0;
       // NSLog(@"%@",self.assetTypeDictionary[key]);
    }

    
    //NSLog(@"%@",[[PositionModel dataHandler] assetTypeDictionary]);
    
}


-(NSDecimalNumber*) projectedPortfolioValueOnDate: (NSDate*) date{
    
    NSDecimalNumber* totVal = [self totalPortfolioValueDollars];
    
    totVal = [totVal decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:@"1"]]; // placeholder
    
    return totVal;
    
}

-(void) positionIn: (NSString*) ticker shouldChangeAllocToType: (NSString*) allocationTypeString
{
    
    if ([self.tickerList containsObject:ticker]) {
            self.positionDictionary[ticker] = [self appendedDictWithKey:@"allocType" andObject:allocationTypeString toDictionary:self.positionDictionary[ticker]];
    }

}

-(NSDictionary*) appendedDictWithKey: (NSString*) dictKey andObject: (id) appendObj toDictionary: (NSDictionary*) dict
{
    
   NSMutableDictionary* tempDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    tempDict[dictKey] = appendObj;
   
    return [NSDictionary dictionaryWithDictionary:tempDict];
    
}

-(NSDecimalNumber*) totalPortfolioValueKiloDollars{
    return [[self totalPortfolioValueDollars] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"] withBehavior:self.numberHandler];
}

#pragma mark - Saving and Loading

- (void) saveState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
 //save the positions dictionary... and anything else.
    
    [defaults setObject:self.positionDictionary forKey:@"posDict"];
    [defaults setObject:self.scheduleArray forKey:@"schedDict"];
    [defaults setObject:self.tickerList forKey:@"ticklerList"];
    [defaults setObject:self.assetTypeDictionary forKey:@"allocationList"];
    [defaults synchronize];
    
    NSLog(@"called savestate");
    
    
}

- (void) restoreState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    

    
    if ([defaults objectForKey:@"posDict"])self.positionDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"posDict"]];
        
        
        if ([defaults objectForKey:@"schedDict"])self.scheduleArray = [NSMutableArray arrayWithArray:[defaults objectForKey:@"schedDict"]];
        if ([defaults objectForKey:@"ticklerList"])self.tickerList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"ticklerList"]];
        if ([defaults objectForKey:@"allocationList"])self.assetTypeDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"allocationList"]];
        
    
    
    
    
}

-(void) clearDefaults
{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"posDict"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ticklerList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"schedDict"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"allocationList"];
    
    
    [NSUserDefaults resetStandardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -- delegation from data grabber

-(void) receivedPriceDictionary: (NSArray*) priceArray forTransaction: (NSDictionary*) transactionDictionary{

    if(priceArray.count==1){
        //do it
        //there was a price that day.
        //find increment based on type
        NSLog(@"%@",priceArray);
        NSDecimalNumber* avgPrice = [NSDecimalNumber decimalNumberWithDecimal:[priceArray[0][2] decimalValue]];
        NSString *tickerSymbol = priceArray[0][0];
        NSDecimalNumber *amount = transactionDictionary[@"amount"];
        NSDecimalNumber *basisToBuy = amount; //This is correct in the type = buySharePoints naturally
        NSDecimalNumber *costToBuy = [amount decimalNumberByMultiplyingBy:avgPrice];
        if ([transactionDictionary[@"type"] isEqualToString:@"buyPennies"]) {
            basisToBuy = [amount decimalNumberByDividingBy:avgPrice];
            costToBuy = amount;
        }
        
        
            if (self.positionDictionary[tickerSymbol]==nil) {
            [self storePositionInTicker:tickerSymbol forShareBasisAmount:basisToBuy andPennyCost:costToBuy];
                NSDictionary *updatedPos =@{@"costBasisPennies":self.positionDictionary[tickerSymbol][@"costBasisPennies"],
                                            @"shareBasisPoints":self.positionDictionary[tickerSymbol][@"shareBasisPoints"],
                                            @"latestPrice":[avgPrice stringValue],
                                            @"allocType":self.positionDictionary[tickerSymbol][@"allocType"]};
                
                [self.positionDictionary setObject:updatedPos forKey:tickerSymbol];
                
            }else{ NSLog(@"position exists");
                //already have a position in this ticker, add more or sell.
                NSDictionary *existingPos = self.positionDictionary[tickerSymbol];
                
                NSDecimalNumber* existingCostPennies = [NSDecimalNumber decimalNumberWithString:existingPos[@"costBasisPennies"]];
                NSDecimalNumber* existingBasisShares = [NSDecimalNumber decimalNumberWithString:existingPos[@"shareBasisPoints"]];
                NSDecimalNumber* updatedCost;
                NSDecimalNumber* updatedShareBasis;
                
                BOOL positiveAmount = [amount compare:[NSNumber numberWithInt:0]]==NSOrderedDescending;
                if (!positiveAmount) {
                    //have to adjust the cost basis appropriately...
                    NSDecimalNumber* avgPenniesPerShareBasis = [existingCostPennies decimalNumberByDividingBy:existingBasisShares];
                    NSDecimalNumber* costDecrement = [avgPenniesPerShareBasis decimalNumberByMultiplyingBy:basisToBuy];
                    updatedCost = [existingCostPennies decimalNumberByAdding:costDecrement];
                }else{
                    updatedCost = [existingCostPennies decimalNumberByAdding:costToBuy];
                }
                updatedShareBasis = [existingBasisShares decimalNumberByAdding:basisToBuy];
#warning may or may not be averaging cost basis down correctly.
                
                NSDictionary *updatedPos =@{@"costBasisPennies":[NSString stringWithFormat:@"%@",updatedCost],
                                            @"shareBasisPoints":[NSString stringWithFormat:@"%@",updatedShareBasis],
                                            @"latestPrice":[avgPrice stringValue],
                                            @"allocType":existingPos[@"allocType"]};
                
                [self.positionDictionary setObject:updatedPos forKey:tickerSymbol];
            
                BOOL positionGoneNegative = ([updatedShareBasis compare:[NSNumber numberWithInt:0]]==NSOrderedAscending ||[updatedShareBasis compare:[NSNumber numberWithInt:0]]==NSOrderedSame);
               if (positionGoneNegative) {
                    //can't have negative shares.. sold the position out.. delete it.
                    [self.positionDictionary removeObjectForKey:tickerSymbol];
                    [self.tickerList removeObject:tickerSymbol];
                }
                
                }
        
    }else{ //no price!
    }
             
    if (self.delegate != nil)
    {
        [self.delegate pingForUpdate];
    }
    


}




-(void) receivedNewPrices: (NSArray*) newArray
{
    NSLog(@"%@",newArray);
    for (NSString* tickerKey in self.tickerList) {
        
        for (NSArray *priceEntry in newArray) {
            if ([tickerKey isEqualToString:priceEntry[0]]) {
                //symbols match, update the price
                
                    NSDictionary *updatedPos =@{@"costBasisPennies":self.positionDictionary[tickerKey][@"costBasisPennies"],
                                                @"shareBasisPoints":self.positionDictionary[tickerKey][@"shareBasisPoints"],
                                                @"latestPrice":[priceEntry[2] stringValue],
                                                @"allocType":self.positionDictionary[tickerKey][@"allocType"]};
                    
                    [self.positionDictionary setObject:updatedPos forKey:tickerKey];
                }

        }
    }
    if (self.delegate != nil)
    {
        [self.delegate pingForUpdate];
    }

}
//
-(void) failedToReceivePriceForTicker: (NSString*) ticker{
    if (self.delegate != nil)
    {NSLog(@"ping fail");
        [self.delegate pingForFailedTicker];
    }
    
}



@end
