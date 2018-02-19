//
// CurvedScatterPlot.m
// Plot_Gallery_iOS
//
// Created by Nino Ag on 23/10/11.

#import "CurvedScatterPlot.h"
#import "PositionModel.h"
#import "BudgetModel.h"

static NSString *const kData   = @"Data Source Plot";
static NSString *const kFirst  = @"First Derivative";
static NSString *const kSecond = @"Second Derivative";

@interface CurvedScatterPlot()

@property (nonatomic, readwrite, strong) CPTPlotSpaceAnnotation *symbolTextAnnotation;

@property (nonatomic, readwrite, strong) NSArray<NSDictionary<NSString *, NSNumber *> *> *plotData;
@property (nonatomic, readwrite, strong) NSArray<NSDictionary<NSString *, NSNumber *> *> *plotData1;
@property (nonatomic, readwrite, strong) NSArray<NSDictionary<NSString *, NSNumber *> *> *plotData2;

@end

@implementation CurvedScatterPlot

@synthesize symbolTextAnnotation;
@synthesize plotData;
@synthesize plotData1;
@synthesize plotData2;

+(void)load
{
    [super registerPlotItem:self];
}

-(instancetype)init
{
    if ( (self = [super init]) ) {
        self.title = @"Current Networth & SWR Projection";
        self.section = kLinePlots;
    }

    return self;
}

