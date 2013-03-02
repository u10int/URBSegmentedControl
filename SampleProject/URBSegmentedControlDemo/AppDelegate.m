//
//  AppDelegate.m
//  URBSegmentedControlDemo
//
//  Created by Nicholas Shipes on 2/1/13.
//  Copyright (c) 2013 Urban10 Interactive. All rights reserved.
//

#import "AppDelegate.h"
#import "URBSegmentedControl.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	UIViewController *viewController = [[UIViewController alloc] initWithNibName:nil bundle:nil];
	
	// use UIAppearance to set styles on control
	[[URBSegmentedControl appearance] setSegmentBackgroundColor:[UIColor greenColor]];
	
	
	// items to be used for each segment (same as UISegmentControl) for all instances
	NSArray *titles = [NSArray arrayWithObjects:[@"Item 1" uppercaseString], [@"Item 2" uppercaseString], [@"Item 3" uppercaseString], nil];
	NSArray *icons = [NSArray arrayWithObjects:[UIImage imageNamed:@"mountains.png"], [UIImage imageNamed:@"snowboarder.png"], [UIImage imageNamed:@"biker.png"], nil];
	
	//
	// Basic horizontal segmented control
	//
	URBSegmentedControl *control = [[URBSegmentedControl alloc] initWithItems:titles];
	control.frame = CGRectMake(10.0, 10.0, 300.0, 40.0);
	control.segmentBackgroundColor = [UIColor blueColor];
	[control setSegmentBackgroundColor:[UIColor greenColor] atIndex:2];
	[viewController.view addSubview:control];
	
	// UIKit method of handling value changes
	[control addTarget:self action:@selector(handleSelection:) forControlEvents:UIControlEventValueChanged];
	// block-based value change handler
	[control setControlEventBlock:^(NSInteger index, URBSegmentedControl *segmentedControl) {
		NSLog(@"URBSegmentedControl: control block - index=%i", index);
	}];
	
	//
	// Horizontal segmented control with icons using the standard initWithItems: method of UISegmentedControl
	//
	URBSegmentedControl *iconControl = [[URBSegmentedControl alloc] initWithItems:titles];
	iconControl.frame = CGRectMake(10.0, CGRectGetMaxY(control.frame) + 20.0, 300.0, 40.0);
	[viewController.view addSubview:iconControl];
	
	// set icons for each segment
	[iconControl setImage:[UIImage imageNamed:@"mountains.png"] forSegmentAtIndex:0];
	[iconControl setImage:[UIImage imageNamed:@"snowboarder.png"] forSegmentAtIndex:1];
	[iconControl setImage:[UIImage imageNamed:@"biker.png"] forSegmentAtIndex:2];
	
	
	//
	// Vertical segmented control with icons in vertical layout
	//
	URBSegmentedControl *verticalControl = [[URBSegmentedControl alloc] initWithTitles:titles icons:icons];
	verticalControl.frame = CGRectMake(10.0, CGRectGetMaxY(iconControl.frame) + 20.0, 100.0, 300.0);
	verticalControl.layoutOrientation = URBSegmentedControlOrientationVertical;
	verticalControl.segmentViewLayout = URBSegmentViewLayoutVertical;
	[viewController.view addSubview:verticalControl];
	
	
	//
	// Vertical segmented control with icons in horizontal layout
	//
	URBSegmentedControl *verticalControl2 = [[URBSegmentedControl alloc] initWithTitles:titles icons:icons];
	verticalControl2.frame = CGRectMake(CGRectGetMaxX(verticalControl.frame) + 20.0, CGRectGetMaxY(iconControl.frame) + 20.0, 180.0, 150.0);
	verticalControl2.layoutOrientation = URBSegmentedControlOrientationVertical;
	verticalControl2.imageEdgeInsets = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
	[viewController.view addSubview:verticalControl2];
	
	// set icons for each segment
	[verticalControl2 setImage:[UIImage imageNamed:@"mountains.png"] forSegmentAtIndex:0];
	[verticalControl2 setImage:[UIImage imageNamed:@"snowboarder.png"] forSegmentAtIndex:1];
	[verticalControl2 setImage:[UIImage imageNamed:@"biker.png"] forSegmentAtIndex:2];
	
	
	//
	// Vertical segmented control with icons only
	//
	URBSegmentedControl *verticalIconControl = [[URBSegmentedControl alloc] initWithIcons:icons];
	verticalIconControl.frame = CGRectMake(CGRectGetMaxX(verticalControl.frame) + 20.0, CGRectGetMaxY(verticalControl2.frame) + 20.0, 50.0, 130.0);
	verticalIconControl.layoutOrientation = URBSegmentedControlOrientationVertical;
	verticalIconControl.contentEdgeInsets = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
	[viewController.view addSubview:verticalIconControl];
	
	//
	// Vertical segmented control with icons in horizontal layout and no gradient
	//
	URBSegmentedControl *horizVerticalControl = [[URBSegmentedControl alloc] initWithTitles:titles icons:icons];
	horizVerticalControl.frame = CGRectMake(10.0, CGRectGetMaxY(verticalControl.frame) + 20.0, 300.0, 80.0);
	horizVerticalControl.segmentViewLayout = URBSegmentViewLayoutVertical;
	horizVerticalControl.showsGradient = NO;
	horizVerticalControl.contentEdgeInsets = UIEdgeInsetsMake(6.0, 6.0, 6.0, 6.0);
	horizVerticalControl.imageEdgeInsets = UIEdgeInsetsMake(6.0, 8.0, 8.0, 8.0);
	horizVerticalControl.titleEdgeInsets = UIEdgeInsetsZero;
	[viewController.view addSubview:horizVerticalControl];
	
	
	self.window.rootViewController = viewController;	
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)handleSelection:(id)sender {
	NSLog(@"URBSegmentedControl: value changed");
}

@end
