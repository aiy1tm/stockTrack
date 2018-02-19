//
//  AdvancedModeViewController.h
//  stockTrack
//
//  Created by Scott Sullivan on 5/21/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AdvancedModeViewController : UIViewController

@property (strong, nonatomic) NSString *positionName;
@property BOOL isNewPosition;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;
- (IBAction)returnHome:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
- (IBAction)scheduleBuys:(id)sender;
- (IBAction)tapSetShare:(id)sender;
- (IBAction)tapSetBasis:(id)sender;



@end
