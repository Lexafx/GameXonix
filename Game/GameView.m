//
//  GameView.m
//  Game
//
//  Created by Alexey Baranov on 27.12.2021.
//

#import "GameView.h"

@implementation GameView

// return YES if marker stay
-(BOOL)isMarkerStay {
    return isMarkerStay;
}

// set to NO when marker move
-(void)setMarkerMove {
    isMarkerStay = NO;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        NSLog(@"%f, %f, %f, %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
        // set frame to whole screen
        [self setFrame:rect];
        // init game ground array
        [self initGameGround];
        // prepare ground field layer
        [self prepareGroundImage];

        // prepare ball image
        [self prepareBallImage];

        amountOfBalls = DEFAULT_AMOUNT_OF_BALLS;
        // init balls
        [self initNumberOfBalls: amountOfBalls];

        // prepare marker movement layer
        markerMovementLayer = [CALayer layer];
        markerMovementLayer.anchorPoint = CGPointMake(0, 0);
        markerMovementLayer.frame = CGRectMake(0, 0, WIDTH_OF_FIELD_IN_POINTS, HEIGHT_OF_FIELD_IN_POINTS);
        [self.layer addSublayer:markerMovementLayer];

 
        // draw ground image
        self.layer.contents = (id) groundImage.CGImage;

        // prepare marker image
        [self prepareMarkerImage];
        // display marker image
        markerLayer = [CALayer layer];
        markerLayer.anchorPoint = CGPointMake(0, 0);
        markerLayer.frame = CGRectMake(MARKER_X_POS, MARKER_Y_POS, MARKER_SIZE, MARKER_SIZE);
        markerLayer.contents = (id)markerImage.CGImage;
        [self.layer addSublayer:markerLayer];

        // marker stay still and in base position
        isMarkerStay = YES;
        xMarker = MARKER_X;
        yMarker = MARKER_Y;
        dxMarker = dyMarker = 0;
        filledAmount = 0;
        
        // start balls movement
        [self moveBalls];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

// init game ground array
- (void)initGameGround {
    // nulify field
    for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
        for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
            gameGround[iX][iY] = FIELD_TYPE;
        }
    }
    
    // make a boundary
    // Horizontal first
    for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
        gameGround[iX][0] = BOUNDARY_TYPE;
        gameGround[iX][HEIGHT_OF_FIELD - 1] = BOUNDARY_TYPE;
    }

    // Vertical second
    for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
        gameGround[0][iY] = BOUNDARY_TYPE;
        gameGround[WIDTH_OF_FIELD - 1][iY] = BOUNDARY_TYPE;
    }
}

    // init balls on game ground
- (void) initBallsOnGameGround: (NSInteger) amountOfBalls {
    int iX, iY;
    
    for (int i = 0; i < amountOfBalls; i++) {
        iX = arc4random() % (WIDTH_OF_FIELD - 2);
        iY = arc4random() % (HEIGHT_OF_FIELD - 2);
        NSLog(@"%u, %u", iX, iY);
        gameGround[iX + 1][iY + 1] = BALL_TYPE;
    }
}

// creates balls for the game
- (void) initNumberOfBalls: (NSInteger) ballsQuantity {
    Ball *ball;
    balls = [[NSMutableArray alloc] initWithCapacity:ballsQuantity];

    for (int i = 0; i < ballsQuantity; i++) {
        ball = [[Ball alloc] initWithRandomPositionForWidth: WIDTH_OF_FIELD andForHeight:HEIGHT_OF_FIELD];
        // prepare CALayer for ball
        CALayer *ballLayer = [CALayer layer];
        ballLayer.anchorPoint = CGPointMake(0, 0);
        ballLayer.frame = CGRectMake([ball x] * MARKER_SIZE, [ball y] * MARKER_SIZE, MARKER_SIZE, MARKER_SIZE);
        ballLayer.contents = (id)[self prepareBallImageWithNumber:i];
        [self.layer addSublayer:ballLayer];
        [ball setLayer:ballLayer];

        [balls addObject:ball];
    }
}

