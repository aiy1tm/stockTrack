//
//  FirstViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 2/7/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "FirstViewController.h"
#import "PositionModel.h"
#import "BudgetModel.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

@synthesize chartHostView;
@synthesize selectedTheme;
@synthesize pieDataSource;

- (void)viewDidLoad {
    [super viewDidLoad];
    [[PositionModel dataHandler] refreshAllPrices];
    self.pieDataSource = [[FIPieChartDataSource alloc] init];
    


#warning implement default firstload budget & positions
 //  int outcomeInt =  [[PositionModel dataHandler] addPositionIn: @"SWLBX" forAmount: [NSDecimalNumber decimalNumberWithString:@"4545.69"] ofType:kTypeDollarAmount onDate:[NSDate dateWithTimeIntervalSinceNow:-864000]]; //10 days ago, a Sunday
 //   NSLog(@"%d",outcomeInt);
 //   [[PositionModel dataHandler] addScheduledBuyFor:@"GE" forDate:[NSDate dateWithTimeIntervalSinceNow:-2*24*60*60] andFrequency:kFrequencyTypeWeekly andAmount:[NSDecimalNumber decimalNumberWithString:@"150"] andType:kTypeDollarAmount];
 //   [[PositionModel dataHandler] handleScheduledBuys];
    
  //  NSLog(@"total value %@",[[PositionModel dataHandler] totalPortfolioValueDollars]);
    
}

- (void) viewWillAppear:(BOOL)animated
{
    int months = [[BudgetModel dataHandler] monthsToFiForCagr:[BudgetModel dataHandler].expectedGain andNestEgg: [[PositionModel dataHandler] totalPortfolioValueDollars] andSWR:[BudgetModel dataHandler].SWR];
    self.t2fiLabel.text = [NSString stringWithFormat:@"%d years, %d months",months/12, months%12];
    self.navigationController.navigationBar.topItem.title = @"At A Glance";
    [super viewWillAppear:YES];
    // NSLog(@"total value %@",[[PositionModel dataHandler] totalPortfolioValueDollars]);
    [self initPiePlot];
}


- (void) viewDidLayoutSubviews{
    [self initPiePlot];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Chart behavior
-(void)initPiePlot {
    [self configurePieGraph];
    [self configurePieChart];
    // [self configureLegend];
}


-(void)configurePieGraph {
    // 1 - Create and initialise graph
    if (!self.chartHostView.hostedGraph) {
        CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.chartHostView.bounds];
        self.chartHostView.hostedGraph = graph;
        graph.paddingLeft = 0.0f;
        graph.paddingTop = 0.0f;
        graph.paddingRight = 0.0f;
        graph.paddingBottom = 0.0f;
        graph.axisSet = nil;
        // 2 - Set up text style
        CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
        textStyle.color = [CPTColor grayColor];
        textStyle.fontName = @"Helvetica-Bold";
        textStyle.fontSize = 16.0f;
        // 3 - Configure title
        NSString *title = [NSString stringWithFormat:@"Portfolio Value: %@ k", [[PositionModel dataHandler] totalPortfolioValueKiloDollars]];
        graph.title = title;
        graph.titleTextStyle = textStyle;
        graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
        graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
        // 4 - Set theme
        self.selectedTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
        [graph applyTheme:self.selectedTheme];
    }

  
}

-(void)configurePieChart {
    // 1 - Get reference to graph
    
    CPTGraph *graph = self.chartHostView.hostedGraph;
    [graph removePlotWithIdentifier:@"holdingsChart"];
    // 2 - Create chart
    CPTPieChart *pieChart = [[CPTPieChart alloc] init];
    pieChart.dataSource = self.pieDataSource;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.chartHostView.bounds.size.height * 0.7) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    pieChart.identifier = @"holdingsChart";
    // 3 - Create gradient
    CPTGradient *overlayGradient = [[CPTGradient alloc] init];
    overlayGradient.gradientType = CPTGradientTypeRadial;
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
    overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
    pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    pieChart.labelOffset = -40.0f;
    // 4 - Add chart to graph
    [graph addPlot:pieChart];
}

-(void)configurePieLegend {
    // 1 - Get graph instance
    CPTGraph *graph = self.chartHostView.hostedGraph;
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    // 3 - Configure legen
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor blackColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 8);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

- (IBAction)pieSwitchType:(id)sender {
 
    [self.chartHostView.hostedGraph removePlotWithIdentifier:@"holdingsChart"];
    self.pieDataSource.isAllocMode = !self.pieDataSource.isAllocMode;
    [self initPiePlot];
}

-(void)plot:(CPTPlot *)plot dataLabelWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"Data label for '%@' was selected at index %d.", plot.identifier, (int)index);
}


-(void)pieChart:(CPTPieChart *)plot sliceWasSelectedAtRecordIndex:(NSUInteger)index
{
    /*
        NSString *touchedTicker =[[[PositionModel dataHandler] tickerList] objectAtIndex:index];
    float touchedAlloc = [[PositionModel dataHandler] allocForPosition:touchedTicker];

    UIAlertController* alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@ : %.01f%% of Portfolio",touchedTicker,touchedAlloc]
                                                                   message:@"Target allocation percentage:"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = [NSString stringWithFormat:@"%.01f",touchedAlloc];
        textField.keyboardType = UIKeyboardTypeNumberPad;
    
    
    }];
  
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {
                                                              NSCharacterSet * amountSet = [[NSCharacterSet characterSetWithCharactersInString:@".,0123456789"] invertedSet];
                                                              NSString* amountField = alert.textFields[0].text;
                                                              BOOL shouldUpdate=  ([amountField rangeOfCharacterFromSet:amountSet].location == NSNotFound);
                                                              if (shouldUpdate) {
                                                                  [[PositionModel dataHandler] updateAllocForPosition:touchedTicker toAmount:amountField
                                                                   ];
                                                              }else{
#warning implement an error for ridiculous inputs here.
                                                              }
                                                                                                                     }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
    */
  
  }



@end
