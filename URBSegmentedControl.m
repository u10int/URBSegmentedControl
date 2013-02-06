//
//  URBSegmentedControl.m
//  URBSegmentedControlDemo
//
//  Created by Nicholas Shipes on 2/1/13.
//  Copyright (c) 2013 Urban10 Interactive. All rights reserved.
//

#import "URBSegmentedControl.h"
#import <QuartzCore/QuartzCore.h>

@interface UIColor (URBSegmentedControl)
- (UIColor *)adjustBrightness:(CGFloat)amount;
@end

@interface URBSegmentView : UIButton
@property (nonatomic, assign) URBSegmentViewLayout viewLayout;
@property (nonatomic, strong) UIColor *imageBackgroundColor;
@property (nonatomic, strong) UIColor *selectedImageBackgroundColor;
@property (nonatomic, assign) CGFloat cornerRadius;
- (void)setTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state;
- (void)updateBackgrounds;
@end

@interface URBSegmentedControl ()
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIImageView *backgroundView;
@property (nonatomic) UIEdgeInsets segmentEdgeInsets;
@property (nonatomic, strong) NSDictionary *segmentTextAttributes;
- (void)layoutSegments;
- (void)handleSelect:(URBSegmentView *)segmentView;
- (NSInteger)firstEnabledSegmentIndexNearIndex:(NSUInteger)index;
- (UIImage *)defaultBackgroundImage;
@end 

static CGSize const kURBDefaultSize = {300.0f, 44.0f};

@implementation URBSegmentedControl {
	NSInteger _selectedSegmentIndex;
	NSInteger _lastSelectedSegmentIndex;
}

- (id)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
		_selectedSegmentIndex = -1;
		_lastSelectedSegmentIndex = -1;
		_items = [NSMutableArray new];
		
		[self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		
		self.frame = CGRectMake(10.0, 0.0, kURBDefaultSize.width, kURBDefaultSize.height);
		self.backgroundColor = [UIColor clearColor];
		self.imageColor = [UIColor grayColor];
		self.selectedImageColor = [UIColor whiteColor];
		self.segmentEdgeInsets = UIEdgeInsetsMake(4.0f, 4.0f, 4.0f, 4.0f);
		
		// base styles
		self.baseColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
		self.strokeColor = [UIColor darkGrayColor];
		self.segmentBackgroundColor = nil;
		self.strokeWidth = 2.0f;
		self.cornerRadius = 4.0f;
		
		// layout
		self.layoutOrientation = URBSegmentedControlOrientationHorizontal;
		self.segmentViewLayout = URBSegmentViewLayoutDefault;
		
		// base image view
        _backgroundView = [[UIImageView alloc] init];
		_backgroundView.backgroundColor = [UIColor clearColor];
		_backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		_backgroundView.frame = self.frame;
		[self insertSubview:_backgroundView atIndex:0];
    }
    return self;
}

- (id)initWithItems:(NSArray *)items {
	self = [self init];
	if (self) {
		[items enumerateObjectsUsingBlock:^(id title, NSUInteger idx, BOOL *stop) {
			[self insertSegmentWithTitle:title image:nil atIndex:idx animated:NO];
		}];
	}
	return self;
}

- (id)initWithTitles:(NSArray *)titles {
	return [self initWithItems:titles];
}

- (id)initWithIcons:(NSArray *)icons {
	self = [self init];
	if (self) {
		[icons enumerateObjectsUsingBlock:^(UIImage *image, NSUInteger idx, BOOL *stop) {
			[self insertSegmentWithTitle:nil image:image atIndex:idx animated:NO];
		}];
	}
	return self;
}

- (id)initWithTitles:(NSArray *)titles icons:(NSArray *)icons {
	NSParameterAssert(titles.count == icons.count);
	self = [self init];
	if (self) {
		[titles enumerateObjectsUsingBlock:^(NSString *title, NSUInteger idx, BOOL *stop) {
			[self insertSegmentWithTitle:title image:[icons objectAtIndex:idx] atIndex:idx animated:NO];
		}];
	}
	return self;
}

