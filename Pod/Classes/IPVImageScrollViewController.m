#import "IPVImageScrollViewController.h"
#import "IPVAutoLayoutUtils.h"
#import "IPVImageScrollView.h"

@implementation IPVImageScrollViewController{
    IPVImageScrollView *_imageScrollView;
    UIActivityIndicatorView *_activityIndicatorView;
    UIGestureRecognizer *_zoomToggleGestureRecognizer;
}

+(instancetype)imageScrollViewControllerForKey:(id)key
                                    dataSource:(id<IPVImageScrollViewControllerDataSource>)dataSource
{
    return [[self alloc] initWithKey:key dataSource:dataSource];
}

- (instancetype)initWithKey:(id)key
                 dataSource:(id<IPVImageScrollViewControllerDataSource>)dataSource
{
    self = [super init];
    if (self) {
        _key = key;
        _dataSource = dataSource;
        BOOL isCached = [dataSource
                    imageScrollViewController:self
                    imageForKey:key
                    completionHandler:^(UIImage *image) {
                        [self setImage:image];
                    }];
        if (!isCached) {
            _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _activityIndicatorView.hidesWhenStopped = YES;
            _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = NO;
            UIView *view = self.view;
            [view addSubview:_activityIndicatorView];
            [view addConstraints:IPVCenterInSuperview(_activityIndicatorView, view)];
            [_activityIndicatorView startAnimating];
        }
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    UIView *view = self.view;
    _image = image;
    _imageScrollView = [[IPVImageScrollView alloc] initWithImage:image];
    _imageScrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:_imageScrollView];
    [view addConstraints:IPVPinEdgesToSuperview(_imageScrollView, view)];
    if (_activityIndicatorView) {
        [_activityIndicatorView stopAnimating];
        _imageScrollView.alpha = 0.0;
        [UIView animateWithDuration:0.2 animations:^{
            _imageScrollView.alpha = 1.0;
        }];
    }
}

- (void)toggleZoom:(CGPoint)center
{
    [_imageScrollView toggleZoom:center];
}

@end