-(void)killGraph
{
    if ( self.graphs.count ) {
        CPTGraph *graph = (self.graphs)[0];

        CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;
        if ( annotation ) {
            [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
            self.symbolTextAnnotation = nil;
        }
    }

    [super killGraph];
}

-(NSArray*) worthArrayForPlot
{
    NSMutableArray* worthArray = [NSMutableArray arrayWithCapacity:12*20];
    double worthValue = [[[PositionModel dataHandler] totalPortfolioValueDollars] doubleValue];
    int monthsSinceNow = 0;
     int monthsToFi = [[BudgetModel dataHandler] monthsToFiForCagr:[BudgetModel dataHandler].expectedGain andNestEgg: [[PositionModel dataHandler] totalPortfolioValueDollars] andSWR:[BudgetModel dataHandler].SWR];
    int plotModulo = MAX(monthsToFi/10,10);
   
    if ([[BudgetModel dataHandler] totalMonthlySavings]>0||worthValue>0) { // avoid the infinite while
        
    while (worthValue<= 1.5*[[BudgetModel dataHandler] fiNumber]) {
        //stuff
        if (monthsSinceNow%plotModulo==0) {
          
        NSNumber *x = [NSNumber numberWithFloat:(float)monthsSinceNow/12];
        NSNumber *y = [NSNumber numberWithDouble:worthValue/1000.0];
        [worthArray addObject:@{ @"x": x,
                                 @"y": y }
         ];
    }
        monthsSinceNow++;
        worthValue*= pow(1+[[BudgetModel dataHandler] expectedGain], 0.08333); // apply interest
        worthValue+= [[BudgetModel dataHandler] totalMonthlySavings]; //apply savings
        
        
    }
    }else{
        [worthArray addObject:@{ @"x": [NSNumber numberWithInt:0],
                                 @"y": [NSNumber numberWithInt:0]}
         ];
    }
    
    return [NSArray arrayWithArray:worthArray];
    
}

-(NSArray*) fiNumArray
{
    
    NSMutableArray* worthArray = [NSMutableArray arrayWithCapacity:12*20];
    double worthValue = [[BudgetModel dataHandler] fiNumber];
   
    for (NSDictionary *dictVal in [self worthArrayForPlot]) {
        [worthArray addObject:@{ @"x": dictVal[@"x"],
                                 @"y": [NSNumber numberWithDouble:worthValue/1000.0]}
         ];
    }
    
    return [NSArray arrayWithArray:worthArray];
    
}


-(void)generateData
{
    self.plotData = [self worthArrayForPlot];
    self.plotData1 = [self fiNumArray];
}

-(void)renderInGraphHostingView:(CPTGraphHostingView *)hostingView withTheme:(CPTTheme *)theme animated:(BOOL)animated
{
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    CGRect bounds = hostingView.bounds;
#else
    CGRect bounds = NSRectToCGRect(hostingView.bounds);
#endif

    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:bounds];
    [self addGraph:graph toHostingView:hostingView];
    [self applyTheme:theme toGraph:graph withDefault:[CPTTheme themeNamed:kCPTDarkGradientTheme]];

    graph.plotAreaFrame.paddingLeft   += self.titleSize * CPTFloat(2.25);
    graph.plotAreaFrame.paddingTop    += self.titleSize;
    graph.plotAreaFrame.paddingRight  += self.titleSize;
    graph.plotAreaFrame.paddingBottom += self.titleSize;
    graph.plotAreaFrame.masksToBorder  = NO;

    // Plot area delegate
    graph.plotAreaFrame.plotArea.delegate = self;

    // Setup scatter plot space
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = YES;
    plotSpace.delegate              = self;

    // Grid line styles
    CPTMutableLineStyle *majorGridLineStyle = [CPTMutableLineStyle lineStyle];
    majorGridLineStyle.lineWidth = 0.75;
    majorGridLineStyle.lineColor = [[CPTColor colorWithGenericGray:CPTFloat(0.2)] colorWithAlphaComponent:CPTFloat(0.75)];

    CPTMutableLineStyle *minorGridLineStyle = [CPTMutableLineStyle lineStyle];
    minorGridLineStyle.lineWidth = 0.25;
    minorGridLineStyle.lineColor = [[CPTColor whiteColor] colorWithAlphaComponent:CPTFloat(0.1)];

    CPTMutableLineStyle *redLineStyle = [CPTMutableLineStyle lineStyle];
    redLineStyle.lineWidth = 10.0;
    redLineStyle.lineColor = [[CPTColor redColor] colorWithAlphaComponent:0.5];

    CPTLineCap *lineCap = [CPTLineCap sweptArrowPlotLineCap];
    lineCap.size = CGSizeMake( self.titleSize * CPTFloat(0.625), self.titleSize * CPTFloat(0.625) );

    // Axes
    // Label x axis with a fixed interval policy
    
    int monthsToFi = [[BudgetModel dataHandler] monthsToFiForCagr:[BudgetModel dataHandler].expectedGain andNestEgg: [[PositionModel dataHandler] totalPortfolioValueDollars] andSWR:[BudgetModel dataHandler].SWR];
    float yearsToFi = monthsToFi/12.0f;
    
    NSNumberFormatter *xnumberFormatter = [[NSNumberFormatter alloc] init];
    [xnumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [xnumberFormatter setNumberStyle:NSDateFormatterNoStyle];
    [xnumberFormatter setMaximumFractionDigits:1];
    [xnumberFormatter setPositiveFormat:@"###1"];
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)graph.axisSet;
    CPTXYAxis *x          = axisSet.xAxis;
    x.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    x.majorIntervalLength   = [NSNumber numberWithFloat:yearsToFi/10];
    x.minorTicksPerInterval = 1;
    x.majorGridLineStyle    = majorGridLineStyle;
    x.minorGridLineStyle    = minorGridLineStyle;
    x.axisConstraints       = [CPTConstraints constraintWithRelativeOffset:0.0];
    x.labelFormatter        = xnumberFormatter;

    lineCap.lineStyle = x.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    x.axisLineCapMax  = lineCap;

    x.title       = @"Time [years]";
    x.titleOffset = self.titleSize * CPTFloat(1.25);

    // Label y with an automatic label policy.
    
    NSNumberFormatter *ynumberFormatter = [[NSNumberFormatter alloc] init];
    [ynumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [ynumberFormatter setMaximumFractionDigits:2];
    [ynumberFormatter setPositiveFormat:@"#####0k"];
    CPTXYAxis *y = axisSet.yAxis;
    y.labelingPolicy              = CPTAxisLabelingPolicyAutomatic;
    y.minorTicksPerInterval       = 2;
    y.majorIntervalLength         = @0.01;
    y.preferredNumberOfMajorTicks = 8;
    y.majorGridLineStyle          = majorGridLineStyle;
    y.minorGridLineStyle          = minorGridLineStyle;
    y.axisConstraints             = [CPTConstraints constraintWithLowerOffset:0.0];
    y.labelOffset                 = self.titleSize * CPTFloat(0.25);
    y.labelFormatter              = ynumberFormatter;

    lineCap.lineStyle = y.axisLineStyle;
    lineCap.fill      = [CPTFill fillWithColor:lineCap.lineStyle.lineColor];
    y.axisLineCapMax  = lineCap;
    y.axisLineCapMin  = lineCap;

    y.title       = @"Invested Worth [$]";
    y.titleOffset = self.titleSize * CPTFloat(2.5);

    // Set axes
    graph.axisSet.axes = @[x, y];

    // Create a plot that uses the data source method
    CPTScatterPlot *dataSourceLinePlot = [[CPTScatterPlot alloc] init];
    dataSourceLinePlot.identifier = kData;

    // Make the data source line use curved interpolation
    dataSourceLinePlot.interpolation = CPTScatterPlotInterpolationCurved;

    CPTMutableLineStyle *lineStyle = [dataSourceLinePlot.dataLineStyle mutableCopy];
    lineStyle.lineWidth              = 3.0;
    lineStyle.lineColor              = [CPTColor greenColor];
    dataSourceLinePlot.dataLineStyle = lineStyle;

    dataSourceLinePlot.dataSource = self;
    [graph addPlot:dataSourceLinePlot];
    
    // First derivative
    CPTScatterPlot *firstPlot = [[CPTScatterPlot alloc] init];
    firstPlot.identifier    = @"fiNum";
    lineStyle.lineWidth     = 2.0;
    lineStyle.lineColor     = [CPTColor redColor];
    firstPlot.dataLineStyle = lineStyle;
    firstPlot.dataSource    = self;
    
     [graph addPlot:firstPlot];
    
    

    // Auto scale the plot space to fit the plot data
    [plotSpace scaleToFitPlots:[graph allPlots]];
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];

    // Expand the ranges to put some space around the plot
    [xRange expandRangeByFactor:@1.2];
    [yRange expandRangeByFactor:@1.2];
    plotSpace.xRange = xRange;
    plotSpace.yRange = yRange;

    [xRange expandRangeByFactor:@1.025];
    xRange.location = plotSpace.xRange.location;
    [yRange expandRangeByFactor:@1.05];
    x.visibleAxisRange = xRange;
    y.visibleAxisRange = yRange;

    [xRange expandRangeByFactor:@3.0];
    [yRange expandRangeByFactor:@3.0];
    plotSpace.globalXRange = xRange;
    plotSpace.globalYRange = yRange;

    // Add plot symbols
    CPTMutableLineStyle *symbolLineStyle = [CPTMutableLineStyle lineStyle];
    symbolLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:0.5];
    CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill               = [CPTFill fillWithColor:[[CPTColor blueColor] colorWithAlphaComponent:0.5]];
    plotSymbol.lineStyle          = symbolLineStyle;
    plotSymbol.size               = CGSizeMake(2.0, 2.0);
    dataSourceLinePlot.plotSymbol = plotSymbol;

    // Set plot delegate, to know when symbols have been touched
    // We will display an annotation when a symbol is touched
    dataSourceLinePlot.delegate = self;

    dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0;

    /*// Add legend
    graph.legend                 = [CPTLegend legendWithGraph:graph];
    graph.legend.numberOfRows    = 1;
    graph.legend.textStyle       = x.titleTextStyle;
    graph.legend.fill            = [CPTFill fillWithColor:[CPTColor darkGrayColor]];
    graph.legend.borderLineStyle = x.axisLineStyle;
    graph.legend.cornerRadius    = 5.0;
    graph.legendAnchor           = CPTRectAnchorBottom;
    graph.legendDisplacement     = CGPointMake( 0.0, self.titleSize * CPTFloat(2.0) );*/
}