- (void)insertSegmentWithTitle:(NSString *)title image:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated {
	URBSegmentView *segmentView = [URBSegmentView new];
	[segmentView setTitle:title forState:UIControlStateNormal];
	[segmentView setImage:[image imageTintedWithColor:self.imageColor] forState:UIControlStateNormal];
	[segmentView setImage:[image imageTintedWithColor:self.selectedImageColor] forState:UIControlStateSelected];
	[segmentView addTarget:self action:@selector(handleSelect:) forControlEvents:UIControlEventTouchUpInside];
	
	// style the segment
	segmentView.viewLayout = self.segmentViewLayout;
	if (self.segmentTextAttributes) {
		[segmentView setTextAttributes:self.segmentTextAttributes forState:UIControlStateNormal];
	}
	
	// set custom styles if defined
	segmentView.cornerRadius = self.cornerRadius;
	if (self.segmentBackgroundColor) {
		segmentView.imageBackgroundColor = self.segmentBackgroundColor;
	}
	
	// set initial frame for segment, which will be adjusted later when we actually lay everything out
	// we just need some size for proper height of the background images that are drawn
	CGRect segmentRect = CGRectMake(0, 0, MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)), MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)));
	segmentView.frame = CGRectInset(segmentRect, self.segmentEdgeInsets.top, self.segmentEdgeInsets.left);
	
	NSUInteger index = MAX(MIN(segment, self.numberOfSegments), 0);
	if (index < self.items.count) {
		[self.items insertObject:segmentView atIndex:index];
	}
	else {
		[self.items addObject:segmentView];
	}
	[self addSubview:segmentView];
	
	if (self.selectedSegmentIndex >= index) {
		self.selectedSegmentIndex++;
	}
	_lastSelectedSegmentIndex = self.selectedSegmentIndex;
	
	if (animated) {
		[UIView animateWithDuration:0.4 animations:^{
			[self layoutSegments];
		}];
	}
	else {
		[self setNeedsLayout];
	}
}

#pragma mark - UIKit API Overrides

- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated {
	[self insertSegmentWithTitle:title image:nil atIndex:segment animated:animated];
}

- (void)insertSegmentWithImage:(UIImage *)image atIndex:(NSUInteger)segment animated:(BOOL)animated {
	[self insertSegmentWithTitle:nil image:image atIndex:segment animated:animated];
}

- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated {
	if (self.items.count == 0) return;
	
	URBSegmentView *segmentView = [self segmentAtIndex:segment];
	[self.items removeObject:segmentView];
	
	if (self.selectedSegmentIndex >= 0) {
		BOOL changed = NO;
		if (self.items.count == 1) {
			self.selectedSegmentIndex = -1;
			changed = YES;
		}
		else if (self.selectedSegmentIndex == segment) {
			self.selectedSegmentIndex = [self firstEnabledSegmentIndexNearIndex:self.selectedSegmentIndex];
			changed = YES;
		}
		else if (self.selectedSegmentIndex > segment) {
			self.selectedSegmentIndex = [self firstEnabledSegmentIndexNearIndex:self.selectedSegmentIndex];
		}
		
		_lastSelectedSegmentIndex = self.selectedSegmentIndex;
		if (changed) {
			[self sendActionsForControlEvents:UIControlEventValueChanged];
			if (self.controlEventBlock) {
				self.controlEventBlock(self.selectedSegmentIndex, self);
			}
		}
	}
	
	if (animated) {
		[UIView animateWithDuration:0.4 animations:^{
			segmentView.alpha = 0.0f;
			[self layoutSegments];
		}];
	}
	else {
		[segmentView removeFromSuperview];
		[self layoutSegments];
	}
}

