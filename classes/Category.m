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
@dynamic events;

- (void)addEventsObject:(Event *)value {    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"events" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"events"] addObject:value];
    [self didChangeValueForKey:@"events" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)removeEventsObject:(Event *)value {
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    [self willChangeValueForKey:@"events" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveValueForKey:@"events"] removeObject:value];
    [self didChangeValueForKey:@"events" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [changedObjects release];
}

- (void)addEvents:(NSSet *)value {    
    [self willChangeValueForKey:@"events" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"events"] unionSet:value];
    [self didChangeValueForKey:@"events" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeEvents:(NSSet *)value {
    [self willChangeValueForKey:@"events" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveValueForKey:@"events"] minusSet:value];
    [self didChangeValueForKey:@"events" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}


@end
