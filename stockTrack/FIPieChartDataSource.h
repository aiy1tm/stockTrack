//
//  FIPieChartDataSource.h
//  stockTrack
//
//  Created by Scott Sullivan on 3/13/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CorePlot.h"

@interface FIPieChartDataSource : NSObject <CPTPieChartDataSource>

@property BOOL isAllocMode;

@end