- (void)removeAllSegments {
	[self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[self.items removeAllObjects];
	_selectedSegmentIndex = -1;
	[self setNeedsLayout];
}

- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment {
	return [[self segmentAtIndex:segment] imageForState:UIControlStateNormal];
}

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment {
	[[self segmentAtIndex:segment] setImage:[image imageTintedWithColor:self.imageColor] forState:UIControlStateNormal];
	[[self segmentAtIndex:segment] setImage:[image imageTintedWithColor:self.selectedImageColor] forState:UIControlStateSelected];
}

- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment {
	return [[self segmentAtIndex:segment] titleForState:UIControlStateNormal];
}

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment {
	[[self segmentAtIndex:segment] setTitle:title forState:UIControlStateNormal];
}

- (NSUInteger)numberOfSegments {
	return self.items.count;
}

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment {
	[self segmentAtIndex:segment].enabled = enabled;
}

- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment {
	return [self segmentAtIndex:segment].enabled;
}

- (void)setSelectedSegmentIndex:(NSInteger)selectedSegmentIndex {
	if (_selectedSegmentIndex != selectedSegmentIndex) {
		NSParameterAssert(selectedSegmentIndex < (NSInteger)self.items.count);
		
		// deselect current segment if selected
		if (_selectedSegmentIndex >= 0)
			((URBSegmentView *)[self segmentAtIndex:_selectedSegmentIndex]).selected = NO;
		
		((URBSegmentView *)[self segmentAtIndex:selectedSegmentIndex]).selected = YES;
		_lastSelectedSegmentIndex = _selectedSegmentIndex;
		_selectedSegmentIndex = selectedSegmentIndex;
		
		[self setNeedsLayout];
	}
}

- (void)setSegmentViewLayout:(URBSegmentViewLayout)segmentViewLayout {
	if (segmentViewLayout != _segmentViewLayout) {
		[self.items enumerateObjectsUsingBlock:^(URBSegmentView *segmentView, NSUInteger idx, BOOL *stop) {
			segmentView.viewLayout = segmentViewLayout;
			[segmentView setNeedsLayout];
		}];
	}
}

- (NSInteger)selectedSegmentIndex {
	return _selectedSegmentIndex;
}

- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment {
	URBSegmentView *segmentView = [self segmentAtIndex:segment];
	CGRect frame = segmentView.frame;
	frame.size.width = width;
	segmentView.frame = frame;
	[self setNeedsLayout];
}

- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment {
	return CGRectGetWidth([self segmentAtIndex:segment].frame);
}

#pragma mark - Customization

- (void)setTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state {
	self.segmentTextAttributes = textAttributes;
}

- (void)setSegmentBackgroundColor:(UIColor *)segmentBackgroundColor {
	if (segmentBackgroundColor != _segmentBackgroundColor) {
		_segmentBackgroundColor = segmentBackgroundColor;
		
		[self.items enumerateObjectsUsingBlock:^(URBSegmentView *segmentView, NSUInteger idx, BOOL *stop) {
			segmentView.imageBackgroundColor = segmentBackgroundColor;
		}];
	}
}

- (void)setImageColor:(UIColor *)imageColor forState:(UIControlState)state {
	[self.items enumerateObjectsUsingBlock:^(URBSegmentView *segmentView, NSUInteger idx, BOOL *stop) {
		
		UIImage *image = [segmentView imageForState:state];
		UIColor *color = (state == UIControlStateSelected) ? self.selectedImageColor : self.imageColor;
		
		[segmentView setImage:[image imageTintedWithColor:color] forState:state];

	}];
}

#pragma mark - Background Images

- (UIImage *)defaultBackgroundImage {
	CGSize size = self.bounds.size;
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	
	CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height);
	CGFloat stroke = self.strokeWidth;
	CGFloat radius = self.cornerRadius;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// colors
	UIColor* baseGradientTopColor = [self.baseColor adjustBrightness:1.1];
	UIColor* baseGradientBottomColor = [self.baseColor adjustBrightness:0.9];
	UIColor* baseStrokeColor = self.strokeColor;
	
	// gradients
	NSArray* baseGradientColors = @[(id)baseGradientTopColor.CGColor, (id)baseGradientBottomColor.CGColor];
	CGFloat baseGradientLocations[] = {0, 1};
	CGGradientRef baseGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)baseGradientColors, baseGradientLocations);
	
	// shadows
	UIColor* baseInnerShadow = [UIColor blackColor];
	CGSize baseInnerShadowOffset = CGSizeMake(0.1, 1.1);
	CGFloat baseInnerShadowBlurRadius = 3;
	
	{
		// base path
		CGRect backgroundBaseRect = CGRectMake(CGRectGetMinX(frame) + stroke / 2.0, CGRectGetMinY(frame) + stroke / 2.0, size.width - stroke, size.height - stroke);
		UIBezierPath* backgroundBasePath = [UIBezierPath bezierPathWithRoundedRect: backgroundBaseRect cornerRadius:radius];
		CGContextSaveGState(context);
		[backgroundBasePath addClip];
		CGContextDrawLinearGradient(context, baseGradient,
									CGPointMake(CGRectGetMidX(backgroundBaseRect), CGRectGetMinY(backgroundBaseRect)),
									CGPointMake(CGRectGetMidX(backgroundBaseRect), CGRectGetMaxY(backgroundBaseRect)),
									0);
		CGContextRestoreGState(context);
		
		// inner shadow
		CGRect backgroundBaseBorderRect = CGRectInset([backgroundBasePath bounds], -baseInnerShadowBlurRadius, -baseInnerShadowBlurRadius);
		backgroundBaseBorderRect = CGRectOffset(backgroundBaseBorderRect, -baseInnerShadowOffset.width, -baseInnerShadowOffset.height);
		backgroundBaseBorderRect = CGRectInset(CGRectUnion(backgroundBaseBorderRect, [backgroundBasePath bounds]), -1, -1);
		
		UIBezierPath* backgroundBaseNegativePath = [UIBezierPath bezierPathWithRect: backgroundBaseBorderRect];
		[backgroundBaseNegativePath appendPath: backgroundBasePath];
		backgroundBaseNegativePath.usesEvenOddFillRule = YES;
		
		CGContextSaveGState(context);
		{
			CGFloat xOffset = baseInnerShadowOffset.width + round(backgroundBaseBorderRect.size.width);
			CGFloat yOffset = baseInnerShadowOffset.height;
			CGContextSetShadowWithColor(context,
										CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
										baseInnerShadowBlurRadius,
										baseInnerShadow.CGColor);
			
			[backgroundBasePath addClip];
			CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(backgroundBaseBorderRect.size.width), 0);
			[backgroundBaseNegativePath applyTransform: transform];
			[[UIColor grayColor] setFill];
			[backgroundBaseNegativePath fill];
		}
		CGContextRestoreGState(context);
		
		[baseStrokeColor setStroke];
		backgroundBasePath.lineWidth = 2;
		[backgroundBasePath stroke];
	}
	
	CGGradientRelease(baseGradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	CGFloat topCap = CGRectGetMidY(frame) - 1.0;
	CGFloat leftCap = CGRectGetMidX(frame) - 1.0;
	
	return [image resizableImageWithCapInsets:UIEdgeInsetsMake(topCap, leftCap, topCap, leftCap)];
}

