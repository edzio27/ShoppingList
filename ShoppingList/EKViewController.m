//
//  EKViewController.m
//  ShoppingList
//
//  Created by edzio27 on 24.02.2013.
//  Copyright (c) 2013 edzio27. All rights reserved.
//

#import "EKViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Product.h"
#import <CoreData/CoreData.h>
#import "EKAppDelegate.h"
#import "Reachability.h"

#define ADD_PRODUCT_TAG 111

@interface EKViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *productList;
@property (nonatomic, strong) NSMutableArray *productToBuy;
@property (nonatomic, strong) NSMutableArray *productBought;
@property (nonatomic, strong) UIBarButtonItem *addProduct;
@property (nonatomic, strong) UIBarButtonItem *refreshContext;
@property (nonatomic, strong) UIAlertView *addProductAlertView;
@property (nonatomic, strong) UIAlertView *noConnectionAlert;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@end

@implementation EKViewController

- (UIAlertView *)noConnectionAlert {
    if(_noConnectionAlert == nil) {
        _noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    return _noConnectionAlert;
}

- (UIAlertView *)addProductAlertView {
    if(_addProductAlertView == nil) {
        _addProductAlertView = [[UIAlertView alloc] initWithTitle:@"Add new product" message:@"Set name of product" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        _addProductAlertView.tag = ADD_PRODUCT_TAG;
        _addProductAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [_addProductAlertView textFieldAtIndex:0].returnKeyType = UIReturnKeyDone;
        [_addProductAlertView textFieldAtIndex:0].delegate = self;
    }
    [_addProductAlertView textFieldAtIndex:0].text = @"";
    return _addProductAlertView;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self addNewProduct:textField.text];
}

- (void)addProductMethod {
    [self.addProductAlertView show];
}

- (UIBarButtonItem *)addProduct {
    if(_addProduct == nil) {
        _addProduct = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addProductMethod)];
    }
    return _addProduct;
}

- (UIBarButtonItem *)refreshContext {
    if(_refreshContext == nil) {
        _refreshContext = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(updateProductsFromServer)];
    }
    return _refreshContext;
}

- (NSMutableArray *)productBought {
    if(_productBought == nil) {
        _productBought = [[NSMutableArray alloc] init];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"productTimeStamp" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productBought = YES"];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        
        NSError *error;
        _productBought = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    }
    return _productBought;
}

- (NSMutableArray *)productToBuy {
    if(_productToBuy == nil) {
        _productToBuy = [[NSMutableArray alloc] init];
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription
                                       entityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
        NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"productTimeStamp" ascending:YES];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"productBought = NO"];
        [fetchRequest setEntity:entity];
        [fetchRequest setPredicate:predicate];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:descriptor]];
        
        NSError *error;
        _productToBuy = [[self.managedObjectContext executeFetchRequest:fetchRequest error:&error] mutableCopy];
    }
    return _productToBuy;
}


- (NSMutableArray *)productList {
    if(_productList == nil) {
        _productList = [[NSMutableArray alloc] init];
        [_productList addObject:self.productToBuy];
        [_productList addObject:self.productBought];
    }
    return _productList;
}

- (NSManagedObjectContext *)managedObjectContext {
    if(_managedObjectContext == nil) {
        EKAppDelegate *appDelegate = (EKAppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = appDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if(_persistentStoreCoordinator == nil) {
        EKAppDelegate *appDelegate = (EKAppDelegate *)[[UIApplication sharedApplication] delegate];
        _persistentStoreCoordinator = appDelegate.persistentStoreCoordinator;
    }
    return _persistentStoreCoordinator;
}

- (UITableView *)tableView {
    if(_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(12, 12, 296, [UIScreen mainScreen].bounds.size.height
                                                                   - self.navigationController.navigationBar.frame.size.height
                                                                   - self.tabBarController.tabBar.frame.size.height
                                                                   - 44)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.tableView.layer.cornerRadius = 3.0;
    self.tableView.showsHorizontalScrollIndicator = NO;
    self.tableView.showsVerticalScrollIndicator = NO;
    self.navigationItem.rightBarButtonItem = self.addProduct;
    self.navigationItem.leftBarButtonItem = self.refreshContext;
    NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
                                                      selector: @selector(automaticUpdateProductsFromServer) userInfo: nil repeats: YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark tableview delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0)
        return @"Kupić";
    else
        return @"Kupione";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return self.productToBuy.count;
    else
        return self.productBought.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Identifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    if(cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    Product *product = [[self.productList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    cell.textLabel.text = product.productName;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0) {
        Product *product = [self.productToBuy objectAtIndex:indexPath.row];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self.tableView beginUpdates];
        [self.tableView moveRowAtIndexPath:indexPath toIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
        [self.productToBuy removeObject:product];
        [self.productBought addObject:product];
        [self.tableView endUpdates];
        
        [self.managedObjectContext updatedObjects];
        [self saveCurrentContext];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40.0f;
}

- (void)saveCurrentContext {
    NSError *error;
    if(![self.managedObjectContext save:&error]) {
        NSLog(@"error");
    }
}

- (void)addNewProduct:(NSString *)productName {
    
    Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
    product.productName = productName;
    product.productAmount = @"1";
    product.productBought = [NSNumber numberWithBool:NO];
    product.productTimeStamp = [NSDate date];
    
    [self saveCurrentContext];
    
    [self.productToBuy addObject:product];
    [self.tableView beginUpdates];
    [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
    [self.tableView reloadData];
}

#pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == ADD_PRODUCT_TAG) {
        if(buttonIndex == 1) {
            [self addNewProduct:[alertView textFieldAtIndex:0].text];
        }
    }
}

#pragma end

/* Check is there a internet connection */
- (BOOL)isThereInternetConnection {
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    return internetStatus != NotReachable ? YES : NO;
}

- (void)showInternetConnectionTrouble {
    [self.noConnectionAlert show];
}

/* Every 60 seconds automatoc update */
- (void)automaticUpdateProductsFromServer {
    if([self isThereInternetConnection]) {
        /* TODO automatically updates context on device and switch badges */
        
        
        /* TODO check is there any difference between what you get from server and what you have in application */
        /* If there any difference let know user, to make updated list on phone */
        /* There also want be any conflict */
    }
}

/* Update only when user wants to */
- (void)updateProductsFromServer {
    if([self isThereInternetConnection]) {
        /* update */
    } else {
        [self showInternetConnectionTrouble];
    }
}
@end
