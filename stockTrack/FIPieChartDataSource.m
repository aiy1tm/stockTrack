//
//  FIPieChartDataSource.m
//  stockTrack
//
//  Created by Scott Sullivan on 3/13/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "FIPieChartDataSource.h"
#import "PositionModel.h"

@implementation FIPieChartDataSource
@synthesize isAllocMode;


#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    
    NSUInteger sliceCount =[[[PositionModel dataHandler] tickerList] count];
    if(self.isAllocMode){
        
        sliceCount = [[[PositionModel dataHandler] assetTypeDictionary] allKeys].count;   }
    
    return sliceCount;
}

-(instancetype)init
{
    if ( (self = [super init]) ) {
        self.isAllocMode = NO;
    }
    
    return self;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    
    if (CPTPieChartFieldSliceWidth == fieldEnum) {
       
        NSNumber *returnMe;
        
        
        if (self.isAllocMode) {
            NSArray* assetSliceLabels = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            NSString* sliceLabel =[assetSliceLabels objectAtIndex:index];
           returnMe = [[PositionModel dataHandler] assetTypeDictionary][sliceLabel][@"actualAlloc"];
        }else{
            returnMe = [[PositionModel dataHandler] dollarValueForPositionAtIndex:index];
        }
        return returnMe;
    }
    return [NSDecimalNumber zero];
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
    // 1 - Define label text style
    static CPTMutableTextStyle *labelText = nil;
    if (!labelText) {
        labelText= [[CPTMutableTextStyle alloc] init];
        labelText.color = [CPTColor blackColor];
    }
  
    NSString *sliceLabel;
   
    if (self.isAllocMode) {
       NSArray* assetSliceLabels = [[[[PositionModel dataHandler] assetTypeDictionary] allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        sliceLabel =[assetSliceLabels objectAtIndex:index];
    }else{
        sliceLabel = [[[PositionModel dataHandler] tickerList] objectAtIndex:index];
    }
    
 
    return [[CPTTextLayer alloc] initWithText:sliceLabel style:labelText];
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    
    return @"N/A";
}



@end
