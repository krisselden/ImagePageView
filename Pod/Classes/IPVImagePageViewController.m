#import "IPVImagePageViewController.h"
#import "IPVImageScrollViewController.h"
#import "IPVAutoLayoutUtils.h"

@interface IPVImagePageViewController () <UIPageViewControllerDataSource,
                                          UIPageViewControllerDelegate,
                                          IPVImageScrollViewControllerDataSource>

@property (nonatomic, readonly) UIPageViewController *pageViewController;
@property (nonatomic, readonly) UITapGestureRecognizer *toggleControlsGestureRecognizer;
@property (nonatomic, readonly) UITapGestureRecognizer *toggleZoomGestureRecognizer;

@end

@implementation IPVImagePageViewController{
    UIPageViewController *_pageViewController;
    IPVImageScrollViewController *_imageScrollViewController;
    BOOL _interactivePopGestureRecognizerWasEnabled;
    UITapGestureRecognizer *_toggleControlsGestureRecognizer;
    UITapGestureRecognizer *_toggleZoomGestureRecognizer;
    UIProgressView *_progressView;
    UIColor *_backgroundColor;
    BOOL _prefersStatusBarHidden;
    BOOL _controlsHidden;
    BOOL _progressActive;
}

- (BOOL)prefersStatusBarHidden
{
    if (_prefersStatusBarHidden) {
        return YES;
    }
    return [super prefersStatusBarHidden];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation
{
    return UIStatusBarAnimationFade;
}

- (BOOL)automaticallyAdjustsScrollViewInsets
{
    return NO;
}

- (UIPageViewController *)pageViewController
{
    if (!_pageViewController) {
        _pageViewController =
        [[UIPageViewController alloc]
         initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
         navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
         options:@{
                   UIPageViewControllerOptionInterPageSpacingKey:@(self.interPageSpacing)
                   }];
    }
    return _pageViewController;
}

- (UITapGestureRecognizer *)toggleControlsGestureRecognizer
{
    if (!_toggleControlsGestureRecognizer) {
        _toggleControlsGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleControls)];
        _toggleControlsGestureRecognizer.numberOfTapsRequired = 1;
    }
    return _toggleControlsGestureRecognizer;
}

- (UITapGestureRecognizer *)toggleZoomGestureRecognizer
{
    if (!_toggleZoomGestureRecognizer) {
        _toggleZoomGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleZoom)];
        _toggleZoomGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _toggleZoomGestureRecognizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self addPageViewController];
    [self addGestureRecognizers];
    [self addActionButton];
    [self addProgressView];
}

- (void)addPageViewController
{
    UIPageViewController *pageViewController = self.pageViewController;
    pageViewController.delegate = self;
    pageViewController.dataSource = self;
    [self addChildViewController:pageViewController];
    
    UIView *view = self.view;
    UIView *pageView = pageViewController.view;
    pageView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:pageView];
    [view addConstraints:IPVPinEdgesToSuperview(pageView, view)];

    [pageViewController didMoveToParentViewController:self];
}

- (void)addGestureRecognizers
{
    UIGestureRecognizer *toggleControls = self.toggleControlsGestureRecognizer;
    UIGestureRecognizer *toggleZoom = self.toggleZoomGestureRecognizer;
    UIView *view = self.view;
    
    [toggleControls requireGestureRecognizerToFail:toggleZoom];
    [view addGestureRecognizer:toggleControls];
    [view addGestureRecognizer:toggleZoom];
}

- (void)addActionButton
{
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareImage)];
    rightButton.enabled = _image ? YES : NO;
    self.navigationItem.rightBarButtonItem = rightButton;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.delegate respondsToSelector:@selector(imagePageViewController:willAppear:)]){
        [self.delegate imagePageViewController:self willAppear:animated];
    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if ([self.delegate respondsToSelector:@selector(imagePageViewController:didDisappear:)]){
        [self.delegate imagePageViewController:self didDisappear:animated];
    }
}

