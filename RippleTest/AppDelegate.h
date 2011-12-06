//
//  AppDelegate.h
//  RippleTest
//
//  Created by Dave Hersey, Paracoders, Inc. on 12/4/11.
//  Ripples provided by Birkemose.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
