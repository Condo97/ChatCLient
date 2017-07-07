//
//  CoreDataHandler.h
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/30/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "Chat+CoreDataClass.h"


@interface CoreDataHandler : NSObject

+ (CoreDataHandler *)sharedInstance;
- (void)saveToCoreData:(NSObject *)value entityName:(NSString *)name forKey:(NSString *)key;
- (NSObject *)fetchFromCoreData:(NSString *)entityName;
-(void)clearChat;

@end