-(void)willMoveToParentViewController:(UIViewController *)parent
{
    [super willMoveToParentViewController:parent];
    UINavigationController *navigationController = self.navigationController;
    if (navigationController && self.parentViewController == navigationController) {
        navigationController.interactivePopGestureRecognizer.enabled = _interactivePopGestureRecognizerWasEnabled;
    }
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    [super didMoveToParentViewController:parent];
    UINavigationController *navigationController = self.navigationController;
    if (parent && parent == navigationController) {
        _interactivePopGestureRecognizerWasEnabled = navigationController.interactivePopGestureRecognizer.enabled;
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

-(void)addProgressView
{
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.translatesAutoresizingMaskIntoConstraints = NO;
    progressView.hidden = NO;
    progressView.alpha = 0;
    [self.view addSubview:progressView];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:progressView
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.topLayoutGuide
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1
                                                              constant:0],
                                IPVEqualsAttribute(progressView, self.view, NSLayoutAttributeRight),
                                IPVEqualsAttribute(progressView, self.view, NSLayoutAttributeLeft)
                                ]];
    _progressView = progressView;
}

-(void)toggleControls
{
    UINavigationController *navigationController = self.navigationController;
    if (navigationController)
    {
        if (_controlsHidden) {
            _controlsHidden = NO;
            _prefersStatusBarHidden = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            [navigationController setNavigationBarHidden:NO animated:NO];
            navigationController.navigationBar.alpha = 0;
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                             animations:^{
                                 navigationController.navigationBar.alpha = 1;
                                 self.view.backgroundColor = _backgroundColor;
                             }];
        } else {
            _controlsHidden = YES;
            // stash background color
            _backgroundColor = self.view.backgroundColor;
            _prefersStatusBarHidden = YES;
            [self setNeedsStatusBarAppearanceUpdate];
            [UIView animateWithDuration:UINavigationControllerHideShowBarDuration
                             animations:^{
                                 navigationController.navigationBar.alpha = 0;
                                 [navigationController setNavigationBarHidden:YES animated:NO];
                                 self.view.backgroundColor = [UIColor blackColor];
                             }];
        }
        [self updateActivityIndicatorViewStyles];
    }
}

-(void)toggleZoom
{
    CGPoint location = [_toggleZoomGestureRecognizer locationInView:_imageScrollViewController.view];
    [_imageScrollViewController toggleZoom:location];
}

-(void)shareImage
{
    if (_image) {
        UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_image] applicationActivities:nil];
        [self presentViewController:activityViewController
                           animated:YES
                         completion:^{}];
    }
}

- (void)setKey:(id)key
     direction:(UIPageViewControllerNavigationDirection)direction
      animated:(BOOL)animated
    completion:(void (^)(BOOL))completion
{
    IPVImageScrollViewController * imageScrollViewController = [self imageScrollViewControllerForKey:key];
    [self setImageScrollViewController:imageScrollViewController];
    [self.pageViewController setViewControllers:@[imageScrollViewController]
                                      direction:direction
                                       animated:animated
                                     completion:completion];
}

- (IPVImageScrollViewController *)imageScrollViewControllerForKey:(id)key
{
    IPVImageScrollViewController *imageScrollViewController = [IPVImageScrollViewController imageScrollViewControllerForKey:key
                                                                                                                 dataSource:self];
    [self updateActivityIndicatorViewStyleFor:imageScrollViewController];
    return imageScrollViewController;
}

- (void)updateActivityIndicatorViewStyles
{
    for (IPVImageScrollViewController *viewController in _pageViewController.viewControllers) {
        [self updateActivityIndicatorViewStyleFor:viewController];
    }
}

- (void)updateActivityIndicatorViewStyleFor:(IPVImageScrollViewController *)imageScrollViewController
{
    if (imageScrollViewController.activityIndicatorView) {
        if (_controlsHidden) {
            imageScrollViewController.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        } else {
            imageScrollViewController.activityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
        }
    }
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    self.navigationItem.rightBarButtonItem.enabled = image ? YES : NO;
}

- (void)hideProgressWithAnimation:(BOOL)animated
{
    if (_progressView && _progressActive) {
        _progressActive = NO;
        [UIView
         animateWithDuration: animated ? 0.5 : 0
         delay:0
         options:UIViewAnimationOptionBeginFromCurrentState
         animations:^{
             _progressView.alpha = 0;
         }
         completion:^(BOOL finished) {
             if (finished) {
                 _progressView.progress = 0;
                 _progressView.hidden = YES;
             }
         }];
    }
}

