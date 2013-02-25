//
//  Product.h
//  ShoppingList
//
//  Created by edzio27 on 25.02.2013.
//  Copyright (c) 2013 edzio27. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Product : NSManagedObject

@property (nonatomic, retain) NSString * productAmount;
@property (nonatomic, retain) NSNumber * productBought;
@property (nonatomic, retain) NSString * productName;
@property (nonatomic, retain) NSDate * productTimeStamp;

@end