#pragma mark - Private

- (URBSegmentView *)segmentAtIndex:(NSUInteger)index {
	NSParameterAssert(index >= 0 && index < self.items.count);
	return [self.items objectAtIndex:index];
}

- (NSInteger)firstEnabledSegmentIndexNearIndex:(NSUInteger)index {
	for (int i = index; i < self.items.count; i++) {
		if (((URBSegmentView *)[self.items objectAtIndex:i]).enabled) {
			return i;
		}
	}
	
	for (int i = index; i >= 0; i--) {
		if (((URBSegmentView *)[self.items objectAtIndex:i]).enabled) {
			return i;
		}
	}
	return -1;
}

- (void)handleSelect:(URBSegmentView *)segmentView {
	NSUInteger index = [self.items indexOfObject:segmentView];
	if (index != NSNotFound && index != self.selectedSegmentIndex) {
		self.selectedSegmentIndex = index;
		[self setNeedsLayout];
		[self sendActionsForControlEvents:UIControlEventValueChanged];
		if (self.controlEventBlock) {
			self.controlEventBlock(self.selectedSegmentIndex, self);
		}
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	self.backgroundView.frame = self.bounds;
	if (!self.backgroundView.image) {
		self.backgroundView.image = [self defaultBackgroundImage];
	}
	[self layoutSegments];
}

- (void)layoutSegments {
	if (self.items.count == 0) return;
	
	// calculate width of each segment based on number of items and total available width
	CGRect segmentRect = CGRectInset(self.bounds, self.segmentEdgeInsets.top, self.segmentEdgeInsets.left);
	CGSize totalSize = segmentRect.size;
	CGSize segmentSize = (self.layoutOrientation == URBSegmentedControlOrientationVertical) ? CGSizeMake(totalSize.width, totalSize.height / self.items.count) : CGSizeMake(totalSize.width / self.items.count, totalSize.height);
	
	[self.items enumerateObjectsUsingBlock:^(URBSegmentView *item, NSUInteger idx, BOOL *stop) {
		if (self.layoutOrientation == URBSegmentedControlOrientationVertical) {
			item.frame = CGRectMake(CGRectGetMinX(segmentRect), CGRectGetMinY(segmentRect) + segmentSize.height * idx, segmentSize.width, segmentSize.height);
		}
		else {
			item.frame = CGRectMake(CGRectGetMinX(segmentRect) + segmentSize.width * idx, CGRectGetMinY(segmentRect), segmentSize.width, segmentSize.height);
		}
		[item setNeedsLayout];
	}];
}

@end


#pragma mark - URBSegmentView

@implementation URBSegmentView {
	BOOL _hasDrawnImages;
	BOOL _adjustInsetsForSize;
}

+ (void)initialize {
	[super initialize];
	
	URBSegmentView *appearance = [self appearance];
	
	[appearance setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
	[appearance setTitleShadowColor:[UIColor blackColor] forState:UIControlStateNormal];
	
	[appearance setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
	[appearance setTitleShadowColor:[UIColor blackColor] forState:UIControlStateSelected];
}

+ (URBSegmentView *)new {
	return [self.class buttonWithType:UIButtonTypeCustom];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
		self.titleLabel.shadowOffset = CGSizeMake(0, 0.5);
		self.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:14.0];
		self.userInteractionEnabled = YES;
		self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
		self.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		self.clipsToBounds = NO;
		self.adjustsImageWhenHighlighted = NO;
		
		self.viewLayout = URBSegmentViewLayoutDefault;
		
		self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
		self.titleLabel.textAlignment = UITextAlignmentCenter;
		
		self.imageView.contentMode = UIViewContentModeScaleAspectFit;
		self.imageView.layer.shadowColor = [UIColor blackColor].CGColor;
		self.imageView.layer.shadowOffset = CGSizeMake(0.0, 1.0);
		self.imageView.layer.shadowRadius = 0;
		self.imageView.layer.shadowOpacity = 1.0;
		self.imageView.layer.masksToBounds = NO;
		self.imageView.layer.shouldRasterize = YES;
		self.imageView.layer.rasterizationScale = self.imageView.image.scale;
		
		self.imageBackgroundColor = [UIColor redColor];
		
		_hasDrawnImages = NO;
		_adjustInsetsForSize = YES;
	}
	return self;
}

- (void)setTextAttributes:(NSDictionary *)textAttributes forState:(UIControlState)state {
	UIFont *font = [textAttributes objectForKey:UITextAttributeFont];
	UIColor *textColor = [textAttributes objectForKey:UITextAttributeTextColor];
	UIColor *textShadowColor = [textAttributes objectForKey:UITextAttributeTextShadowColor];
	NSValue *shadowOffsetValue = [textAttributes objectForKey:UITextAttributeTextShadowOffset];
	
    if (font) {
		self.titleLabel.font = font;
	}
	
    if (textColor) {
		[self setTitleColor:textColor forState:state];
	}
	
    if (textShadowColor) {
		[self setTitleShadowColor:textShadowColor forState:state];
	}
	
    if (shadowOffsetValue) {
        UIOffset shadowOffset = [shadowOffsetValue UIOffsetValue];
        self.titleLabel.shadowOffset = CGSizeMake(shadowOffset.horizontal, shadowOffset.vertical);
    }
}

- (void)setViewLayout:(URBSegmentViewLayout)viewLayout {
	_viewLayout = viewLayout;
	
	if (viewLayout == URBSegmentViewLayoutVertical) {
		self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 12.0, 0);
		self.imageEdgeInsets = UIEdgeInsetsMake(8.0f, 8.0, 20.0f, 8.0);
		self.contentEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 0.0f, 10.0f);
	}
	else {
		self.titleEdgeInsets = UIEdgeInsetsMake(2.0, 0, 0, 0);
		self.imageEdgeInsets = UIEdgeInsetsZero;
		self.contentEdgeInsets = UIEdgeInsetsMake(4.0f, 8.0f, 4.0f, 8.0f);
	}
}

