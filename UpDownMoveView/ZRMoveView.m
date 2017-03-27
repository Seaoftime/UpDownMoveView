//
//  ZRMoveView.m
//  UpDownMoveView
//
//  Created by Seiko on 17/3/27.
//  Copyright © 2017年 RuiZhang. All rights reserved.
//

#import "ZRMoveView.h"

#import "ZRWeakTimer.h"

@interface ZRMoveView ()

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, assign) NSInteger visibleItemCount;
@property (nonatomic, strong) NSMutableArray<UIView *> *items;
@property (nonatomic, assign) int topItemIndex;
@property (nonatomic, assign) int dataIndex;
@property (nonatomic, strong) ZRWeakTimer *scrollTimer;

@end

@implementation ZRMoveView

static NSInteger DEFAULT_VISIBLE_ITEM_COUNT = 2;
static NSTimeInterval DEFAULT_TIME_INTERVAL = 4.0;
static NSTimeInterval DEFAULT_TIME_DURATION = 1.0;

- (instancetype)init {
    self = [super init];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.clipsToBounds = YES;
        [self addSubview:_contentView];
        
        _timeIntervalPerScroll = DEFAULT_TIME_INTERVAL;
        _timeDurationPerScroll = DEFAULT_TIME_DURATION;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.contentView setFrame:self.bounds];
    [self repositionItemViews];
}

- (void)setClipsToBounds:(BOOL)clipsToBounds {
    _contentView.clipsToBounds = clipsToBounds;
}

- (void)reloadData {
    [self pause];
    
    if (_items) {
        [_items makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_items removeAllObjects];
    } else {
        _items = [NSMutableArray array];
    }
    
    if ([_moveDelegate respondsToSelector:@selector(numberOfVisibleItemsForMoveView:)]) {
        _visibleItemCount = [_moveDelegate numberOfVisibleItemsForMoveView:self];
        if (_visibleItemCount <= 0) {
            return;
        }
    } else {
        _visibleItemCount = DEFAULT_VISIBLE_ITEM_COUNT;
    }
    
    _dataIndex = 0;
    
    for (int i = 0; i < _visibleItemCount + 2; i++) {
        UIView *itemView = [[UIView alloc] init];
        [_contentView addSubview:itemView];
        [_items addObject:itemView];
    }
    _topItemIndex = 0;
    
    [self repositionItemViews];
    
    for (int i = 0; i < _items.count; i++) {
        int index = (i + _topItemIndex) % _items.count;
        if (i == 0) {
            if ([_moveDelegate respondsToSelector:@selector(createItemView:forMoveView:)]) {
                [_moveDelegate createItemView:_items[index] forMoveView:self];
            }
        } else  {
            if ([_moveDelegate respondsToSelector:@selector(createItemView:forMoveView:)]) {
                [_moveDelegate createItemView:_items[index] forMoveView:self];
            }
            if ([_moveDelegate respondsToSelector:@selector(updateItemView:withData:forMoveView:)]) {
                [_moveDelegate updateItemView:_items[index] withData:[self nextData] forMoveView:self];
            }
        }
    }
    
    [self startAfterTimeInterval:YES];
}

- (void)repositionItemViews {
    CGFloat itemWidth = CGRectGetWidth(self.frame);
    CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
    for (int i = 0; i < _items.count; i++) {
        int index = (i + _topItemIndex) % _items.count;
        if (i == 0) {
            [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
        } else if (i == _items.count - 1) {
            [_items[index] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
        } else {
            [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 1), itemWidth, itemHeight)];
        }
    }
}


- (void)start {
    [self startAfterTimeInterval:NO];
}


- (void)startAfterTimeInterval:(BOOL)afterTimeInterval {
    if (_scrollTimer || _items.count <= 0) {
        return;
    }
    
    if (!afterTimeInterval) {
        [self scrollTimerDidFire:nil];
    }
    _scrollTimer = [ZRWeakTimer scheduledTimerWithTimeInterval:_timeIntervalPerScroll
                                                        target:self
                                                      selector:@selector(scrollTimerDidFire:)
                                                      userInfo:nil
                                                       repeats:YES
                                                 dispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}


- (void)pause {
    if (_scrollTimer) {
        [_scrollTimer invalidate];
        _scrollTimer = nil;
    }
}


- (void)scrollTimerDidFire:(ZRWeakTimer *)timer {
    dispatch_async(dispatch_get_main_queue(), ^() {
        CGFloat itemWidth = CGRectGetWidth(self.frame);
        CGFloat itemHeight = CGRectGetHeight(self.frame) / _visibleItemCount;
        
        // move the top item to bottom without animation
        [_items[_topItemIndex] setFrame:CGRectMake(0.0f, CGRectGetMaxY(self.bounds), itemWidth, itemHeight)];
        if ([_moveDelegate respondsToSelector:@selector(updateItemView:withData:forMoveView:)]) {
            [_moveDelegate updateItemView:_items[_topItemIndex] withData:[self nextData] forMoveView:self];
        }
        
        int currentTopItemIndex = _topItemIndex;
        [UIView animateWithDuration:_timeDurationPerScroll animations:^{
            for (int i = 0; i < _items.count; i++) {
                int index = (i + currentTopItemIndex) % _items.count;
                if (i == 0) {
                    continue;
                } else if (i == 1) {
                    [_items[index] setFrame:CGRectMake(0.0f, -itemHeight, itemWidth, itemHeight)];
                } else {
                    [_items[index] setFrame:CGRectMake(0.0f, itemHeight * (i - 2), itemWidth, itemHeight)];
                }
            }
        }];
        [self moveToNextItemIndex];
    });
}


- (int)itemIndexWithOffsetFromTop:(int)offsetFromTop {
    return (_topItemIndex + offsetFromTop) % (_visibleItemCount + 2);
}


- (void)moveToNextItemIndex {
    if (_topItemIndex >= _items.count - 1) {
        _topItemIndex = 0;
    } else {
        _topItemIndex++;
    }
}


- (id)nextData {
    NSArray *dataSourceArray = nil;
    if ([_moveDelegate respondsToSelector:@selector(dataSourceArrayForMoveView:)]) {
        dataSourceArray = [_moveDelegate dataSourceArrayForMoveView:self];
    }
    
    if (!dataSourceArray) {
        return nil;
    }
    
    if (_dataIndex < 0 || _dataIndex > dataSourceArray.count - 1) {
        _dataIndex = 0;
    }
    return dataSourceArray[_dataIndex++];
}


- (void)dealloc {
    if (self.scrollTimer) {
        [self.scrollTimer invalidate];
        self.scrollTimer = nil;
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
