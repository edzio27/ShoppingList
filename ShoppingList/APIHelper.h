//
//  APIHelper.h
//  ShoppingList
//
//  Created by Edzio27 Edzio27 on 30.03.2013.
//  Copyright (c) 2013 edzio27. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Product.h"

@interface APIHelper : NSObject

- (void)addProductWithDictionary:(NSMutableDictionary *)dictionary andHandler:(void(^)(NSDecimalNumber *result))handler;
- (void)getProductList;
- (void)getIdList;
- (void)deleteProduct:(Product *)product;

@end
