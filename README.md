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
// base styles
@property (nonatomic, strong) UIColor *baseColor;				// default [UIColor colorWithWhite:0.3 alpha:1.0]
@property (nonatomic, strong) UIColor *strokeColor;				// default [UIColor darkGrayColor]
@property (nonatomic, assign) CGFloat strokeWidth;				// default 2.0
@property (nonatomic) CGFloat cornerRadius;						// default 2.0
@property (nonatomic, assign) UIEdgeInsets segmentEdgeInsets;	// default UIEdgeInsetsMake(4.0, 4.0, 4.0, 4.0)

// segment styles
@property (nonatomic, strong) UIColor *segmentBackgroundColor;		// default [UIColor redColor]
@property (nonatomic, strong) UIColor *imageColor;					// default [UIColor grayColor]
@property (nonatomic, strong) UIColor *selectedImageColor;			// default [UIColor whiteColor]
@property (nonatomic, assign) BOOL showsGradient;					// determines if the base and segment background should have a gradient applied, default YES
```

By default, your images will be tinted with the colors you define using the `imageColor` and `selectedImageColor` properties. If you would rather keep your images in their original format, just set these color properties to `nil`:

```objective-c
control.imageColor = nil;
control.selectedImageColor = nil;
```

In most cases, the default insets applied to the content, title and image for each segment will work. However, if your control is smaller or you wish to adjust the sizes of elements better, you can adjust the insets by setting the following properties on your instance:

```objective-c
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets titleEdgeInsets;
@property (nonatomic, assign) UIEdgeInsets imageEdgeInsets;
```

## TODO

- Support setting images to use for background and segment states instead of drawing in CoreGraphics within the class
- Support for UISegmentedControl's `momentary` mode
- Better support for customization using UIAppearance
- Support installation via CocoaPods

## Credits

The sample URBSegmentedControlDemo project uses the following icons from their respective authors (all from [The Noun Project](http://thenounproject.com) ):

- [Snowboarder](http://thenounproject.com/noun/bike-hop/#icon-No2042) designed by [Vlad Likh](http://thenounproject.com/likh.v) from The Noun Project (under public domain)
- [Mountains](http://thenounproject.com/noun/mountains/#icon-No2469) designed by [Chris Cole](http://thenounproject.com/hellochriscole) from The Noun Project
- [Bike Hop](http://thenounproject.com/noun/bike-hop/#icon-No1889) designed by [Alfonso Melolonta Urbán](http://thenounproject.com/melolonta) from The Noun Project

## License

This code is distributed under the terms and conditions of the MIT license. Review the full [LICENSE](LICENSE) for all the details.

## Support/Contact

Think you found a bug or just have a feature request? Just [post it as an issue](https://github.com/u10int/URBSegmentedControl/issues), but make sure to review the existing issues first to avoid duplicates. You can also hit me up at [@u10int](http://twitter.com/u10int) for anything else, or to let me know how you're using this component. Thanks!
