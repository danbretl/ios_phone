//
//  Category.m
//  Abextra
//
//  Created by Dan Bretl on 6/7/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "Category.h"
#import "Event.h"

@implementation Category
@dynamic colorHex;
@dynamic title;
@dynamic uri;
@dynamic thumbnail;
@dynamic displayOrder;
@dynamic eventsDeprecated;
@dynamic eventsNew;

- (void)addEventsDeprecatedObject:(Event *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"eventsDeprecated"] addObject:value];
    [self didChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeEventsDeprecatedObject:(Event *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"eventsDeprecated"] removeObject:value];
    [self didChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addEventsDeprecated:(NSSet *)value {    
    [self willChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"eventsDeprecated"] unionSet:value];
    [self didChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeEventsDeprecated:(NSSet *)value {
    [self willChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"eventsDeprecated"] minusSet:value];
    [self didChangeValueForKey:@"eventsDeprecated" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

- (void)addEventsNewObject:(CategoryBreadcrumb *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"eventsNew"] addObject:value];
    [self didChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeEventsNewObject:(CategoryBreadcrumb *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"eventsNew"] removeObject:value];
    [self didChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addEventsNew:(NSSet *)value {    
    [self willChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"eventsNew"] unionSet:value];
    [self didChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeEventsNew:(NSSet *)value {
    [self willChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"eventsNew"] minusSet:value];
    [self didChangeValueForKey:@"eventsNew" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}

@end
