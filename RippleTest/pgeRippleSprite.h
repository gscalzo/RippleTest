//
//  pgeRippleSprite.h
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright 2011 Protec Electronics. All rights reserved.
//
//  http://www.youtube.com/user/BackfireE?feature=mhee#p/a/u/0/d5ijwDEfZSw
//  I made a rippleSprite, working more or less the same as a normal CCSprite.
//  I haven't added transformations, because at this point I don't need them, but
//  that shouldn't be to hard.
//  Otherwise you create it much like any other sprite.
//  rippleImage = [ pgeRippleSprite ripplespriteWithFile:@"image.png" ];
//  	[ self addChild:rippleImage ];
//  Then you add ripples to the image
//  	[ rippleImage addRipple:pos type:RIPPLE_TYPE_WATER strength:1.0f ];
//  and update the image each frame
//  	[ rippleImage update:dt ];
//  And that is it.
// --------------------------------------------------------------------------
// import headers

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// --------------------------------------------------------------------------
// defines

#define RIPPLE_DEFAULT_QUAD_COUNT_X             30
#define RIPPLE_DEFAULT_QUAD_COUNT_Y             20 

#define RIPPLE_BASE_GAIN                        0.1f        // an internal constant

#define RIPPLE_DEFAULT_RADIUS                   800         // radius in pixels
#define RIPPLE_DEFAULT_RIPPLE_CYCLE             0.2f        // timing on ripple ( 1/frequenzy )
#define RIPPLE_DEFAULT_LIFESPAN                 3.0f        // entire ripple lifespan

// --------------------------------------------------------------------------
// typedefs

typedef enum {
    RIPPLE_TYPE_RUBBER,                                     // a soft rubber sheet
    RIPPLE_TYPE_GEL,                                        // high viscosity fluid
    RIPPLE_TYPE_WATER,                                      // low viscosity fluid
} RIPPLE_TYPE;

typedef struct _rippleData {
    RIPPLE_TYPE             rippleType;                     // type of ripple ( se update: )
    CGPoint                 center;                         // ripple center ( but you just knew that, didn't you? )
    CGPoint                 centerCoordinate;               // ripple center in texture coordinates
    float                   radius;                         // radius at which ripple has faded 100%
    float                   strength;                       // ripple strength
    float                   runtime;                        // current run time
    float                   currentRadius;                  // current radius
    float                   rippleCycle;                    // ripple cycle timing
    float                   lifespan;                       // total life span
} rippleData;

// --------------------------------------------------------------------------
// interface

@interface pgeRippleSprite : CCNode {
    CCTexture2D*            m_texture;
    int                     m_quadCountX;                   // quad count in x and y direction
    int                     m_quadCountY;
    int                     m_VerticesPrStrip;              // number of vertices in a strip
    int                     m_bufferSize;                   // vertice buffer size
    CGPoint*                m_vertice;                      // vertices
    CGPoint*                m_textureCoordinate;            // texture coordinates ( original )
    CGPoint*                m_rippleCoordinate;             // texture coordinates ( ripple corrected )
    bool*                   m_edgeVertice;                  // vertice is a border vertice
    NSMutableArray*         m_rippleList;                   // list of running ripples
}

// --------------------------------------------------------------------------
// properties

// --------------------------------------------------------------------------
// methods

+( pgeRippleSprite* )ripplespriteWithFile:( NSString* )filename;
-( pgeRippleSprite* )initWithFile:( NSString* )filename;
-( void )tesselate;
-( void )addRipple:( CGPoint )pos type:( RIPPLE_TYPE )type strength:( float )strength;
-( void )update:( ccTime )dt;

// --------------------------------------------------------------------------

@end
