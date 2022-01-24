//
//  ViewController.m
//  Game
//
//  Created by Alexey Baranov on 27.12.2021.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSLog(@"viewDidLoad");
    gameView = [[GameView alloc] init];
    [gameView setFrame:self.view.bounds];
    [self.view addSubview:gameView];
    

}

- (void)viewDidAppear:(BOOL)animated {
    NSLog(@"viewDidAppear");
}


// activate keyboard for testing on mac
- (BOOL)canBecomeFirstResponder {
    return YES;
}

// make first responder
-(BOOL)becomeFirstResponder {
    NSLog(@"become first responder");
    return YES;
}


// define list of handlers for key clicks
- (NSArray<UIKeyCommand *>*)keyCommands {

    UIKeyCommand* upKeyCommand = [UIKeyCommand keyCommandWithInput:UIKeyInputUpArrow modifierFlags: nil action:@selector(pressed:)];
    UIKeyCommand* downKeyCommand = [UIKeyCommand keyCommandWithInput:UIKeyInputDownArrow modifierFlags: nil action:@selector(pressed:)];
    UIKeyCommand* leftKeyCommand = [UIKeyCommand keyCommandWithInput:UIKeyInputLeftArrow modifierFlags: nil action:@selector(pressed:)];
    UIKeyCommand* rightKeyCommand = [UIKeyCommand keyCommandWithInput:UIKeyInputRightArrow modifierFlags: nil action:@selector(pressed:)];
    UIKeyCommand* escKeyCommand = [UIKeyCommand keyCommandWithInput:UIKeyInputEscape modifierFlags: nil action:@selector(pressed:)];

//    upKeyCommand.wantsPriorityOverSystemBehavior = YES;
    return @[
             upKeyCommand, downKeyCommand, leftKeyCommand, rightKeyCommand, escKeyCommand
        ];
}

- (void)pressed: (UIKeyCommand *) key {
//    NSLog(@"Arrow clicked %s", key.input);

    if ([key.input isEqual:UIKeyInputEscape]) {
        [gameView resetGame];
    // if marker stay update flags and start movement
    } else if ([gameView isMarkerStay]) {
        [gameView markerStartMovement:key];

    // if marker moving just change direction
    } else {
        [gameView markerChangeDirection:key];
    }
}

@end
