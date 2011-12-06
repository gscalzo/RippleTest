//
//  HelloWorldLayer.h
//  RippleTest
//
//  Created by Dave Hersey, Paracoders, Inc. on 12/4/11.
//  Ripples provided by Birkemose.
//


#import "cocos2d.h"
#import "pgeRippleSprite.h"

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer
{
    pgeRippleSprite     *rippleImage;
    CCLabelTTF          *rippleTypeLabel;
    RIPPLE_TYPE         rippleType;
    CGPoint             lastRippleTouch;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