// move balls one step and repeat
- (void)moveBalls {
    for (Ball *ball in balls) {
        // check if move by x axis will hit ground boundary
        // projected postion
        NSInteger projX, projY;
        // current position
        NSInteger x, y;
        
        projX = [ball projectiveX];
        y = [ball y];
        // checks on boundary by X
        if (gameGround[projX][y] == BOUNDARY_TYPE) {
            [ball setOppositeDirectionByX];
        
            // checks if ball hit marker trace
        } else if (isOnGround && markerGround[projX][y] == MARKER_TYPE) {
            NSLog(@"Ball hit marker line");
            // return to previous state before marker start
            [self resetMarkerGroundToPrev];

            // checks if ball hit another ball
        } else if ([self isHitAnotherBallByX:ball]) {
            [ball setOppositeDirectionByX];
        }
        [ball moveX];
        // move by y
        projY = [ball projectiveY];
        x = [ball x];
        if (gameGround[x][projY] == BOUNDARY_TYPE) {
            [ball setOppositeDirectionByY];
            // checks if ball hit another ball
        } else if ([self isHitAnotherBallByY:ball]) {
            [ball setOppositeDirectionByY];
        }
        [ball moveY];
//        NSLog(@"moveBalls: %lu, %lu: %lu, %lu", [ball x], [ball y], [ball x] * MARKER_SIZE, [ball y] * MARKER_SIZE);

        ball.layer.position = CGPointMake([ball x] * MARKER_SIZE, [ball y] * MARKER_SIZE);

    }
    
 //   [self setNeedsDisplay];
    
    // move marker if needed
    if (!isMarkerStay) {
        [self moveMarker];
    }
    
    [self performSelector:@selector(moveBalls)
        withObject:nil
        afterDelay:ANIMATION_SPEED];

}

// prepare ground image
- (void)prepareGroundImage {

    // ***** Creating ground image and drawing in it

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(WIDTH_OF_FIELD_IN_POINTS, HEIGHT_OF_FIELD_IN_POINTS), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);

    CGContextSetRGBStrokeColor(ctx, 1, 1 , 0, 1);
    CGContextSetLineWidth(ctx, MARKER_SIZE * 2);
//    CGContextSetLineWidth(ctx, 1);

    CGContextStrokeRect(ctx, CGRectMake(0, 0, WIDTH_OF_FIELD_IN_POINTS, HEIGHT_OF_FIELD_IN_POINTS));

    CGContextSetRGBFillColor(ctx, 1, 0 , 1, 1);
    CGContextFillRect(ctx, CGRectMake(MARKER_SIZE, MARKER_SIZE, WIDTH_OF_FIELD_IN_POINTS - MARKER_SIZE * 2, HEIGHT_OF_FIELD_IN_POINTS - MARKER_SIZE * 2));

    CGContextRestoreGState(ctx);

    groundImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup context
    UIGraphicsEndImageContext();
}

// prepare regular image
- (void)prepareBallImage {

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(MARKER_SIZE, MARKER_SIZE), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);

    CGContextSetRGBFillColor (ctx, 1, 1 , 1, 1);
    CGContextFillEllipseInRect(ctx, CGRectMake(0, 0, MARKER_SIZE, MARKER_SIZE));
        
    CGContextRestoreGState(ctx);

    ballImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup
    UIGraphicsEndImageContext();
}

// prepare ball image with number for testing purposes
- (CGImageRef)prepareBallImageWithNumber: (NSInteger) number {
    NSString *str = [NSString stringWithFormat:@"%lu", number];
    
    UIGraphicsBeginImageContextWithOptions(ballImage.size, NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);

    [ballImage drawAtPoint:CGPointZero];
    CGContextSetRGBStrokeColor (ctx, 1, 1, 1, 1);
 
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *dict = @{NSFontAttributeName : [UIFont systemFontOfSize:MARKER_SIZE],
                           NSParagraphStyleAttributeName : paragraphStyle,
                           NSForegroundColorAttributeName : [UIColor blueColor]
    };
    
    // allign text in rectangle
    CGSize fontSize = [str sizeWithAttributes:dict];
    CGFloat x, y;
    x = (ballImage.size.width - fontSize.width) / 2;
    y = (ballImage.size.height - fontSize.height) / 2;
    
    [str drawInRect:CGRectMake(x, y, fontSize.width, fontSize.height) withAttributes:dict];

//    CGContextSetFont(ctx, [UIFont systemFontOfSize:8]);
        
    CGContextRestoreGState(ctx);

    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup
    UIGraphicsEndImageContext();
    
    return img.CGImage;
}

