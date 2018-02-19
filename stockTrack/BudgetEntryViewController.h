//
//  BudgetEntryViewController.h
//  stockTrack
//
//  Created by Scott Sullivan on 3/3/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BudgetEntryViewController : UIViewController
@property (strong, nonatomic) NSString* entryName;
@property (strong, nonatomic) NSString* entryFrequency;
@property (strong, nonatomic) NSNumber* budgetAmount;
@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmenter;
@property (weak, nonatomic) IBOutlet UITextField *entryNameField;
@property (weak, nonatomic) IBOutlet UITextField *amountEntryField;
@property (nonatomic) UITapGestureRecognizer *tapRecognizer;

@property (weak, nonatomic) IBOutlet UISegmentedControl *frequencySegmenter;
- (IBAction)budgetSubmit:(id)sender;

@end
