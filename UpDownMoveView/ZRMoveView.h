//
//  ZRMoveView.h
//  UpDownMoveView
//
//  Created by Seiko on 17/3/27.
//  Copyright © 2017年 RuiZhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ZRMoveView;

@protocol ZRMoveViewDelegate <NSObject>

- (NSInteger)numberOfVisibleItemsForMoveView:(ZRMoveView *)moveView;

- (NSArray*)dataSourceArrayForMoveView:(ZRMoveView *)moveView;

- (void)createItemView:(UIView *)itemView forMoveView:(ZRMoveView *)moveView;

- (void)updateItemView:(UIView *)itemView withData:(id)data forMoveView:(ZRMoveView *)moveView;


@end

@interface ZRMoveView : UIView

@property (nonatomic, weak)   id<ZRMoveViewDelegate> moveDelegate;
@property (nonatomic, assign) NSTimeInterval timeIntervalPerScroll;
@property (nonatomic, assign) NSTimeInterval timeDurationPerScroll;
@property (nonatomic, assign) BOOL clipsToBounds;

- (void)reloadData;
- (void)start;
- (void)pause;



@end