- (void)layoutSubviews {
	[super layoutSubviews];
	
	if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
		return;
	}
	// automatically reset title and image insets if this segment is below a certain size to prevent
	// the image from getting too small
	else if (_adjustInsetsForSize) {
		if (self.viewLayout == URBSegmentViewLayoutVertical) {
			if (CGRectGetHeight(self.bounds) / CGRectGetWidth(self.bounds) < 0.75) {
				self.imageEdgeInsets = UIEdgeInsetsMake(5.0f, 5.0f, 8.0f, 5.0f);
				self.contentEdgeInsets = UIEdgeInsetsMake(6.0f, 6.0f, 0.0f, 6.0f);
				self.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 3.0, 0);
			}
			_adjustInsetsForSize = NO;
		}
	}
		
	// don't draw background images until we have a valid size so that our vertical gradients display properly.
	if (!_hasDrawnImages) {
		_hasDrawnImages = YES;
		[self updateBackgrounds];
	}
	
	CGRect frame = UIEdgeInsetsInsetRect(self.bounds, self.contentEdgeInsets);
	CGSize titleSize = [self.titleLabel.text sizeWithFont:self.titleLabel.font forWidth:frame.size.width lineBreakMode:self.titleLabel.lineBreakMode];
	
	if (self.viewLayout == URBSegmentViewLayoutVertical) {
		// only adjust layout if we have both a title and image, otherwise the default layout works
		if (self.titleLabel.text.length > 0 && self.imageView.image) {
			CGRect imageRect = frame;
			imageRect.size.height = CGRectGetHeight(frame) - titleSize.height;
			self.imageView.frame = UIEdgeInsetsInsetRect(imageRect, self.imageEdgeInsets);
			
			// title should start at bottom of content area with bottom inset
			CGRect titleFrame = CGRectMake(CGRectGetMinX(frame), 0, CGRectGetWidth(frame), titleSize.height);
			titleFrame.origin.y = CGRectGetMaxY(frame) - self.titleEdgeInsets.bottom - titleSize.height;
			self.titleLabel.frame = titleFrame;
		}
		else {
			CGRect titleFrame = self.titleLabel.frame;
			titleFrame.size.width = frame.size.width;
			titleFrame.origin.x = CGRectGetMinX(frame);
			titleFrame.origin.y = CGRectGetMidY(self.bounds) - titleSize.height / 2.0;
			self.titleLabel.frame = titleFrame;
		}
	}
	else {
		if (self.titleLabel.text.length > 0 && self.imageView.image) {
			CGRect imageRect = frame;
			imageRect.size.width = imageRect.size.height;
			self.imageView.frame = imageRect;
			
			CGRect titleFrame = UIEdgeInsetsInsetRect(frame, self.titleEdgeInsets);
			titleFrame.origin.x = CGRectGetMaxX(self.imageView.frame);
			titleFrame.size.width = CGRectGetWidth(frame) - CGRectGetMinX(titleFrame);
			self.titleLabel.frame = titleFrame;
		}
		else {
			CGRect titleFrame = UIEdgeInsetsInsetRect(frame, self.titleEdgeInsets);
			titleFrame.origin.x = CGRectGetMinX(frame);
			titleFrame.size.width = frame.size.width;
			self.titleLabel.frame = titleFrame;
		}
	}
	
	if (self.selected)
		self.titleLabel.shadowOffset = CGSizeMake(0.0f, -0.5f);
	else
		self.titleLabel.shadowOffset = CGSizeMake(0.0f, 1.0f);
	
	self.imageView.layer.shadowOffset = self.titleLabel.shadowOffset;
	
}

