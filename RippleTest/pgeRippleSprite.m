//
//  pgeRippleSprite.m
//  rippleDemo
//
//  Created by Lars Birkemose on 02/12/11.
//  Copyright 2011 Protec Electronics. All rights reserved.
//
// --------------------------------------------------------------------------
// import headers

#import "pgeRippleSprite.h"

// --------------------------------------------------------------------------
// implementation

@implementation pgeRippleSprite

// --------------------------------------------------------------------------
// properties

// --------------------------------------------------------------------------
// methods
// --------------------------------------------------------------------------

+( pgeRippleSprite* )ripplespriteWithFile:( NSString* )filename {
	return [ [ [ self alloc ] initWithFile:filename ] autorelease ];
}

// --------------------------------------------------------------------------

-( pgeRippleSprite* )initWithFile:( NSString* )filename {
    self = [ super init ];
    // load texture
    m_texture = [ [ CCTextureCache sharedTextureCache ] addImage: filename ];
    // reset internal data
    m_vertice = nil;
    m_textureCoordinate = nil;
    // builds the vertice and texture-coordinates arrays
    m_quadCountX = RIPPLE_DEFAULT_QUAD_COUNT_X;
    m_quadCountY = RIPPLE_DEFAULT_QUAD_COUNT_Y;
    [ self tesselate ];

    // create ripple list
    m_rippleList = [ [ [ NSMutableArray alloc ] init ] retain ];
    // done
    return( self );
}

// --------------------------------------------------------------------------

-( void )draw {
    // skip is not visible
    if ( self.visible == NO ) return;

    // add transformations
    glPushMatrix( );

    // well, I dont really need transformations on my ripples, so I will leave this part to you
    // but I added push and pop - just to be nice

    // set states
    glDisableClientState( GL_COLOR_ARRAY );

    // and plx, dont just draw anything
    glBindTexture( GL_TEXTURE_2D, [ m_texture name ] ); 

    // set texture coordinates
    // if no ripples running, use original coordinates ( Yay, dig that kewl old school C syntax )
    glTexCoordPointer( 2, GL_FLOAT, 0, ( m_rippleList.count == 0 ) ? m_textureCoordinate : m_rippleCoordinate );

    // set vertice pointer
    glVertexPointer( 2, GL_FLOAT, 0, m_vertice );

    // draw as many triangle fans, as quads in y direction
    // ( I guess traditional mongolians, would have made it vertical fans, but here I am, sitting in western Europa )
    for ( int strip = 0; strip < m_quadCountY; strip ++ ) {
        glDrawArrays( GL_TRIANGLE_STRIP, strip * m_VerticesPrStrip, m_VerticesPrStrip );
    }

    // reset any state altered ( Riq wants us to )
    glEnableClientState( GL_COLOR_ARRAY );

    // restore
    glPopMatrix( );
}

// --------------------------------------------------------------------------

-( void )dealloc {
    rippleData* runningRipple;

    // clean up buffers
    free( m_vertice );
    free( m_textureCoordinate );
    free( m_rippleCoordinate );
    free( m_edgeVertice );

    // clean up running ripples
    for ( int count = 0; count < m_rippleList.count; count ++ ) {

        // get a pointer and free manually, as data was allocated manually
        // a void pointer would do, but this adds readability at no expense
        runningRipple = ( rippleData* )[ [ m_rippleList objectAtIndex:count ] pointerValue ];
        free( runningRipple );

    }

    // delete list
    [ m_rippleList release ];

    // done
    [ super dealloc ];
}

// --------------------------------------------------------------------------
// tesselation is expensive

