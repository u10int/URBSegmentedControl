URBSegmentedControl
===================

## Overview

`URBSegmentedControl` is a more flexible alternative to the default `UISegmentedControl` available in UIKit that offers easier customization and more options for layout orientations with titles and images. However, much of the same functionality and API methods that are available in `UISegmentedControl` are also available in `URBSegmentedControl`, making it an easier drop-in replacement within your own projects.

![Screenshot of the sample project example](http://dl.dropbox.com/u/197980/Screenshots/URBSegmentedControl_screenshot01.png)

## Features

- Segments can be just icons or titles, or titles with icons
- Supports customizable colors and fonts
- Supports using UIAppearance for setting the global styles on all instances
- Supports blocks for value changes
- Automatically tints images based on normal and selected image colors (no need for two separate versions of your icons)
- Horizontal and vertial layout orientations for the overall control and for each individual segment
- Uses ARC and targets iOS 5.0+

## Installation

To use `URBSegmentedControl` in your own project:
- import `URBSegmentedControl.h` and `URBSegmentedControl.m` files into your project, and then include "`URBSegmentedControl.h`" where needed, or in your precompiled header
- link against the `QuartzCore` framework by adding `QuartzCore.framework` to your project under `Build Phases` > `Link Binary With Libraries`.

Once installed, you can then use `URBSegmentedControl` just as you would with UIKit's `UISegmentedControl`.

This project uses ARC and targets iOS 5.0+.

## Usage

(see more detailed usage examples in the included project under /SampleProject)

The following is the most basic example of creating an URBSegmentedControl instance that mimics the same for UISegmentedControl:

```objective-c
NSArray *titles = [NSArray arrayWithObjects:[@"Item 1" uppercaseString], [@"Item 2" uppercaseString], [@"Item 3" uppercaseString], nil];
URBSegmentedControl *control = [[URBSegmentedControl alloc] initWithItems:titles];
[control addTarget:self action:@selector(handleSelection:) forControlEvents:UIControlEventValueChanged];
[viewController.view addSubview:control];
```

Instead of adding a target to the control to respond to value changes, you can set a handler block on each instance:

```objective-c
NSArray *titles = [NSArray arrayWithObjects:[@"Item 1" uppercaseString], [@"Item 2" uppercaseString], [@"Item 3" uppercaseString], nil];
URBSegmentedControl *control = [[URBSegmentedControl alloc] initWithItems:titles];
[control setControlEventBlock:^(NSInteger index, URBSegmentedControl *segmentedControl) {
	NSLog(@"control value changed - index=%i", index);
}];
[viewController.view addSubview:control];
```

If you just want a control with icons only, you would initialize the instance with `initWithIcons:`:

```objective-c
NSArray *icons = [NSArray arrayWithObjects:[UIImage imageNamed:@"mountains.png"], [UIImage imageNamed:@"snowboarder.png"], [UIImage imageNamed:@"biker.png"], nil];
URBSegmentedControl *control = [[URBSegmentedControl alloc] initWithIcons:icons];
[viewController.view addSubview:control];
```

Alternative, you can initialize an instance with both titles and images (as long as both arrays provided for each are equal in length):

```objective-c
NSArray *titles = [NSArray arrayWithObjects:[@"Item 1" uppercaseString], [@"Item 2" uppercaseString], [@"Item 3" uppercaseString], nil];
NSArray *icons = [NSArray arrayWithObjects:[UIImage imageNamed:@"mountains.png"], [UIImage imageNamed:@"snowboarder.png"], [UIImage imageNamed:@"biker.png"], nil];
URBSegmentedControl *control = [[URBSegmentedControl alloc] initWithTitles:titles icons:icons];
[viewController.view addSubview:control];
```

## Customization

Your `URBSegmentedControl` can be customized using the following properties:

```objective-c
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic) CGFloat cornerRadius;
```

## TODO

- Support setting images to use for background and segment states
- Support installation via CocoaPods

## Credits

The sample URBSegmentedControlDemo project uses the following icons from their respective authors (all from [The Noun Project](http://thenounproject.com) ):

- [Snowboarder](http://thenounproject.com/noun/bike-hop/#icon-No2042) designed by [Vlad Likh](http://thenounproject.com/likh.v) from The Noun Project (under public domain)
- [Mountains](http://thenounproject.com/noun/mountains/#icon-No2469) designed by [Chris Cole](http://thenounproject.com/hellochriscole) from The Noun Project
- [Bike Hop](http://thenounproject.com/noun/bike-hop/#icon-No1889) designed by [Alfonso Melolonta Urbán](http://thenounproject.com/melolonta) from The Noun Project

## License

This code is distributed under the terms and conditions of the MIT license.