#pragma mark - Properties

- (void)setImageBackgroundColor:(UIColor *)imageBackgroundColor {
	if (imageBackgroundColor != _imageBackgroundColor) {
		_imageBackgroundColor = imageBackgroundColor;
		
		// only update backgrounds if they've been drawn already
		if (_hasDrawnImages)
			[self updateBackgrounds];
	}
}

#pragma mark - Background Images

- (void)updateBackgrounds {
	[self setBackgroundImage:[self normalBackgroundImage] forState:UIControlStateNormal];
	[self setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateSelected];
}

- (UIImage *)normalBackgroundImage {
	return nil;
}

- (UIImage *)selectedBackgroundImage {
	CGSize size = self.bounds.size;
	UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
	
	CGFloat stroke = 2.0;
	CGFloat radius = self.cornerRadius - 1.0;
	CGRect frame = CGRectMake(0, 0, size.width, size.height);
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// colors
	UIColor *segmentGradientTopColor = [self.imageBackgroundColor adjustBrightness:1.2];
	UIColor *segmentGradientBottomColor = [self.imageBackgroundColor adjustBrightness:0.8];
	UIColor *segmentStrokeColor = [self.imageBackgroundColor adjustBrightness:0.6];
	UIColor *segmentHighlight = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.7];
	
	// gradients
	NSArray *segmentGradientColors = @[(id)segmentGradientTopColor.CGColor, (id)segmentGradientBottomColor.CGColor];
	CGFloat segmentGradientLocations[] = {0, 1};
	CGGradientRef segmentGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)segmentGradientColors, segmentGradientLocations);
	
	// shadows
	CGSize segmentHighlightOffset = CGSizeMake(0.1, 1.1);
	CGFloat segmentHighlightBlurRadius = 2;
	UIColor *segmentShadow = [UIColor blackColor];
	CGSize segmentShadowOffset = CGSizeMake(0.1, -0.1);
	CGFloat segmentShadowBlurRadius = 5;
	
	{
		CGContextSaveGState(context);
		CGContextSetShadowWithColor(context, segmentShadowOffset, segmentShadowBlurRadius, segmentShadow.CGColor);
		CGContextBeginTransparencyLayer(context, NULL);
		
		// outer path
		UIBezierPath *segmentBaseOuterPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(CGRectGetMinX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame)) cornerRadius:radius];
		[segmentStrokeColor setFill];
		[segmentBaseOuterPath fill];
		
		// inner path
		CGRect segmentBaseRect = CGRectMake(CGRectGetMinX(frame) + stroke, CGRectGetMinY(frame) + stroke, CGRectGetWidth(frame) - stroke * 2.0, CGRectGetHeight(frame) - stroke * 2.0);
		UIBezierPath *segmentBasePath = [UIBezierPath bezierPathWithRoundedRect:segmentBaseRect cornerRadius:radius];
		CGContextSaveGState(context);
		[segmentBasePath addClip];
		CGContextDrawLinearGradient(context, segmentGradient,
									CGPointMake(CGRectGetMidX(segmentBaseRect), CGRectGetMinY(segmentBaseRect)),
									CGPointMake(CGRectGetMidX(segmentBaseRect), CGRectGetMaxY(segmentBaseRect)),
									0);
		CGContextRestoreGState(context);
		
		// inner shadow
		CGRect segmentBaseBorderRect = CGRectInset([segmentBasePath bounds], -segmentHighlightBlurRadius, -segmentHighlightBlurRadius);
		segmentBaseBorderRect = CGRectOffset(segmentBaseBorderRect, -segmentHighlightOffset.width, -segmentHighlightOffset.height);
		segmentBaseBorderRect = CGRectInset(CGRectUnion(segmentBaseBorderRect, [segmentBasePath bounds]), -1, -1);
		
		UIBezierPath* segmentBaseNegativePath = [UIBezierPath bezierPathWithRect:segmentBaseBorderRect];
		[segmentBaseNegativePath appendPath: segmentBasePath];
		segmentBaseNegativePath.usesEvenOddFillRule = YES;
		
		CGContextSaveGState(context);
		{
			CGFloat xOffset = segmentHighlightOffset.width + round(segmentBaseBorderRect.size.width);
			CGFloat yOffset = segmentHighlightOffset.height;
			CGContextSetShadowWithColor(context,
										CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
										segmentHighlightBlurRadius,
										segmentHighlight.CGColor);
			
			[segmentBasePath addClip];
			CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(segmentBaseBorderRect.size.width), 0);
			[segmentBaseNegativePath applyTransform: transform];
			[[UIColor grayColor] setFill];
			[segmentBaseNegativePath fill];
		}
		CGContextRestoreGState(context);
		
		CGContextEndTransparencyLayer(context);
		CGContextRestoreGState(context);
	}
	 
	CGGradientRelease(segmentGradient);
	CGColorSpaceRelease(colorSpace);
	
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
	
	CGFloat topCap = CGRectGetMidY(frame) - 1.0;
	CGFloat leftCap = CGRectGetMidX(frame) - 1.0;
	
	return [image resizableImageWithCapInsets:UIEdgeInsetsMake(topCap, leftCap, topCap, leftCap)];
}

