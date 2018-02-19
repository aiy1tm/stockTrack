//
//  SULGDataGrabber.m
//  SULGFinanceIntfc
//
//  Created by Scott Sullivan on 11/6/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//


// https://www.quandl.com/api/v3/datasets/WIKI/AAPL.csv?api_key=


#import "SULGDataGrabber.h"
#define QUANDL_API_KEY @"<add_yours_here>"

@implementation SULGDataGrabber

- (instancetype) initWithDelegate: (id) delegate
{
    
    self = [super init];
    if(self){
    
    _delegate = delegate;
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    _urlSession = [NSURLSession sessionWithConfiguration:config];
        self.databaseStrings = @{@"qWiki":@"yFUND",
                             @"yFUND":@"yINDEX",
                             @"yINDEX":@"gPINK",
                             @"gPINK":@"gNYSE",
                             @"gNYSE":@"None"};
        
    }
    return self;
}

-(NSURL*) urlStringForTicker: (NSString*) ticker nearDate: (NSDate*) date andDatabase: (NSString*)databaseString
{


 
    NSDate *currentDate = [NSDate dateWithTimeIntervalSinceNow:-24*60*60*5]; // 3 days ago...
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *dateInString = [dateFormatter stringFromDate:currentDate];
    
    NSString *symbol = ticker;
    
    NSDictionary *urlDatabasePrefixDictionary = @{@"qWiki":[NSString stringWithFormat:
                                                           @"https://www.quandl.com/api/v3/datatables/WIKI/PRICES.json?ticker=%@&date.gte=%@&api_key=%@", symbol, dateInString,QUANDL_API_KEY],
                                                  @"yFUND":[NSString stringWithFormat:
                                                                @"https://www.quandl.com/api/v3/datasets/YAHOO/FUND_%@/data.json?start_date=%@&api_key=%@",symbol, dateInString,QUANDL_API_KEY],
                                                  @"yINDEX":[NSString stringWithFormat:
                                                                 @"https://www.quandl.com/api/v3/datasets/YAHOO/INDEX_%@/data.json?start_date=%@&api_key=%@", symbol, dateInString,QUANDL_API_KEY],
                                                  @"gPINK":[NSString stringWithFormat:@"https://www.quandl.com/api/v3/datasets/GOOG/PINK_%@/data.json?start_date=%@&api_key=%@",symbol,dateInString,QUANDL_API_KEY],
                                                   @"gNYSE":[NSString stringWithFormat:@"https://www.quandl.com/api/v3/datasets/GOOG/NYSE_%@/data.json?start_date=%@&api_key=%@",symbol,dateInString,QUANDL_API_KEY]};
    
    NSString *urlString = [NSString stringWithFormat:
                           @"https://www.quandl.com/api/v3/datatables/WIKI/PRICES.json?ticker=%@&date.gte=%@&api_key=%@", symbol, dateInString,QUANDL_API_KEY];
    NSURL *url = [NSURL URLWithString:urlString];
    
    if (urlDatabasePrefixDictionary[databaseString]) {
        url = [NSURL URLWithString:urlDatabasePrefixDictionary[databaseString]];
    }

    return url;
    
}


