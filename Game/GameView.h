//
//  GameView.h
//  Game
//
//  Created by Alexey Baranov on 27.12.2021.
//

#import <UIKit/UIKit.h>
#import "Ball.h"


static const NSInteger DEFAULT_AMOUNT_OF_BALLS = 5;
static const NSInteger WIDTH_OF_FIELD_IN_POINTS = 320;
static const NSInteger HEIGHT_OF_FIELD_IN_POINTS = 480;
static const NSInteger MARKER_SIZE = 10;
static const CGFloat   ANIMATION_SPEED = 0.1;
static const CGFloat   WIN_RATE = 0.75; // 75% covered screen to win

static const NSInteger WIDTH_OF_FIELD = WIDTH_OF_FIELD_IN_POINTS / MARKER_SIZE;
static const NSInteger HEIGHT_OF_FIELD = HEIGHT_OF_FIELD_IN_POINTS / MARKER_SIZE;
static const NSInteger FIELD_TYPE = 0;
static const NSInteger BOUNDARY_TYPE = 1;
static const NSInteger BALL_TYPE = 2;
static const NSInteger MARKER_TYPE = 3;
static const NSInteger MARKER_X_POS = 0;
static const NSInteger MARKER_Y_POS = 50;
static const NSInteger MARKER_X = MARKER_X_POS / MARKER_SIZE;
static const NSInteger MARKER_Y = MARKER_Y_POS / MARKER_SIZE;


NS_ASSUME_NONNULL_BEGIN

@interface GameView : UIView
{
    // array for ground
    NSInteger gameGround[WIDTH_OF_FIELD][HEIGHT_OF_FIELD];
    // array for marker path
    NSInteger markerGround[WIDTH_OF_FIELD][HEIGHT_OF_FIELD];
    // array for filling ground after cut
    NSInteger calcGround[WIDTH_OF_FIELD][HEIGHT_OF_FIELD];

    
    // array of balls
    NSMutableArray *balls;
    // Ground field image.
    UIImage *groundImage;

    // Image to visialisate ball
    UIImage *ballImage;
    // image for marker
    UIImage *markerImage;
    
    // indicate if marker moved
    BOOL isMarkerStay;
    // indicate if mareker left boundary and go into gorund
    BOOL isOnGround;
    // marker positions
    NSInteger xMarker, yMarker;
    // marker direction
    NSInteger dxMarker, dyMarker;

    // previous marker positions before start movement
    NSInteger xPrevMarker, yPrevMarker;

    // marker layer
    CALayer *markerLayer;
    // marker movement layer
    CALayer *markerMovementLayer;
    UIImage *markerMovementImage;
    
    NSInteger recurIndex;
    
    // amount of balls
    NSInteger amountOfBalls;
    
    // filled amount of ground
    CGFloat filledAmount;
}

// start movement of marker
-(void)markerStartMovement: (UIKeyCommand *) key;

// marker change direction
-(void)markerChangeDirection: (UIKeyCommand *) key;

// return YES if marker stay
-(BOOL)isMarkerStay;

// set to NO when marker move
-(void)setMarkerMove;

// start new game
-(void)resetGame;

@end

NS_ASSUME_NONNULL_END