@end


#pragma mark - UIImage Category

@implementation UIImage (URBSegmentedControl)

/**
 UIImage tint category methods originally developed by Matt Gemmell and released under the BSD License: http://mattgemmell.com/license/
 https://github.com/mattgemmell/MGImageUtilities
 */
- (UIImage *)imageTintedWithColor:(UIColor *)color {
	if (color) {
		UIGraphicsBeginImageContextWithOptions([self size], NO, 0.f);
		
		CGRect rect = CGRectZero;
		rect.size = [self size];
		
		[color set];
		UIRectFill(rect);
		
		[self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1.0];
		
		UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return image;
	}
	
	return self;
}

@end

#pragma mark - UIColor Category

@implementation UIColor (URBSegmentedControl)

- (UIColor *)adjustBrightness:(CGFloat)amount {
	float h, s, b, a, w;	
	
    if ([self getHue:&h saturation:&s brightness:&b alpha:&a]) {
		b += (amount-1.0);
        b = MAX(MIN(b, 1.0), 0.0);
        return [UIColor colorWithHue:h saturation:s brightness:b alpha:a];
	}
	else if ([self getWhite:&w alpha:&a]) {
		w += (amount-1.0);
        w = MAX(MIN(w, 1.0), 0.0);
		return [UIColor colorWithWhite:w alpha:a];
	}
	
    return nil;
}

@end