-(void) urlPrice:(NSString*) tickerString forType: (NSString*) databaseType forDate: (NSDate *) date forTransaction: (NSDictionary*) transactionDict{

    if(![databaseType isEqualToString:@"None"]){
  //  NSLog(@"checkin urlprice for ticker: %@, of type %@",tickerString, databaseType);
    NSURL *url = [self urlStringForTicker:tickerString nearDate:[NSDate date] andDatabase:databaseType];
    long tickerCount  = (long) [[tickerString componentsSeparatedByString:@","] count];
    //NSLog(@"queried %d tickers",tickerCount);
    
 
    NSURLSessionDataTask *downloadTask = [[NSURLSession sharedSession]
                                          dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                           
                                              NSDictionary *priceDict =
                                              [NSJSONSerialization JSONObjectWithData:data
                                                                              options:NSJSONReadingAllowFragments
                                                                                error:&error];
                                              if (!error) {
                                                  //NSLog(@"%@",priceDict);
                                                  
                                                  // this is probing a "dataset"
                                                  // has entry "column_names"
                                                    __block BOOL foundNothing = YES;
                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                      
                                                      if([priceDict[@"dataset_data"][@"data"] count]!=0)  {
                                                        
                                                          NSInteger closeIndex=[priceDict[@"dataset_data"][@"column_names"] indexOfObject:@"Close"];
                                                          NSInteger dateIndex=[priceDict[@"dataset_data"][@"column_names"] indexOfObject:@"Date"];
                                                          //NSLog(@"close index %ld",closeIndex);
                                                          //NSLog(@"date index %ld",dateIndex);
                                                          if(NSNotFound == closeIndex) {
                                                              NSLog(@"close not found");
                                                          }
                                                          if(NSNotFound == dateIndex) {
                                                              NSLog(@"date not found");
                                                          }
                                                          NSArray *dataTable = priceDict[@"dataset_data"][@"data"];
                                                          //NSLog(@"%d",(int) dataTable.count);
                                                          NSArray *priceArray = @[tickerString,dataTable[0][dateIndex],dataTable[0][closeIndex]];
                                                          
                                                          //NSLog(@"%@",priceArray);
                                                          //[self.delegate receivedPriceDictionary:priceDict[@"dataset_data"][@"data"]];
                                                          
                                                          [self.delegate receivedPriceDictionary:priceArray forTransaction:transactionDict];
                                                         
                                                          
                                                          foundNothing = NO;
                                                      }else{
                                                          //this is responding with a "datatable"
                                                          // has entry "columns"
                                                          if ([priceDict[@"datatable"][@"data"] count]!=0) {
                                                             // NSLog(@"saw datatable");
                                                              
                                                              
                                                             //NSLog(@"%@", priceDict[@"datatable"][@"columns"]);
                                                              NSArray *dataTable = priceDict[@"datatable"][@"data"];
                                                              
                                                              long priceStep = dataTable.count/tickerCount;
                                                              long lastEntry = dataTable.count - 1;
                                                              int dateEntry = 1;
                                                              int closeEntry = 5;
                                                              //int adjClose =12; future-proofin'
                                                              NSMutableArray *priceArray = [NSMutableArray array];//@[dataTable[lastEntry][0],dataTable[lastEntry][dateEntry],dataTable[lastEntry][closeEntry]]; // close price... not adjusted index 12 is adj_close.
                                                              long addIdx = lastEntry;
                                                              while(addIdx>0){
                                                                  [priceArray addObject:@[dataTable[addIdx][0],dataTable[addIdx][dateEntry],dataTable[addIdx][closeEntry]]];
                                                                  addIdx -= priceStep;
                                                              }
                                                              if(priceArray.count>1 || [transactionDict[@"type"] isEqual:@"latestPrice"]){
                                                                  [self.delegate receivedNewPrices:priceArray];
                                                              }else{
                                                                  NSLog(@"delegate price send");
                                                                  [self.delegate receivedPriceDictionary:priceArray forTransaction:transactionDict];
                                                              }
                                                              foundNothing = NO;
                                                          }
                                                          
                                                          
                                                          if(foundNothing){
                                                              //this can be a switch statement checking a lot of different quandl databse queries if I feel like going there..
                                                              // trick here is each key-value of the disctionary jumps through the urls for the databases.. some deprecated
                                                              [self urlPrice:tickerString forType:self.databaseStrings[databaseType] forDate:[NSDate date] forTransaction:transactionDict];
                                        
                                                              
                                                          }
                                                      }
                                                      
                                                  });

                                                  
                                                  
                                                  
                                              }
                                              if (error)
                                              {   NSLog(@"data grab error:");
                                                  NSLog(@"%@",error);
                                              }
                                          }];
    
 
    [downloadTask resume];
    }else{
        [self.delegate failedToReceivePriceForTicker:tickerString];
    }
}

-(void) getLatestPriceForTicker:(NSString *)tickerString{

    [self urlPrice: tickerString forType:@"qWiki" forDate:[NSDate date] forTransaction:@{@"type":@"latestPrice"}];
}

-(void) getPriceForTicker: (NSString*) tickerString onOrNearDate: (NSDate*) date{
    [self urlPrice: tickerString forType:@"qWiki" forDate:date forTransaction:@{}];
}

-(void) getPriceForTicker: (NSString*) tickerString onOrNearDate: (NSDate*) date forTransaction: (NSDictionary*) transDict
{
    [self urlPrice: tickerString forType:@"qWiki" forDate:date forTransaction:transDict];//includes the rider, to be interpreted by the position manager
    NSLog(@"dispatched transaction");
}


@end
