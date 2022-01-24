//
//  Ball.m
//  Game
//
//  Created by Alexey Baranov on 27.12.2021.
//

#import "Ball.h"

@implementation Ball

@synthesize x;
@synthesize y;
@synthesize dx;
@synthesize dy;
@synthesize layer;

- (instancetype)initWithPositionX:(NSInteger) xPos andPositionY:(NSInteger) yPos {
    self = [super init];
    if (self) {
        x = xPos;
        y = yPos;
    }
    return self;
}

- (instancetype)initWithRandomPositionForWidth:(NSInteger)width andForHeight:(NSInteger)height {
    self = [super init];
    if (self) {
        // width decreases on 2 points: left and right. To be on the field and not on the boundary of field
        x = arc4random() % (width - 2) + 1;
        y = arc4random() % (height - 2) + 1;
        NSLog(@"%ld, %ld", x, y);
        
        // init movement gradient by x and y axis
        dx = 1;
        if (arc4random() % (width) < width / 2) {
            dx = -1;
        }
        dy = 1;
        if (arc4random() % (width) < width / 2) {
            dy = -1;
        }

    }
    return self;
}

- (void)moveBall {
    
}

- (NSInteger)projectiveX {
    return x + dx;
}

- (NSInteger)projectiveY {
    return y + dy;
}

// move ball by x
- (void)moveX {
    x += dx;
}

// set opposite direction by x
- (void)setOppositeDirectionByX {
    dx = -dx;
}

// move ball by y
- (void)moveY {
    y += dy;
}

// set opposite direction by y
- (void)setOppositeDirectionByY {
    dy = -dy;
}

@end
