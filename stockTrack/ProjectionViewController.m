//
//  ProjectionViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 4/23/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "ProjectionViewController.h"
#import "BudgetModel.h"

@interface ProjectionViewController ()

@end

@implementation ProjectionViewController
@synthesize projectionPlotHostingView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
     [self.projectionPlotHostingView setTransform:CGAffineTransformMakeScale(1,-1)];
    
    [self.apySlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    [self.swrSlider addTarget:self action:@selector(sliderChange:) forControlEvents:UIControlEventValueChanged];
    self.apyButton.tag = 2;
    self.swrButton.tag = 1;
    [self.apyButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.swrButton addTarget:self action:@selector(tappedButton:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.swrSlider setValue:([[BudgetModel dataHandler] SWR]/0.08) - 0.125 animated:YES];
    [self.apySlider setValue:[[BudgetModel dataHandler] expectedGain]/0.1 animated:YES];
    [self updateLabels];
    
    //move the sliders into position...
}

- (void) sliderChange: (id) sender
{
    [[BudgetModel dataHandler] setSWR:(self.swrSlider.value+0.125)*0.08];
    [[BudgetModel dataHandler] setExpectedGain:self.apySlider.value*0.1     ];
    
    [self updateLabels];
    
}

- (void) updateLabels{
    
    [self.apyButton setTitle:[NSString stringWithFormat:@"APY : %.01f%%",100*[[BudgetModel dataHandler] expectedGain]] forState:UIControlStateNormal];
    
    [self.swrButton setTitle:[NSString stringWithFormat:@"SWR : %.01f%%",100*[[BudgetModel dataHandler] SWR]] forState:UIControlStateNormal];
    
    if ( self.projectionPlotHostingView) {
        PlotItem* detailItem = [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:0];
        
        detailItem.title = @"Projected Invested Worth";
        [detailItem renderInView:self.projectionPlotHostingView withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] animated:YES];
    }
}

- (void) tappedButton: (id) sender
{
    UIButton *bpressed = (UIButton*) sender;
    NSLog(@"tapped button %d",bpressed.tag);
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ( self.projectionPlotHostingView) {
        PlotItem* detailItem = [[PlotGallery sharedPlotGallery] objectInSection:0 atIndex:0];
      
        detailItem.title = @"Projected Invested Worth";
        [detailItem renderInView:self.projectionPlotHostingView withTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme] animated:YES];
    }
    self.navigationController.navigationBarHidden = NO;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
