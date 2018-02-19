//
//  PositionEditorViewController.h
//  stockTrack
//
//  Created by Scott Sullivan on 2/10/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PositionEditorViewController : UIViewController

@property (strong, nonatomic) NSString *positionName;
@property BOOL isNewPosition;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
@property (weak, nonatomic) IBOutlet UITextField *posTextField;

@property (weak, nonatomic) IBOutlet UITextField *amountTextField;




@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSelectSegment;
@property (weak, nonatomic) IBOutlet UISegmentedControl *currencySelection;

- (IBAction)submitPress:(id)sender;

@end
