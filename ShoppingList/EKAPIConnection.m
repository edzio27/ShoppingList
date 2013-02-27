//
//  EKAPIConnection.m
//  ShoppingList
//
//  Created by edzio27 on 27.02.2013.
//  Copyright (c) 2013 edzio27. All rights reserved.
//

#import "EKAPIConnection.h"

NSString *registerUserURL = @"http://szkolaperfect.pl/product/register.php";

@implementation EKAPIConnection

- (NSString *)getJSONFromDeviceRegister {
    
    NSArray *objectArray = [NSArray arrayWithObjects:[[UIDevice currentDevice] uniqueIdentifier],
                            nil];
    
    NSArray *keyArray = [NSArray arrayWithObjects:@"udid",
                         nil];
    
    NSDictionary *jsondictionary = [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray];
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsondictionary options:NSJSONReadingMutableContainers error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}


- (void)registerDevice {
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:registerUserURL]
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    NSData *requestData = [NSData dataWithBytes:[[self getJSONFromDeviceRegister] UTF8String] length:[[self getJSONFromDeviceRegister] length]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody: requestData];
    
    NSLog(@"jsonik %@", [self getJSONFromDeviceRegister]);
    NSLog(@"address %@", registerUserURL);
    
    NSError *error;
    NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:returnData options:kNilOptions error:&error];
    
    NSLog(@"dictionaory %@", dictionary);
    NSString *returnString = [dictionary objectForKey:@"access_token"];
    
    [prefs setValue:returnString forKey:@"access_token"];
}

@end
