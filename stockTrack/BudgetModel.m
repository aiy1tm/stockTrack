//
//  BudgetModel.m
//  stockTrack
//
//  Created by Scott Sullivan on 2/28/16.
//  Copyright © 2016 Scott Sullivan. All rights reserved.
//

#import "BudgetModel.h"

@implementation BudgetModel

@synthesize budgetDictionary;
@synthesize expenseList;
@synthesize savingsList;

+ (instancetype) dataHandler
{
    
    static BudgetModel *handler = nil;
    
    if (!handler) {
        handler = [[self alloc] initPrivate];
    }
    
    return handler;
}

- (instancetype) init
{
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[BudgetModel dataHandler]" userInfo:nil];
}

- (instancetype) initPrivate
{
    self = [super init];
    

    self.budgetDictionary = [NSMutableDictionary dictionary];
    self.savingsList = [[NSMutableArray alloc] init];
    self.expenseList = [[NSMutableArray alloc] init];
    self.SWR = 0.04;
    self.expectedGain = 0.07;
    [self restoreState];

    
    return self;
}

- (double) fiNumber
{
    double fiNum = 12*[self totalMonthlyExpenses]/self.SWR;
    //NSLog(@"fi number %lf",fiNum);
    return fiNum;
}

#pragma mark -- data operations

- (void) addBudgetItem:(NSString *)itemName forPennyAmount:(int)pennyAmount andFrequency:(NSString *)freq
{// work in pennies
    
        if (pennyAmount<0) {
           if (![self.expenseList containsObject:itemName])[self.expenseList addObject:itemName];
            if ([self.savingsList containsObject:itemName]) {
                //remove it from savings if it were there
                [self.savingsList removeObject:itemName];
            }
        }else{
            if (![self.savingsList containsObject:itemName])[self.savingsList addObject:itemName];
            if ([self.expenseList containsObject:itemName]) {
                //remove it from expense if it were there before
                [self.expenseList removeObject:itemName];
            }
        }
    
    NSDictionary *budgetEntry =@{@"budgetedPennies":[NSNumber numberWithInt:pennyAmount],
                                 @"budgetFrequency":freq};
    
    [self.budgetDictionary setObject:budgetEntry forKey:itemName];
   
        }


- (void) addBudgetItem:(NSString *)itemName forDollarAmount:(float)dollarAmount andFrequency:(NSString *)freq
{// fundamentally work in pennies to avoid floating point issues. so convert dollars to pennies then call the penny method...
    
    int dollarsInCents = roundf(100*dollarAmount);
    
    [self addBudgetItem:itemName forPennyAmount:dollarsInCents andFrequency:freq];
    
}

- (int) monthsToFiForCagr: (float) cagr andNestEgg: (NSDecimalNumber*) egg andSWR: (float) swr
{

    double eggDouble = [egg doubleValue];
    
   float monthlyExpenses = [self totalMonthlyExpenses];
    
   float monthlySavings = [self totalMonthlySavings];

    
    float yearsToFi=log((12*monthlySavings+cagr*(1+cagr)*((1/swr)*12*(monthlyExpenses)))/((1+cagr)*(12*monthlySavings+cagr*eggDouble)))/log(1+cagr);
    

    return 12*yearsToFi;
}

- (float) totalMonthlyExpenses
{
    float preFactor = 1;
    float monthlyExpenses = 0.1;
    for (NSString *budgetItem in self.expenseList) {
        // sum expenses over dictionary
        if([self.budgetDictionary[budgetItem][@"budgetFrequency"] isEqualToString:@"yearly"]) preFactor = 0.08333; //1/12
        else preFactor = 1;
        monthlyExpenses+= preFactor*0.01*fabs([self.budgetDictionary[budgetItem][@"budgetedPennies"] floatValue]); //stored in pennies make to dollars
    }
    
    return monthlyExpenses;
}

-(float) totalMonthlySavings
{
    float preFactor = 1;
    float monthlySavings = 0.1;
    for (NSString *budgetItem in self.savingsList) {
        // sum savings over dictionary
        if([self.budgetDictionary[budgetItem][@"budgetFrequency"] isEqualToString:@"yearly"]) preFactor = 0.08333; //1/12
        else preFactor = 1;
        monthlySavings+= preFactor*0.01*fabs([self.budgetDictionary[budgetItem][@"budgetedPennies"] floatValue]); //stored in pennies make to dollars
    }
    
    return monthlySavings;
}


#pragma mark - Saving and Loading

- (void) saveState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    
    //save the positions dictionary... and anything else.
    
    [defaults setObject:self.budgetDictionary forKey:@"budgetDict"];
    [defaults setObject:self.expenseList forKey:@"expList"];
    [defaults setObject:self.savingsList forKey:@"saveList"];
    [defaults setObject:[NSNumber numberWithFloat:self.SWR] forKey:@"safeRate"];
    [defaults setObject:[NSNumber numberWithFloat:self.expectedGain] forKey:@"expectedGain"];
    [defaults synchronize];
    
    NSLog(@"called savestate");
    
    
}

- (void) restoreState
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults synchronize];
    
    
    if ([defaults objectForKey:@"safeRate"]) self.SWR = [[defaults objectForKey:@"safeRate"] floatValue];
    if ([defaults objectForKey:@"expectedGain"]) self.expectedGain = [[defaults objectForKey:@"expectedGain"] floatValue];
       
    if ([defaults objectForKey:@"budgetDict"]) {
        
        self.budgetDictionary = [NSMutableDictionary dictionaryWithDictionary:[defaults objectForKey:@"budgetDict"]];
        self.expenseList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"expList"]];
        self.savingsList = [NSMutableArray arrayWithArray:[defaults objectForKey:@"saveList"]];
        
        // NSLog(@"called in positions dictionary. %@", self.positionDictionary);
    }
    
    
    
}

-(void) clearDefaults
{
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"posDict"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"ticklerList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"budgetDict"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"expList"];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"saveList"];
    
    [NSUserDefaults resetStandardUserDefaults];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
