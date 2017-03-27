//
//  ZRWeakTimer.h
//  UpDownMoveView
//
//  Created by Seiko on 17/3/27.
//  Copyright © 2017年 RuiZhang. All rights reserved.
//

#import <Foundation/Foundation.h>


//ZRWeakTimer` behaves similar to an `NSTimer` but doesn't retain the target.
//This timer is implemented using GCD, so you can schedule and unschedule it on arbitrary queues (unlike regular NSTimers!)

@interface ZRWeakTimer : NSObject

/*
 Sets the amount of time after the scheduled fire date that the timer may fire to the given interval.
 */

@property (atomic, assign) NSTimeInterval tolerance;


- (id)initWithTimeInterval:(NSTimeInterval)timeInterval
                    target:(id)target
                  selector:(SEL)selector
                  userInfo:(id)userInfo
                   repeats:(BOOL)repeats
             dispatchQueue:(dispatch_queue_t)dispatchQueue;



+ (instancetype)scheduledTimerWithTimeInterval:(NSTimeInterval)timeInterval
                                        target:(id)target
                                      selector:(SEL)selector
                                      userInfo:(id)userInfo
                                       repeats:(BOOL)repeats
                                 dispatchQueue:(dispatch_queue_t)dispatchQueue;

/*
  Starts the timer if it hadn't been schedule yet.
 */

- (void)schedule;

- (void)fire;

- (void)invalidate;

- (id)userInfo;



@end
