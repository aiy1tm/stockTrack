//
//  FirstViewController.h
//  stockTrack
//
//  Created by Scott Sullivan on 2/7/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CorePlot.h"
#import "FIPieChartDataSource.h"

@interface FirstViewController : UIViewController <CPTPieChartDelegate>

@property (weak, nonatomic) IBOutlet UILabel *t2fiLabel;
@property (strong, nonatomic) IBOutlet CPTGraphHostingView *chartHostView;
@property (strong, nonatomic) CPTTheme *selectedTheme;
@property (strong, nonatomic) FIPieChartDataSource *pieDataSource;

-(void)initPiePlot;
-(void)configurePieGraph;
-(void)configurePieChart;
-(void)configurePieLegend;
- (IBAction)pieSwitchType:(id)sender;

@end