#pragma mark -
#pragma mark Plot Data Source Methods

-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    NSUInteger numRecords = 0;
    NSString *identifier  = (NSString *)plot.identifier;

    if ( [identifier isEqualToString:kData] ) {
        numRecords = self.plotData.count;
    }
    else if ( [identifier isEqualToString:@"fiNum"] ) {
        numRecords = self.plotData1.count;
    }
    else if ( [identifier isEqualToString:kSecond] ) {
        numRecords = self.plotData2.count;
    }

    return numRecords;
}

-(id)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    NSNumber *num        = nil;
    NSString *identifier = (NSString *)plot.identifier;

    if ( [identifier isEqualToString:kData] ) {
        num = self.plotData[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }else if ( [identifier isEqualToString:@"fiNum"] ) {
        num = self.plotData1[index][(fieldEnum == CPTScatterPlotFieldX ? @"x" : @"y")];
    }
    

    return num;
}

#pragma mark -
#pragma mark Plot Space Delegate Methods

-(CPTPlotRange *)plotSpace:(CPTPlotSpace *)space willChangePlotRangeTo:(CPTPlotRange *)newRange forCoordinate:(CPTCoordinate)coordinate
{
    CPTGraph *theGraph    = space.graph;
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)theGraph.axisSet;

    CPTMutablePlotRange *changedRange = [newRange mutableCopy];

    switch ( coordinate ) {
        case CPTCoordinateX:
            [changedRange expandRangeByFactor:@1.025];
            changedRange.location          = newRange.location;
            axisSet.xAxis.visibleAxisRange = changedRange;
            break;

        case CPTCoordinateY:
            [changedRange expandRangeByFactor:@1.05];
            axisSet.yAxis.visibleAxisRange = changedRange;
            break;

        default:
            break;
    }

    return newRange;
}

#pragma mark -
#pragma mark CPTScatterPlot delegate methods

-(void)scatterPlot:(CPTScatterPlot *)plot plotSymbolWasSelectedAtRecordIndex:(NSUInteger)index
{
    NSLog(@"touched a symbol...");
}

-(void)scatterPlotDataLineWasSelected:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineWasSelected: %@", plot);
}

-(void)scatterPlotDataLineTouchDown:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchDown: %@", plot);
}

-(void)scatterPlotDataLineTouchUp:(CPTScatterPlot *)plot
{
    NSLog(@"scatterPlotDataLineTouchUp: %@", plot);
}

#pragma mark -
#pragma mark Plot area delegate method

-(void)plotAreaWasSelected:(CPTPlotArea *)plotArea
{
    // Remove the annotation
    CPTPlotSpaceAnnotation *annotation = self.symbolTextAnnotation;

    if ( annotation ) {
        CPTXYGraph *graph = [self.graphs objectAtIndex:0];

        [graph.plotAreaFrame.plotArea removeAnnotation:annotation];
        self.symbolTextAnnotation = nil;
    }
}

@end