// draws balls image on the screen
-(void)drawBalls {
    // display balls on the screen
    for (Ball *ball in balls) {
        [ballImage drawAtPoint:CGPointMake([ball x] * MARKER_SIZE, [ball y] * MARKER_SIZE)];
    }
}

// checks if ball hits any other balls
-(BOOL)isHitAnotherBallByX: (Ball *)paramBall {
    NSInteger projX = [paramBall projectiveX];
    NSInteger y = [paramBall y];
    
    for (Ball *ball in balls) {
        // do check if ball not equal paramBall
        if (![ball isEqual:paramBall]) {
            if ([ball x] == projX && [ball y] == y) {
                return YES;
            }
        }
    }
    
    return NO;
}

// checks if ball hits any other balls
-(BOOL)isHitAnotherBallByY: (Ball *)paramBall {
    NSInteger projY = [paramBall projectiveY];
    NSInteger x = [paramBall x];
    
    for (Ball *ball in balls) {
        // do check if ball not equal paramBall
        if (![ball isEqual:paramBall]) {
            if ([ball x] == x && [ball y] == projY) {
                return YES;
            }
        }
    }
    
    return NO;
}

// prepare marker image
- (void)prepareMarkerImage {
    // prepare
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(MARKER_SIZE, MARKER_SIZE), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);

//    CGContextSetRGBFillColor (ctx, 183. / 255, 143. / 255, 143. / 255, 1);
    CGContextSetRGBFillColor (ctx, 165. / 255, 42. / 255, 42. / 255, 1);
    CGContextFillRect(ctx, CGRectMake(0, 0, MARKER_SIZE, MARKER_SIZE));
        
    CGContextRestoreGState(ctx);

    markerImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup
    UIGraphicsEndImageContext();
}

// move marker one step and update marker movement iamge
- (void)moveMarker {
    // check if move by x axis will hit ground boundary
    // projected postion
    NSInteger projX, projY;
    NSInteger prevX, prevY;

    projX = xMarker + dxMarker;
    projY = yMarker + dyMarker;

    // save prev position if we left boundary
    prevX = xMarker;
    prevY = yMarker;
    
    // if equal marker line is hitted
    if (markerGround[projX][projY] == MARKER_TYPE) {
        NSLog(@"Marker line hitted");
        // clear market ground and return marker to prev position
        [self resetMarkerGroundToPrev];
        return;
    }

    // move marker
    markerLayer.position = CGPointMake(projX * MARKER_SIZE, projY * MARKER_SIZE);
    xMarker = projX;
    yMarker = projY;


    
    if (isOnGround) {
        
        // if left ground set proper flag and fill the ground without balls
        if (gameGround[projX][projY] == BOUNDARY_TYPE) {
            isOnGround = NO;
            // nulify increment for marker
            dxMarker = dyMarker = 0;
            // set stay markey to yes
            isMarkerStay = YES;
            // fill the ground after cut
//            [self NSLogMarkerGround];
            [self fillGroundAfterCut];
        } else {
            // fill marker ground if marker is only on the ground
            markerGround[projX][projY] = MARKER_TYPE;

            // update marker trace on marker layer
            [self updateMarkerMovementImage];

        }
    } else {
        // if just come to ground set proper flag
        if (gameGround[projX][projY] == FIELD_TYPE) {
            isOnGround = YES;
            // save previous position
            xPrevMarker = prevX;
            yPrevMarker = prevY;
            
            // fill marker ground if marker is only on the ground
            markerGround[projX][projY] = MARKER_TYPE;


            // draw marker trace on marker layer
            [self updateMarkerMovementImage];
            
        // when marker does not left boundary
        } else if (dxMarker == -1 && projX == 0) {
            isMarkerStay = YES;
        } else if (dxMarker == 1 && projX * MARKER_SIZE == WIDTH_OF_FIELD_IN_POINTS - MARKER_SIZE) {
            isMarkerStay = YES;
        } else if (dyMarker == -1 && projY == 0) {
            isMarkerStay = YES;
        } else if (dyMarker == 1 && projY * MARKER_SIZE == HEIGHT_OF_FIELD_IN_POINTS - MARKER_SIZE) {
            isMarkerStay = YES;
        }
    }
 
}

