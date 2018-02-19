//
//  ProjectionViewController.h
//  stockTrack
//
//  Created by Scott Sullivan on 4/23/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BudgetModel.h"
#import "PositionModel.h"
#import "PlotGallery.h"

@interface ProjectionViewController : UIViewController
@property (weak, nonatomic) IBOutlet CPTGraphHostingView *projectionPlotHostingView;
@property (weak, nonatomic) IBOutlet UIButton *swrButton;
@property (weak, nonatomic) IBOutlet UIButton *apyButton;
@property (weak, nonatomic) IBOutlet UISlider *swrSlider;
@property (weak, nonatomic) IBOutlet UISlider *apySlider;

@end
