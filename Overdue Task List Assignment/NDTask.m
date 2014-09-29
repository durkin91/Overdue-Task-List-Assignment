//
//  NDTask.m
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import "NDTask.h"

@implementation NDTask

-(id)init
{
    self = [self initWithData:nil];
    return self;
}

-(NDTask *)initWithData:(NSDictionary *)data
{
    self = [super init];
    self.title = data[TITLE];
    self.description = data[DESCRIPTION];
    self.dueDate = data[DUE_DATE];
    self.completed = [data[COMPLETION] boolValue];
    
    return self;
}

@end