- (void)showProgress:(float)progress
{
    if (_progressView) {
        if (_progressActive) {
            [_progressView setProgress:progress animated:YES];
        } else {
            // do 0 duration animation to interrupt possible
            // fade out animation
            [UIView
             animateWithDuration:0
             delay:0
             options:UIViewAnimationOptionBeginFromCurrentState
             animations:^{
                 _progressView.alpha = 1;
             }
             completion:^(BOOL finished) {
                 if (finished) {
                     _progressActive = YES;
                     _progressView.hidden = NO;
                     _progressView.progress = progress;
                 }
             }];
        }
    }
}

- (void)setImageScrollViewController:(IPVImageScrollViewController *)imageScrollViewController
{
    _imageScrollViewController = imageScrollViewController;
    _key = imageScrollViewController.key;
    [self setImage:imageScrollViewController.image];
    [self hideProgressWithAnimation:NO];
    if (self.navigationItem) {
        NSString *title;
        if ([self.dataSource respondsToSelector:@selector(imagePageViewController:titleForKey:)]) {
            title = [self.dataSource imagePageViewController:self titleForKey:_key];
        } else {
            title = @"";
        }
        self.navigationItem.title = title;
    }
}

#pragma mark - IPVImageScrollViewControllerDataSource

- (BOOL)imageScrollViewController:(IPVImageScrollViewController *)imageScrollViewController
                      imageForKey:(id)key
                completionHandler:(void (^)(UIImage *image))completionHandler
{
    return [self.dataSource
            imagePageViewController:self
            imageForKey:key
            progressHandler:^(float progress){
                // if current key
                if (_key == key) {
                    [self showProgress:progress];
                }
            }
            completionHandler:^void(UIImage *image){
                completionHandler(image);
                // if current key
                if (_key == key) {
                    [self setImage:image];
                    [self hideProgressWithAnimation:YES];
                }
            }];
}

#pragma mark - UIPageViewControllerDataSource

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
      viewControllerAfterViewController:(UIViewController *)viewController
{
    IPVImageScrollViewController *imageScrollViewController =
    (IPVImageScrollViewController *)viewController;
    id key = imageScrollViewController.key;
    id keyAfter = [self.dataSource imagePageViewController:self
                                               keyAfterKey:key];
    return keyAfter ? [self imageScrollViewControllerForKey:keyAfter] : nil;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController
     viewControllerBeforeViewController:(UIViewController *)viewController
{
    IPVImageScrollViewController *imageScrollViewController =
    (IPVImageScrollViewController *)viewController;
    id key = imageScrollViewController.key;
    id keyBefore = [self.dataSource imagePageViewController:self
                                               keyBeforeKey:key];
    return keyBefore ? [self imageScrollViewControllerForKey:keyBefore] : nil;
}

#pragma mark - UIPageViewControllerDelegate

-(void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    IPVImageScrollViewController *pendingViewController =
    (IPVImageScrollViewController *)pendingViewControllers[0];
    id pendingKey = pendingViewController.key;
    if ([self.delegate respondsToSelector:@selector(imagePageViewController:willTransitionToKey:)]) {
        [self.delegate imagePageViewController:self willTransitionToKey:pendingKey];
    }
}

-(void)pageViewController:(UIPageViewController *)pageViewController
       didFinishAnimating:(BOOL)finished
  previousViewControllers:(NSArray *)previousViewControllers
      transitionCompleted:(BOOL)completed
{
    IPVImageScrollViewController *previousViewController =
    (IPVImageScrollViewController *)previousViewControllers[0];
    id previousKey = previousViewController.key;
    if (completed) {
        IPVImageScrollViewController *viewController =
        (IPVImageScrollViewController *)pageViewController.viewControllers[0];
        [self setImageScrollViewController:viewController];
    }
    if ([self.delegate respondsToSelector:@selector(imagePageViewController:didFinishAnimating:previousKey:transitionCompleted:)]) {
        [self.delegate imagePageViewController:self
                            didFinishAnimating:finished
                                   previousKey:previousKey
                           transitionCompleted:completed];
    }
}

@end