-( void )tesselate {
    int vertexPos = 0;
    CGPoint normalized;

    // clear buffers ( yeah, clearing nil buffers first time around )
    free( m_vertice );
    free( m_textureCoordinate );
    free( m_rippleCoordinate );
    free( m_edgeVertice );

    // calculate vertices pr strip
    m_VerticesPrStrip = 2 * ( m_quadCountX + 1 );

    // calculate buffer size
    m_bufferSize = m_VerticesPrStrip * m_quadCountY;

    // allocate buffers
    m_vertice = malloc( m_bufferSize * sizeof( CGPoint ) );
    m_textureCoordinate = malloc( m_bufferSize * sizeof( CGPoint ) );
    m_rippleCoordinate = malloc( m_bufferSize * sizeof( CGPoint ) );
    m_edgeVertice = malloc( m_bufferSize * sizeof( bool ) );

    // reset vertice pointer
    vertexPos = 0;

    // create all vertices and default texture coordinates
    // scan though y quads, and create an x-oriented triangle strip for each
    for ( int y = 0; y < m_quadCountY; y ++ ) {

        // x counts to quadcount + 1, because number of vertices is number of quads + 1
        for ( int x = 0; x < ( m_quadCountX + 1 ); x ++ ) {

            // for each x vertex, an upper and lower y position is calculated, to create the triangle strip
            // upper + lower + upper + lower
            for ( int yy = 0; yy < 2; yy ++ ) {

                // first simply calculate a normalized position into rectangle
                normalized.x = ( float )x / ( float )m_quadCountX;
                normalized.y = ( float )( y + yy ) / ( float )m_quadCountY;

                // calculate vertex by multiplying rectangle ( texture ) size
                m_vertice[ vertexPos ] = ccp( normalized.x * [m_texture contentSize].width, normalized.y * [m_texture contentSize].height );

                // adjust texture coordinates according to texture size
                // as a texture is always in the power of 2, maxS and maxT are the fragment of the size actually used
                // invert y on texture coordinates
                m_textureCoordinate[ vertexPos ] = ccp( normalized.x * m_texture.maxS, m_texture.maxT - ( normalized.y * m_texture.maxT ) );

                // check if vertice is an edge vertice, because edge vertices are never modified to keep outline consistent
                m_edgeVertice[ vertexPos ] = (
                                              ( x == 0 ) ||
                                              ( x == m_quadCountX ) ||
                                              ( ( y == 0 ) && ( yy == 0 ) ) ||
                                              ( ( y == ( m_quadCountY - 1 ) ) && ( yy > 0 ) ) );

                // next buffer pos
                vertexPos ++;

            }
        }
    }
}

// --------------------------------------------------------------------------
// adds a ripple to list of running ripples
// higher strength result in more distinct ripples

-( void )addRipple:( CGPoint )pos type:( RIPPLE_TYPE )type strength:( float )strength {
    rippleData* newRipple;

    // allocate new ripple
    newRipple = malloc( sizeof( rippleData ) );

    // initialize ripple
    newRipple->rippleType = type;
    newRipple->center = pos;
    newRipple->centerCoordinate = ccp( pos.x / [m_texture contentSize].width * m_texture.maxS, m_texture.maxT - ( pos.y / [m_texture contentSize].height * m_texture.maxT ) );
    newRipple->radius = RIPPLE_DEFAULT_RADIUS;
    newRipple->strength = strength;
    newRipple->runtime = 0;
    newRipple->currentRadius = 0;
    newRipple->rippleCycle = RIPPLE_DEFAULT_RIPPLE_CYCLE;
    newRipple->lifespan = RIPPLE_DEFAULT_LIFESPAN;

    // add ripple to running list
	[ m_rippleList addObject:[ NSValue valueWithPointer:newRipple ] ];

}

// --------------------------------------------------------------------------
// update any running ripples
// it is parents responsibility to call the method with appropriate intervals

