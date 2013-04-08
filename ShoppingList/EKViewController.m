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
#import "APIHelper.h"

#define ADD_PRODUCT_TAG 111
#define UPLOAD_LIST_ALERT 222
#define DOWNLOAD_LIST_ALERT 333

@interface EKViewController ()

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *productList;
@property (nonatomic, strong) NSMutableArray *productToBuy;
@property (nonatomic, strong) NSMutableArray *productBought;

@property (nonatomic, strong) UIBarButtonItem *uploadAllProductsToServerItem;
@property (nonatomic, strong) UIBarButtonItem *downloadAllProductFromServerItem;

@property (nonatomic, strong) UIAlertView *addProductAlertView;
@property (nonatomic, strong) UIAlertView *uploadListAlertView;
@property (nonatomic, strong) UIAlertView *downloadListAlertView;

@property (nonatomic, strong) UIAlertView *noConnectionAlert;

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic, strong) APIHelper *apiHelper;
@property (nonatomic, strong) UIButton *downloadButton;

@end

@implementation EKViewController

- (UIButton *)downloadButton {
    if(_downloadButton == nil) {
        _downloadButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 370, 280, 30)];
        _downloadButton.backgroundColor = [UIColor colorWithRed:1 green:0.6 blue:0 alpha:1];
        [_downloadButton setTitle:@"Dodaj produkt" forState:UIControlStateNormal];
        [_downloadButton addTarget:self action:@selector(addProductMethod) forControlEvents:UIControlEventTouchUpInside];
    }
    return _downloadButton;
}

- (void)addAllProductToServer {
    if([self isThereInternetConnection]) {
        [self.apiHelper removaAllElementsFromServer];
        for(int i = 0; i < self.productToBuy.count; i++) {
            /* add product to server */
            Product *product = [self.productToBuy objectAtIndex:i];
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:@[product.productName,
                                               product.productAmount,
                                               @"2013:03:30"]
                                                                                 forKeys:@[@"name",@"amount", @"time_stamp"]];
            [self addProduct:product ToServerWithDictionary:dictionary];
        }
    } else {
        [self showInternetConnectionTrouble];
    }
}

- (UIAlertView *)noConnectionAlert {
    if(_noConnectionAlert == nil) {
        _noConnectionAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No internet connection" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    }
    return _noConnectionAlert;
}

- (UIAlertView *)uploadListAlertView {
    if(_uploadListAlertView == nil) {
        _uploadListAlertView = [[UIAlertView alloc] initWithTitle:@"Wysłanie listy" message:@"Chcesz wysłać listę na serwer? Wszystkie dane z serwera zostana skasowane!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Upload", nil];
        _uploadListAlertView.tag = UPLOAD_LIST_ALERT;
    }
    return _uploadListAlertView;
}

- (UIAlertView *)downloadListAlertView {
    if(_downloadListAlertView == nil) {
        _downloadListAlertView = [[UIAlertView alloc] initWithTitle:@"Pobranie listy" message:@"Chcesz pobrać listę z serwera? Wszystkie dane z aktualnej listy zostana skasowane!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Download", nil];
        _downloadListAlertView.tag = DOWNLOAD_LIST_ALERT;
    }
    return _downloadListAlertView;
}

- (APIHelper *)apiHelper {
    if(_apiHelper == nil) {
        _apiHelper = [[APIHelper alloc] init];
    }
    return _apiHelper;
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

- (void)addProductMethod {
    [self.addProductAlertView show];
}

- (UIBarButtonItem *)uploadAllProductsToServerItem {
    if(_uploadAllProductsToServerItem == nil) {
        UIButton *someButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        [someButton setBackgroundImage:[UIImage imageNamed:@"arrowup"] forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(showUploadAlertView)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        _uploadAllProductsToServerItem = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    }
    return _uploadAllProductsToServerItem;
}

- (void)showUploadAlertView {
    [self.uploadListAlertView show];
}

- (UIBarButtonItem *)downloadAllProductFromServerItem {
    if(_downloadAllProductFromServerItem == nil) {
        UIButton *someButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 26, 26)];
        [someButton setBackgroundImage:[UIImage imageNamed:@"arrowdown"] forState:UIControlStateNormal];
        [someButton addTarget:self action:@selector(showDownloadAlertView)
             forControlEvents:UIControlEventTouchUpInside];
        [someButton setShowsTouchWhenHighlighted:YES];
        _downloadAllProductFromServerItem = [[UIBarButtonItem alloc] initWithCustomView:someButton];
    }
    return _downloadAllProductFromServerItem;
}

- (void)showDownloadAlertView {
    [self.downloadListAlertView show];
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
                                                                   - 44 - 50)];
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
    self.navigationItem.rightBarButtonItem = self.uploadAllProductsToServerItem;
    self.navigationItem.leftBarButtonItem = self.downloadAllProductFromServerItem;
    [self.view addSubview:self.downloadButton];
    self.navigationItem.title = @"Lista zakupów";
    
    
    self.view.backgroundColor = [UIColor colorWithRed:0.373 green:0.373 blue:0.373 alpha:1];
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:1 green:0.6 blue:0 alpha:1];
    //NSTimer* myTimer = [NSTimer scheduledTimerWithTimeInterval: 10.0 target: self
    //                                                  selector: @selector(automaticUpdateProductsFromServer) userInfo: nil repeats: YES];
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
        NSLog(@"api id %@", product.apiId);

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

#pragma mark api methods

- (void)addProduct:(Product *)product ToServerWithDictionary:dictionary {
    [self.apiHelper addProductWithDictionary:dictionary andHandler:^(NSDecimalNumber *result) {
        product.apiId = result;
    }];
}

- (void)refreshProductList {
    [self.apiHelper getProductListWithHandler:^(NSMutableArray *result) {
        [self.productToBuy removeAllObjects];
        for(NSMutableDictionary *dictionary in result) {
            Product *product = [NSEntityDescription insertNewObjectForEntityForName:@"Product" inManagedObjectContext:self.managedObjectContext];
            product.productName = [dictionary objectForKey:@"name"];
            product.productAmount = [dictionary objectForKey:@"amount"];
            product.productBought = [NSNumber numberWithBool:NO];
            product.productTimeStamp = [NSDate date];
            product.apiId = [dictionary objectForKey:@"apiid"];
            [self.productToBuy addObject:product];
        }
        [self saveCurrentContext];
        [self.tableView reloadData];
    }];
}

- (void)deleteProduct:(Product *)product {
    NSLog(@"api id %@", product.apiId);
    [self.apiHelper deleteProduct:product];
}

#pragma end

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

#pragma end

#pragma mark alertView delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == ADD_PRODUCT_TAG) {
        if(buttonIndex == 1) {
            [self addNewProduct:[alertView textFieldAtIndex:0].text];
        }
    }
    if(alertView.tag == UPLOAD_LIST_ALERT) {
        if(buttonIndex == 1) {
            [self addAllProductToServer];
        }
    }
    if(alertView.tag == DOWNLOAD_LIST_ALERT) {
        [self refreshProductList];
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

/* Update only when user wants to */
- (void)updateProductsFromServer {
    if([self isThereInternetConnection]) {
        [self refreshProductList];
    } else {
        [self showInternetConnectionTrouble];
    }
}
@end
