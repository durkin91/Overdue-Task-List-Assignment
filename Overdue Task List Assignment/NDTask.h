//
//  NDTask.h
//  Overdue Task List Assignment
//
//  Created by Nikki Durkin on 9/29/14.
//  Copyright (c) 2014 Nikki Durkin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NDTask : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSDate *dueDate;
@property (nonatomic) BOOL completed;

-(NDTask *)initWithData:(NSDictionary *)data;
-(NSString *)convertDateIntoDueDateFormat;
-(int)daysLeftUntilTaskDue;
-(UIColor *)colorForDueDateString;
@end