-( void )update:( ccTime )dt {
    rippleData* ripple;
    CGPoint pos;
    float distance, correction;

    // test if any ripples at all
    if ( m_rippleList.count == 0 ) return;

    // ripples are simulated by altering texture coordinates
    // on all updates, an entire new array is calculated from the base array
    // not maintainng an original set of texture coordinates, could result in accumulated errors
    memcpy( m_rippleCoordinate, m_textureCoordinate, m_bufferSize * sizeof( CGPoint ) );

    // scan through running ripples
    // the scan is backwards, so that ripples can be removed on the fly
    for ( int count = ( m_rippleList.count - 1 ); count >= 0; count -- ) {

        // get ripple data
        ripple = ( rippleData* )[ [ m_rippleList objectAtIndex:count ] pointerValue ];

        // scan through all texture coordinates
        for ( int count = 0; count < m_bufferSize; count ++ ) {

            // dont modify edge vertices
            if ( m_edgeVertice[ count ] == NO ) {

                // calculate distance
                // you might think it would be faster to do a box check first
                // but it really isnt,
                // ccpDistance is like my sexlife - BAM! - and its all over
                distance = ccpDistance( ripple->center, m_vertice[ count ] );

                // only modify vertices within range
                if ( distance <= ripple->currentRadius ) {

                    // load the texture coordinate into an easy to use var
                    pos = m_rippleCoordinate[ count ];  

                    // calculate a ripple
                    switch ( ripple->rippleType ) {

                        case RIPPLE_TYPE_RUBBER:
                            // method A
                            // calculate a sinus, based only on time
                            // this will make the ripples look like poking a soft rubber sheet, since sinus position is fixed
                            correction = sinf( 2 * M_PI * ripple->runtime / ripple->rippleCycle );
                            break;

                        case RIPPLE_TYPE_GEL:
                            // method B
                            // calculate a sinus, based both on time and distance
                            // this will look more like a high viscosity fluid, since sinus will travel with radius
                            correction = sinf( 2 * M_PI * ( ripple->currentRadius - distance ) / ripple->radius * ripple->lifespan / ripple->rippleCycle );
                            break;

                        case RIPPLE_TYPE_WATER:
                        default:
                            // method c
                            // like method b, but faded for time and distance to center
                            // this will look more like a low viscosity fluid, like water     

                            correction = ( ripple->radius * ripple->rippleCycle / ripple->lifespan ) / ( ripple->currentRadius - distance );
                            if ( correction > 1.0f ) correction = 1.0f;

                            // fade center of quicker
                            correction *= correction;

                            correction *= sinf( 2 * M_PI * ( ripple->currentRadius - distance ) / ripple->radius * ripple->lifespan / ripple->rippleCycle );
                            break;

                    }

                    // fade with distance
                    correction *= 1 - ( distance / ripple->currentRadius );

                    // fade with time
                    correction *= 1 - ( ripple->runtime / ripple->lifespan );

                    // adjust for base gain and user strength
                    correction *= RIPPLE_BASE_GAIN;
                    correction *= ripple->strength;

                    // finally modify the coordinate by interpolating
                    // because of interpolation, adjustment for distance is needed,
                    correction /= ccpDistance( ripple->centerCoordinate, pos );
                    pos = ccpAdd( pos, ccpMult( ccpSub( pos, ripple->centerCoordinate ), correction ) );

                    // another approach for applying correction, would be to calculate slope from center to pos
                    // and then adjust based on this

                    // clamp texture coordinates to avoid artifacts
                    pos = ccpClamp( pos, CGPointZero, ccp( m_texture.maxS, m_texture.maxT ) );

                    // save modified coordinate
                    m_rippleCoordinate[ count ] = pos;

                }
            }
        }

        // calculate radius
        ripple->currentRadius = ripple->radius * ripple->runtime / ripple->lifespan;

        // check if ripple should expire
        ripple->runtime += dt;
        if ( ripple->runtime >= ripple->lifespan ) {

            // free memory, and remove from list
            free( ripple );
            [ m_rippleList removeObjectAtIndex:count ];

        }

    }
}

// --------------------------------------------------------------------------

@end
