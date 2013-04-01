//
//  Product.h
//  ShoppingList
//
//  Created by Edzio27 Edzio27 on 01.04.2013.
//  Copyright (c) 2013 edzio27. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Product : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * apiId;
@property (nonatomic, retain) NSString * productAmount;
@property (nonatomic, retain) NSNumber * productBought;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSDate * productTimeStamp;

@end
