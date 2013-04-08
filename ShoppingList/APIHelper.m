//
//  APIHelper.m
//  ShoppingList
//
//  Created by Edzio27 Edzio27 on 30.03.2013.
//  Copyright (c) 2013 edzio27. All rights reserved.
//

#import "APIHelper.h"
#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "Product.h"

#define URL @"http://testurlgae.appspot.com"

@implementation APIHelper

- (void)addProductWithDictionary:(NSMutableDictionary *)dictionary andHandler:(void(^)(NSDecimalNumber *result))handler {

    NSURL *url = [NSURL URLWithString:URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *urlRequest = [httpClient requestWithMethod:@"GET" path:@"addproduct" parameters:dictionary];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSDictionary *responseDictionary = [JSON objectAtIndex:0];
        NSLog(@"App.net Global Stream: %@", [responseDictionary objectForKey:@"apiid"]);
        handler([responseDictionary objectForKey:@"apiid"]);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error %@", error);
    }];
    [operation start];
    
}

- (void)getProductListWithHandler:(void(^)(NSMutableArray *result))handler {

    NSURL *url = [NSURL URLWithString:URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
        handler(JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error %@", error);
    }];
    [operation start];
}

- (void)removaAllElementsFromServer {
    NSURL *url = [NSURL URLWithString:URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSMutableURLRequest *urlRequest = [httpClient requestWithMethod:@"GET" path:@"deleteall" parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error %@", error);
    }];
    [operation start];
}

- (void)getIdList {
    
    NSURL *url = [NSURL URLWithString:URL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error %@", error);
    }];
    [operation start];
}

- (void)deleteProduct:(Product *)product {
    NSURL *url = [NSURL URLWithString:URL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSLog(@"api id %@", product.apiId);
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjects:@[product.apiId]
                                                                         forKeys:@[@"apiid"]];
    
    NSMutableURLRequest *urlRequest = [httpClient requestWithMethod:@"GET" path:@"deleteproduct" parameters:dictionary];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"App.net Global Stream: %@", JSON);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"error %@", error);
    }];
    [operation start];
}

@end
