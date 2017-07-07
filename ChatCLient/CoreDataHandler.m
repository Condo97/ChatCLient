//
//  CoreDataHandler.m
//  ChatCLient
//
//  Created by Alex Coundouriotis on 1/30/17.
//  Copyright © 2017 ACApplications. All rights reserved.
//

#import "CoreDataHandler.h"
#import "AppDelegate.h"


@implementation CoreDataHandler

+ (CoreDataHandler *)sharedInstance {
    static dispatch_once_t onceToken;
    static CoreDataHandler *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[CoreDataHandler alloc] init];
    });
    return instance;
}

- (void)saveToCoreData:(NSObject *)value entityName:(NSString *)name forKey:(NSString *)key {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
    
    /*NSManagedObject *newContact;
    newContact = [NSEntityDescription
                  insertNewObjectForEntityForName:@"Contacts"
                  inManagedObjectContext:context];
    [newContact setValue: _name.text forKey:@"name"];
    [newContact setValue: _address.text forKey:@"address"];
    [newContact setValue: _phone.text forKey:@"phone"];
    _name.text = @"";
    _address.text = @"";
    _phone.text = @"";*/
    NSError *error;
    [managedObject setValue:value forKey:key];

    
    [context save:&error];
    //_status.text = @"Contact saved";
    
    
    
    //NSManagedObjectContext *context = [self managedObjectContext];
    
    //Creating a new managed object
    //NSManagedObject *managedObject = [NSEntityDescription insertNewObjectForEntityForName:name inManagedObjectContext:context];
    //[managedObject setValue:value forKey:key];
    
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
}

- (NSObject *)fetchFromCoreData:(NSString *)entityName {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;
    
    //NSEntityDescription *entityDesc =  [NSEntityDescription entityForName:entityName  inManagedObjectContext:context];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];//[[NSFetchRequest alloc] init];
    //[request setEntity:entityDesc];
    
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"(name = %@)", _name.text];
    //[request setPredicate:pred];
    //NSManagedObject *matches = nil;
    
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request
                                              error:&error];
    
    if ([objects count] == 0) {
        NSLog(@"No Matches: %@\n%@",[error localizedDescription],[error userInfo]);
        return nil;
    } else {
        return objects;
        //matches = objects[0];
        //_address.text = [matches valueForKey:@"address"];
        //_phone.text = [matches valueForKey:@"phone"];
        //_status.text = [NSString stringWithFormat:
                        ///@"%lu matches found", (unsigned long)[objects count]];
    }
    
    //NSManagedObjectContext *context = [self managedObjectContext];
    //NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:entityName];
    //return [[context executeFetchRequest:fetchRequest error:nil] mutableCopy];
}

-(void)clearChat {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.persistentContainer.viewContext;

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Chat"];
    NSBatchDeleteRequest *deleteRequset = [[NSBatchDeleteRequest alloc] initWithFetchRequest:request];
    //NSError error = nil;
    [context executeRequest:deleteRequset error:nil];
}



//- (NSManagedObjectContext *)managedObjectContext {
//    NSManagedObjectContext *context = nil;
//    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    return delegate.persistentContainer.viewContext;
//}

//- (NSManagedObjectContext *)managedObjectContext {
//    if (managedObjectContext != nil) return managedObjectContext;
//    
//    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
//    if (coordinator != nil) {
//        
//        managedObjectContext = [[NSManagedObjectContext alloc] init];
//        [managedObjectContext setPersistentStoreCoordinator:coordinator];
//    }
//    return managedObjectContext;
//}

@end
