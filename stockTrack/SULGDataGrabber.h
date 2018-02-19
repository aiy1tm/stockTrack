//
//  SULGDataGrabber.h
//  SULGFinanceIntfc
//
//  Created by Scott Sullivan on 11/6/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SULGDataDelegate <NSObject>

-(void) receivedPriceDictionary: (NSArray*) priceArray forTransaction: (NSDictionary*) transactionDictionary;
-(void) receivedNewPrices: (NSArray*) newArray;
-(void) failedToReceivePriceForTicker: (NSString*) ticker;


@end

@interface SULGDataGrabber : NSObject

@property (weak, nonatomic) id <SULGDataDelegate> delegate;
@property (nonatomic) NSURLSession *urlSession;
@property (nonatomic) NSDictionary* databaseStrings;

-(void) getLatestPriceForTicker: (NSString*) tickerString;
-(void) getPriceForTicker: (NSString*) tickerString onOrNearDate: (NSDate*) date forTransaction: (NSDictionary*) transDict;

-(instancetype) initWithDelegate: (id) delegate;

@end


