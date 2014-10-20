#import "IPVImageScrollView.h"
#import "IPVAutoLayoutUtils.h"

@interface IPVImageScrollView () <UIScrollViewDelegate>

@end

@implementation IPVImageScrollView {
    UIImage *_image;
    UIImageView *_imageView;
    CGSize _lastFrameSize;
}

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.bouncesZoom = YES;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        _image = image;
        _imageView = [[UIImageView alloc] initWithImage:image];
        _imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:_imageView];
        [self addConstraints:IPVPinEdgesToSuperview(_imageView, self)];
    }
    return self;
}

-(void)layoutSubviews
{
    CGSize frameSize = self.frame.size;
    if (!CGSizeEqualToSize(_lastFrameSize, frameSize)) {
        CGSize boundsSize = self.bounds.size;
        CGSize imageSize = _image.size;
        CGFloat xScale = boundsSize.width  / imageSize.width;
        CGFloat yScale = boundsSize.height / imageSize.height;
        CGFloat scale = MIN(xScale, yScale);
        self.minimumZoomScale = scale;
        self.maximumZoomScale = scale * 2;
        // TODO we need to restore the last scale before the size change
        // same with center contentOffset
        self.zoomScale = scale;
        _lastFrameSize = frameSize;
    }

    [super layoutSubviews];
    
    // center image view inside of bounds
    // if it one of its frame dimensions is
    // smaller than the bounds dimensions
    CGSize size = _imageView.frame.size;
    CGSize boundsSize = self.bounds.size;

    CGFloat xInset = (boundsSize.width - size.width) / 2;
    CGFloat yInset = (boundsSize.height - size.height) / 2;
    if (xInset < 0.1) xInset = 0;
    if (yInset < 0.1) yInset = 0;

    UIEdgeInsets contentInset = UIEdgeInsetsMake(yInset, xInset, yInset, xInset);
    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentInset, contentInset)) {
        // this will invalidate the layout and rerun layout (but not constraints)
        // next pass these should be equal
        self.contentInset = contentInset;
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

@end