// marker starts movement
// prepare marker movement layer
-(void)markerStartMovement: (UIKeyCommand *) key {
    
    // set direction and check if marker can move this direction
    if ([key.input isEqual:UIKeyInputUpArrow] && yMarker > 0){
        dxMarker = 0;
        dyMarker = -1;
        isMarkerStay = NO;
    } else if ([key.input isEqual:UIKeyInputDownArrow] && yMarker < HEIGHT_OF_FIELD - 1){
        dxMarker = 0;
        dyMarker = 1;
        isMarkerStay = NO;
    } else if ([key.input isEqual:UIKeyInputLeftArrow] && xMarker > 0){
        dxMarker = -1;
        dyMarker = 0;
        isMarkerStay = NO;
    } else if ([key.input isEqual:UIKeyInputRightArrow] && xMarker < WIDTH_OF_FIELD - 1){
        dxMarker = 1;
        dyMarker = 0;
        isMarkerStay = NO;
    }
    
    // if move started prepare and display marker movement layer
    if (!isMarkerStay) {
        // if marker just started set isOnGround to NO
        isOnGround = NO;
        
        [self prepareMarkerMovementImage];
        // prepare market ground array
        [self initMarkerGround];
    } else {
    }
}

// marker change direction
-(void)markerChangeDirection: (UIKeyCommand *) key {
    
    // set direction and check if marker can move this direction
    if ([key.input isEqual:UIKeyInputUpArrow] && yMarker > 0){
        dxMarker = 0;
        dyMarker = -1;
    } else if ([key.input isEqual:UIKeyInputDownArrow] && yMarker < HEIGHT_OF_FIELD - 1){
        dxMarker = 0;
        dyMarker = 1;
    } else if ([key.input isEqual:UIKeyInputLeftArrow] && xMarker > 0){
        dxMarker = -1;
        dyMarker = 0;
    } else if ([key.input isEqual:UIKeyInputRightArrow] && xMarker < WIDTH_OF_FIELD - 1){
        dxMarker = 1;
        dyMarker = 0;
    }
 }

// prepare and display marker movement image
- (void)prepareMarkerMovementImage {
    // prepare image size of all field
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(WIDTH_OF_FIELD_IN_POINTS, HEIGHT_OF_FIELD_IN_POINTS), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();


    markerMovementImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup
    UIGraphicsEndImageContext();
    
    // display
    markerMovementLayer.contents = (id)markerMovementImage.CGImage;
}

// update marker movement image
- (void)updateMarkerMovementImage {
    // prepare
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(WIDTH_OF_FIELD_IN_POINTS, HEIGHT_OF_FIELD_IN_POINTS), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    CGContextSaveGState(ctx);

    // draw previous movement image
    [markerMovementImage drawAtPoint:CGPointZero];
    CGContextSetRGBFillColor (ctx, 183. / 255, 143. / 255, 143. / 255, 1);
//    CGContextSetRGBFillColor (ctx, 165. / 255, 42. / 255, 42. / 255, 1);
    CGContextFillRect(ctx, CGRectMake(xMarker * MARKER_SIZE, yMarker * MARKER_SIZE, MARKER_SIZE, MARKER_SIZE));
        
    CGContextRestoreGState(ctx);

    markerMovementImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup
    UIGraphicsEndImageContext();
    
    // update image into layer
    markerMovementLayer.contents = (id)markerMovementImage.CGImage;
}

// init game ground array
- (void)initMarkerGround {
    // nulify field
    for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
        for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
            markerGround[iX][iY] = FIELD_TYPE;
        }
    }
}

// reset marker ground to previous state before start movement
-(void)resetMarkerGroundToPrev {
    isMarkerStay = YES;
    dxMarker = dxMarker = 0;
    
    // clear marker ground
    [self initMarkerGround];
    // clear marker ground layer
    [self prepareMarkerMovementImage];

    // move marker position to previous prosition
    xMarker = xPrevMarker;
    yMarker = yPrevMarker;
    markerLayer.position = CGPointMake(xMarker * MARKER_SIZE, yMarker * MARKER_SIZE);
}

