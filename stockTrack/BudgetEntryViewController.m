//
//  BudgetEntryViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 3/3/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "BudgetEntryViewController.h"
#import "BudgetModel.h"

@interface BudgetEntryViewController ()

@end

@implementation BudgetEntryViewController

@synthesize amountEntryField, typeSegmenter, frequencySegmenter, entryNameField, entryName, entryFrequency, budgetAmount;
@synthesize tapRecognizer;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.entryNameField.text = self.entryName;
    if (self.budgetAmount) {
        
        float dollarAmount = [self.budgetAmount floatValue]/100;
        if (dollarAmount<0) {
            self.typeSegmenter.selectedSegmentIndex = 0;
        }
        else{
            self.typeSegmenter.selectedSegmentIndex = 1;
        }
        self.amountEntryField.text = [NSString stringWithFormat:@"%.02f",fabs(dollarAmount)];
    }
    
    if ([self.entryFrequency isEqualToString:@"yearly"]) {
        [self.frequencySegmenter setSelectedSegmentIndex:1];
    }
    
    [self.typeSegmenter addTarget:self
                               action:@selector(typeChanged)
                     forControlEvents:UIControlEventValueChanged];
    //Keyboard stuff
    tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapAnywhere:)];
    tapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapRecognizer];
    
}

-(void) didTapAnywhere:(UITapGestureRecognizer*)sender
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    UITableViewController* destController = segue.destinationViewController;
    [destController.tableView reloadData];
    NSLog(@"calls the segue");
}

- (void) typeChanged
{
    
}

- (IBAction)budgetSubmit:(id)sender {
    
    NSCharacterSet * symbolSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789 "] invertedSet];
    NSCharacterSet * amountSet = [[NSCharacterSet characterSetWithCharactersInString:@".,0123456789"] invertedSet];
    
    if (([self.entryNameField.text rangeOfCharacterFromSet:symbolSet].location != NSNotFound)||([self.amountEntryField.text rangeOfCharacterFromSet:amountSet].location != NSNotFound)) {
        NSLog(@"This string contains illegal characters");
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Entry"
                                                                       message:@"Entry name or amount contains invalid characters. Please try again."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        
        NSString *freq;
        switch (self.frequencySegmenter.selectedSegmentIndex) {
            case 0:
                //monthly
                freq = @"monthly";
                break;
            case 1:
                //yearly
                freq = @"yearly";
                break;
                
            default:
                break;
        }
        
        switch (self.typeSegmenter.selectedSegmentIndex)
        {
                

            case 0: // expense
                [[BudgetModel dataHandler] addBudgetItem:self.entryNameField.text forDollarAmount:-[self.amountEntryField.text floatValue] andFrequency:freq];
                NSLog(@"add expense");
                break;
                
            case 1:  // savings
                NSLog(@"add savings");
               [[BudgetModel dataHandler] addBudgetItem:self.entryNameField.text forDollarAmount:[self.amountEntryField.text floatValue] andFrequency:freq];
                break;
                
        }
        
    }
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}
@end
