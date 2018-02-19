//
//  PositionEditorViewController.m
//  stockTrack
//
//  Created by Scott Sullivan on 2/10/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "PositionEditorViewController.h"
#import "PositionModel.h"
#import "AdvancedModeViewController.h"

@interface PositionEditorViewController ()

@end

@implementation PositionEditorViewController

@synthesize positionName;
@synthesize isNewPosition;
@synthesize tapRecognizer;
@synthesize typeSelectSegment, currencySelection;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
   
    self.posTextField.text = self.positionName;
    self.posTextField.enabled = self.isNewPosition;
    [self.typeSelectSegment addTarget:self
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


- (void) typeChanged
{
    // update the ui appropriately for buy / sell/ edit. 0,1,2
    
    switch (self.typeSelectSegment.selectedSegmentIndex)
    {
        case 0:{ // buy
      
            [UIView animateWithDuration:0.3 animations:^{
                self.currencySelection.hidden = NO;

                
               }];
            NSLog(@"buy");
            break;
        }
        case 1:  //sell
        {
            NSLog(@"Sell");
          
            [UIView animateWithDuration:0.3 animations:^{
                
                self.currencySelection.hidden = NO;
                }];
            break;
        }
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)submitPress:(id)sender {
    
    NSCharacterSet * symbolSet = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789."] invertedSet];
    NSCharacterSet * amountSet = [[NSCharacterSet characterSetWithCharactersInString:@".,0123456789"] invertedSet];
    
    if (([self.posTextField.text rangeOfCharacterFromSet:symbolSet].location != NSNotFound)||([self.amountTextField.text rangeOfCharacterFromSet:amountSet].location != NSNotFound)||[self.amountTextField.text isEqualToString:@""]) {
        NSLog(@"This string contains illegal characters");
        
        UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invalid Entry"
                                                                       message:@"Ticker symbol or amount contains invalid characters. Please try again."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction * action) {}];
        
        [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        int errorCode;
        NSString *negString = [NSString stringWithFormat:@"-%@",self.amountTextField.text];
        NSDecimalNumber* theAmount =[NSDecimalNumber decimalNumberWithString:self.amountTextField.text];
        NSDecimalNumber* negAmount =[NSDecimalNumber decimalNumberWithString:negString];
    switch (self.typeSelectSegment.selectedSegmentIndex)
        {
        case 0: // buy
            if (self.currencySelection.selectedSegmentIndex==0) {
                NSLog(@"buy for dollar amt");
                errorCode = [[PositionModel dataHandler] addPositionIn:self.posTextField.text forDollarAmount:theAmount];
            }else{
                NSLog(@"buy for share aamt");
          errorCode =   [[PositionModel dataHandler] addPositionIn:self.posTextField.text forShareAmount:theAmount];
            }
            
            NSLog(@"buy");
            break;
            
        case 1:  //sell
        {
            NSLog(@"Sell");
            
            if (self.currencySelection.selectedSegmentIndex==0) {
           errorCode =     [[PositionModel dataHandler] addPositionIn:self.posTextField.text forDollarAmount:negAmount];
            }else{
            errorCode =    [[PositionModel dataHandler] addPositionIn:self.posTextField.text forShareAmount:negAmount];
            }
            break;
    }
        case 2: // edit
            NSLog(@"edit");
#warning update all parameters of a position here.
            break;
    }
        
        if (errorCode) {
            UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                           message:@"Data unavailable. Check your connectivity and ticker symbol."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * action) {}];
            
            [alert addAction:defaultAction];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    
   
    
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
     if ([segue.identifier isEqualToString:@"advancedOptions"])
     {
         AdvancedModeViewController *destController = segue.destinationViewController;
         destController.positionName = self.positionName;
     }
    
    
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender{
    
    if ([identifier isEqualToString:@"advancedOptions"]&&self.isNewPosition) {
        [self showNoAdvancedWarning];
        return NO;
    }
    return YES;
}

- (void) showNoAdvancedWarning
{
#warning this could be the prompt to buy the IAP...
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Advanced Settings Only For Existing Positions"
                                                                   message:@"Advanced Settings: Scheduled Buying & Full Manual Cost Basis and Share Count Editing"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction * action) { }];
    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}



@end
