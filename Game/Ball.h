//
//  Ball.h
//  Game
//
//  Created by Alexey Baranov on 27.12.2021.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface Ball : NSObject
{
}

// x,y position of the ball
@property NSInteger x;
@property NSInteger y;

// movement gradient for x, y axis
@property NSInteger dx;
@property NSInteger dy;

// sub layer for ball visualisation
@property CALayer *layer;

- (instancetype)initWithPositionX: (NSInteger) xPos andPositionY: (NSInteger) yPos;
- (instancetype)initWithRandomPositionForWidth: (NSInteger) width andForHeight: (NSInteger) height;
- (void)moveBall;

// move ball by x
- (void)moveX;
// set opposite direction by x
- (void)setOppositeDirectionByX;

// move ball by y
- (void)moveY;
// set opposite direction by y
- (void)setOppositeDirectionByY;

// return projetive x position without physically moving x position
- (NSInteger)projectiveX;

// return projetive y position without physically moving y position
- (NSInteger)projectiveY;

@end

NS_ASSUME_NONNULL_END
