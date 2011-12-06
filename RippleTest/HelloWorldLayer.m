//
//  HelloWorldLayer.m
//  RippleTest
//
//  Created by Dave Hersey, Paracoders, Inc. on 12/4/11.
//  Ripples provided by Birkemose.
//

#import "HelloWorldLayer.h"
#import "pgeRippleSprite.h"

#define MINIMUM_DRAG_DISTANCE  50 /* Dragging only creates new waves every 50 pixels. */

@implementation HelloWorldLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}


- (id) init
{
	if ((self = [super init]) != nil)
    {
        CCMenuItemFont      *menuItem;
        CGSize              winSize = [[CCDirector sharedDirector] winSize];

        // Keep the ripple type in an ivar so we can change it.
        rippleType = RIPPLE_TYPE_WATER;

		// Create a full screen ripple sprite.
        // NOTE: This image is for demo purposes only.
        // Do NOT ship anything using it because you don't have
        // the rights to do that any more than I do.
        rippleImage = [pgeRippleSprite ripplespriteWithFile:
                       ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)? @"Undersea-iPad.png":
                         @"Undersea.png")];

        rippleImage.position = ccp(0,0);
        [self addChild: rippleImage z: 0];

        // Add a menu item so we can change the ripple type.
        menuItem = [CCMenuItemFont itemFromString: @"Change Ripple Type"
                                           target: self
                                         selector: @selector(changeRippleType:)];
        
        [menuItem setFontSize: 36.0f];
        menuItem.position = ccp(0, -winSize.height*2/5);
        [self addChild: [CCMenu menuWithItems: menuItem, nil] z: 10];

        // Add a label so we can show the ripple type.
        rippleTypeLabel = [CCLabelTTF labelWithString: @"RIPPLE_TYPE_WATER"
                                             fontName: @"Helvetica"
                                             fontSize: 18.0f];

        rippleTypeLabel.color = ccBLACK;
        rippleTypeLabel.position = ccp(winSize.width/2, winSize.height -15.0f);
        [self addChild: rippleTypeLabel z: 5];
    }

	return self;
}


- (void) dealloc
{
	[super dealloc];
}


#pragma mark

- (void) onEnter
{
    // Scene coming up. Enable our handlers.
    [super onEnter];
    [self scheduleUpdate];
    self.isTouchEnabled = YES;
    [[CCTouchDispatcher sharedDispatcher] addTargetedDelegate: self priority: 0 swallowsTouches: YES];
}


- (void) onExit
{
    // Scene going down. Disable our handlers.
    [super onExit];   
    [self unscheduleUpdate];
    self.isTouchEnabled = NO;
	[[CCTouchDispatcher sharedDispatcher] removeDelegate: self];
}


- (void) update: (ccTime) dt
{
    // Ripple ripple ripple.
    [rippleImage update: dt];
}


#pragma mark

- (BOOL) ccTouchBegan: (UITouch *) touch withEvent: (UIEvent *) event
{
    // Splash down.
    CGPoint location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    [rippleImage addRipple: location type: rippleType strength: 1.0f];
    lastRippleTouch = location;

    return YES;
}


- (void) ccTouchMoved: (UITouch *) touch withEvent: (UIEvent *) event
{
    double      touchDistance;
    CGPoint     location;
    CGFloat     dx, dy;
    
    location = [touch locationInView: [touch view]];
    location = [[CCDirector sharedDirector] convertToGL: location];
    
    // If we aren't our minimal distance from the last splash, do nothing
    // so we don't end up processing too many ripples. Spreading them out
    // also gives our dragged ripples the appearance of peaks and troughs.
    dx = location.x -lastRippleTouch.x;
    dy = location.y -lastRippleTouch.y;
    touchDistance = sqrt((dx*dx)+(dy*dy));
    
    if (touchDistance >= MINIMUM_DRAG_DISTANCE)
    {
        [rippleImage addRipple: location type: rippleType strength: 0.5f];
        lastRippleTouch = location;
    }
}

#pragma mark

- (void) changeRippleType: (id) sender
{
    // Menu item tapped. Change the ripple type.
    rippleType = (++rippleType % 3);
    
    switch (rippleType)
    {
        case RIPPLE_TYPE_RUBBER:
            rippleTypeLabel.string = @"RIPPLE_TYPE_RUBBER";
            break;
            
        case RIPPLE_TYPE_GEL:
            rippleTypeLabel.string = @"RIPPLE_TYPE_GEL";
            break;
            
        case RIPPLE_TYPE_WATER:
            rippleTypeLabel.string = @"RIPPLE_TYPE_WATER";
            break;
            
        default:
            break;
    }
}

@end