// fill the ground after cut
-(void)fillGroundAfterCut {
    // copy gameGround to calcGround
    [self initCalcGround];
    
    // for each ball and fill the calcGround
    for (Ball *ball in balls) {
        [self fillCalcGroundForBall:ball];
    }
    
    // update game ground and display changes
    BOOL isWon = [self updateGameGroundAfterCut];
    // clear marker movement image and display it
    [self prepareMarkerMovementImage];
    
    // if won increae amount of ball and restart the game
    if (isWon) {
        // Won animation
        [self prepareAndShowWonImage];
        amountOfBalls++;
        // start new game
        [self resetGame];
    }
}

// copy gameGround to calcGround
-(void)initCalcGround {
    for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
        for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
            calcGround[iX][iY] = gameGround[iX][iY];
            // copy marker trace if exist
            // can change on markerGorund later if fills it properly
            if (markerGround[iX][iY] == MARKER_TYPE) {
                calcGround[iX][iY] = markerGround[iX][iY];
            }
        }
    }
}

// for each ball fill calc ground
-(void)fillCalcGroundForBall:(Ball *) ball {
    // position of index
    NSInteger x, y;
    // start from ball position
    x = [ball x];
    y = [ball y];
    
    // set calc ground for ball to ball type
//    calcGround[x][y] = BALL_TYPE;

//    [self NSLogCalcGround];

    recurIndex = 0;
    // first move up
    [self fillCalcGroundForX:x AndY:y];
    
    // print calc ground to log
//    [self NSLogCalcGround];
}

// recursively fill call ground for whole field
-(void) fillCalcGroundForX: (NSInteger) x AndY: (NSInteger) y {
//    NSLog(@"RecurIndex: %lu for %lu, %lu", recurIndex, x, y);
    
    recurIndex++;
    // first move up
    if (calcGround[x][y] == FIELD_TYPE) {
        calcGround[x][y] = BALL_TYPE;
        [self fillCalcGroundForX:x AndY:y - 1];
        [self fillCalcGroundForX:x AndY:y + 1];
        [self fillCalcGroundForX:x - 1 AndY:y];
        [self fillCalcGroundForX:x + 1 AndY:y];
    }
}

// fill game ground based on calc ground
// and display changes
-(BOOL)updateGameGroundAfterCut {
    // ***** Update ground image and drawing in it

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(WIDTH_OF_FIELD_IN_POINTS, HEIGHT_OF_FIELD_IN_POINTS), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // draw current ground image in to context
    [groundImage drawAtPoint:CGPointZero];

    CGContextSetRGBFillColor(ctx, 1, 1 , 0, 1);

    // Checks if win cretaria are met
    CGFloat coveredIndex = 0;
    for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
    
        for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
            if (calcGround[iX][iY] == FIELD_TYPE || calcGround[iX][iY] == MARKER_TYPE) {
                gameGround[iX][iY] = BOUNDARY_TYPE;
                CGContextFillRect(ctx, CGRectMake(iX * MARKER_SIZE, iY * MARKER_SIZE, MARKER_SIZE, MARKER_SIZE));
                coveredIndex++;
            }
        }
    }
    
    groundImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup context
    UIGraphicsEndImageContext();
    
    // update layer with image
    self.layer.contents = (id)groundImage.CGImage;
    
    // if coveredIndex more than win rate return YES, otherwise NO
    filledAmount += coveredIndex / ((WIDTH_OF_FIELD - 2) * (HEIGHT_OF_FIELD - 2) + 2);
    NSLog(@"Filled area surface: %3.1f%%", filledAmount * 100);
    if (filledAmount > WIN_RATE) {
        // won!
        NSLog(@"Won!!!");
        return YES;
    }
    return NO;
}

// NSLog calcGround
-(void)NSLogCalcGround {
    NSLog(@"calcGround");
    for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
        NSMutableString *str = [[NSMutableString alloc] initWithCapacity:100];
    
        for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
            [str appendFormat:@"%ld", (long)calcGround[iX][iY]];
        }
        NSLog(@"%@", str);
    }
}

// NSLog gameGround
-(void)NSLogGameGround {
    NSLog(@"gameGround");
    for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
        NSMutableString *str = [[NSMutableString alloc] initWithCapacity:100];
    
        for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
            [str appendFormat:@"%ld", (long)gameGround[iX][iY]];
        }
        NSLog(@"%@", str);
    }
}

// NSLog markerGround
-(void)NSLogMarkerGround {
    NSLog(@"markerGround");
    for (int iY = 0; iY < HEIGHT_OF_FIELD; iY++) {
        NSMutableString *str = [[NSMutableString alloc] initWithCapacity:100];
    
        for (int iX = 0; iX < WIDTH_OF_FIELD; iX++) {
            [str appendFormat:@"%ld", (long)markerGround[iX][iY]];
        }
        NSLog(@"%@", str);
    }
}

// start new game
-(void)resetGame {
    // init game ground array
    [self initGameGround];
    // prepare ground field layer
    [self prepareGroundImage];

    // remove all balls from view
    [self removeBalls];
    // init balls
    [self initNumberOfBalls: amountOfBalls];

    // display marker image
    markerLayer.frame = CGRectMake(MARKER_X_POS, MARKER_Y_POS, MARKER_SIZE, MARKER_SIZE);

    // draw ground image
    self.layer.contents = (id) groundImage.CGImage;

    // marker stay still and in base position
    isMarkerStay = YES;
    xMarker = MARKER_X;
    yMarker = MARKER_Y;
    dxMarker = dyMarker = 0;
    filledAmount = 0;

    // start balls movement after delay
    // to avoid double animation
//    [self performSelector:@selector(moveBalls) withObject:nil afterDelay:ANIMATION_SPEED +0.01];

}

// removes balls
- (void) removeBalls {
    for (Ball *ball in balls) {
        // remove laeyr from view
        [[ball layer] removeFromSuperlayer];
    }
    // remove all balls;
    [balls removeAllObjects];
}

// prepare won image
- (void)prepareAndShowWonImage {

    // ***** Creating won image and drawing in it

    UIGraphicsBeginImageContextWithOptions(CGSizeMake(WIDTH_OF_FIELD_IN_POINTS / 2, HEIGHT_OF_FIELD_IN_POINTS /2), NO, 0.0);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    
    CGContextSaveGState(ctx);

    CGContextSetRGBFillColor (ctx, 1, 1, 0, 1);
    CGRect rect = CGRectMake(0, 0, WIDTH_OF_FIELD_IN_POINTS / 2, HEIGHT_OF_FIELD_IN_POINTS /2);
    CGContextFillRect(ctx, rect);
 
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.alignment = NSTextAlignmentCenter;

    NSDictionary *dict = @{NSFontAttributeName : [UIFont boldSystemFontOfSize:20],
                           NSParagraphStyleAttributeName : paragraphStyle,
                           NSForegroundColorAttributeName : [UIColor blueColor]
    };

    NSString *str = [NSString stringWithFormat:@"You Won!!!"];

    // allign text in rectangle
    CGSize fontSize = [str sizeWithAttributes:dict];
    CGFloat x, y;
    x = (WIDTH_OF_FIELD_IN_POINTS / 2 - fontSize.width) / 2;
    y = (HEIGHT_OF_FIELD_IN_POINTS /2 - fontSize.height) / 2;
    
    [str drawInRect:CGRectMake(x, y, fontSize.width, fontSize.height) withAttributes:dict];

    CGContextRestoreGState(ctx);

    UIImage *wonImage = UIGraphicsGetImageFromCurrentImageContext();

    // Cleanup context
    UIGraphicsEndImageContext();
    
    // add won layer
    CALayer *wonLayer = [CALayer layer];
    wonLayer.contents = (id)wonImage.CGImage;
    wonLayer.anchorPoint = CGPointMake(0, 0);
    wonLayer.cornerRadius = 20;
    wonLayer.masksToBounds = YES;
    wonLayer.frame = CGRectMake(rect.size.width / 2, rect.size.height / 2, WIDTH_OF_FIELD_IN_POINTS / 2, HEIGHT_OF_FIELD_IN_POINTS / 2);

    [self.layer addSublayer:wonLayer];

    [UIView transitionWithView:self duration:1.5
                           options:UIViewAnimationOptionTransitionFlipFromBottom
                        animations:^ {
//                            [self.layer addSublayer:wonLayer];
                        }
                        completion:^(BOOL finished){
                            if (finished) {
                                // Successful
                                [wonLayer removeFromSuperlayer];
                            }
                            NSLog(@"Animations completed.");
                            // do something…
     }];
}

@end
