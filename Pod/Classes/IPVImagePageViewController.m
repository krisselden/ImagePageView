#import "IPVImagePageViewController.h"
#import "IPVImageScrollViewController.h"
#import "IPVAutoLayoutUtils.h"

@interface IPVImagePageViewController () <UIPageViewControllerDataSource, UIPageViewControllerDelegate,IPVImageScrollViewControllerDataSource>
@end

@implementation IPVImagePageViewController{
    UIPageViewController *_pageViewController;
    IPVImageScrollViewController *_imageScrollViewController;
    BOOL _interactivePopGestureRecognizerWasEnabled;
    UIBarButtonItem *_rightButtonItem;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
    
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    return self;
}

// TODO tap gesture recognizer for toggling nav bar and status bar
// TODO double tap gesture recognizer for zoom to point

- (UIPageViewController *)pageViewController
{
    if (!_pageViewController) {
        _pageViewController = [[UIPageViewController alloc]
                               initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll
                               navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal
                               options:@{
                                         UIPageViewControllerOptionInterPageSpacingKey:@(self.interPageSpacing)
                                         }];
        _pageViewController.delegate = self;
        _pageViewController.dataSource = self;
        [self addChildViewController:_pageViewController];
    }
    return _pageViewController;
}

- (void)viewDidLoad
{
    [self addViewForPageViewController];
    [super viewDidLoad];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.delegate imagePageViewController:self didDismissController:YES];
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
        _rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareImage)];
        self.navigationItem.rightBarButtonItem = _rightButtonItem;
    }
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

-(void)addViewForPageViewController
{
    UIPageViewController *pageViewController = self.pageViewController;
    UIView *view = self.view;
    UIView *pageView = pageViewController.view;
    pageView.translatesAutoresizingMaskIntoConstraints = NO;
    [view addSubview:pageView];
    [view addConstraints:IPVPinEdgesToSuperview(pageView, view)];
    [pageViewController willMoveToParentViewController:self];
}

- (void)setKey:(id)key
     direction:(UIPageViewControllerNavigationDirection)direction
      animated:(BOOL)animated
    completion:(void (^)(BOOL))completion
{
    NSLog(@"%s key=%@",__PRETTY_FUNCTION__, key);
    IPVImageScrollViewController * imageScrollViewController = [self imageScrollViewControllerForKey:key];
    [self setImageScrollViewController:imageScrollViewController];
    [self.pageViewController setViewControllers:@[imageScrollViewController]
                                      direction:direction
                                       animated:animated
                                     completion:completion];
}

- (IPVImageScrollViewController *)imageScrollViewControllerForKey:(id)key
{
    return [IPVImageScrollViewController
            imageScrollViewControllerForKey:key
            dataSource:self];
}

- (void)setImage:(UIImage *)image
{
    _image = image;
    _rightButtonItem.enabled = image ? YES : NO;
}

- (void)setImageScrollViewController:(IPVImageScrollViewController *)imageScrollViewController
{
    _imageScrollViewController = imageScrollViewController;
    id oldKey = _key;
    _key = imageScrollViewController.key;
    [self setImage:imageScrollViewController.image];
    NSLog(@"%s oldKey%@ newKey=%@",__PRETTY_FUNCTION__, oldKey, _key);
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
            // TODO display progress in nav bar with bar style progress view
            progressHandler:nil
            completionHandler:^void(UIImage *image){
                completionHandler(image);
                // if current key
                if (key == _key) {
                    [self setImage:image];
                }
            }];
}

#pragma mark - UIPageViewControllerDataSource

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    IPVImageScrollViewController *imageScrollViewController =
    (IPVImageScrollViewController *)viewController;
    id key = imageScrollViewController.key;
    id keyAfter = [self.dataSource imagePageViewController:self
                                               keyAfterKey:key];
    NSLog(@"%s key=%@ keyAfter=%@",__PRETTY_FUNCTION__, key, keyAfter);
    return keyAfter ? [self imageScrollViewControllerForKey:keyAfter] : nil;
}

-(UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    IPVImageScrollViewController *imageScrollViewController =
    (IPVImageScrollViewController *)viewController;
    id key = imageScrollViewController.key;
    id keyBefore = [self.dataSource imagePageViewController:self
                                               keyBeforeKey:key];
    NSLog(@"%s key=%@ keyBefore=%@",__PRETTY_FUNCTION__, key, keyBefore);
    return keyBefore ? [self imageScrollViewControllerForKey:keyBefore] : nil;
}

#pragma mark - UIPageViewControllerDelegate

-(void)pageViewController:(UIPageViewController *)pageViewController
willTransitionToViewControllers:(NSArray *)pendingViewControllers
{
    IPVImageScrollViewController *pendingViewController =
    (IPVImageScrollViewController *)pendingViewControllers[0];
    id pendingKey = pendingViewController.key;
    NSLog(@"%s pendingKey=%@",__PRETTY_FUNCTION__, pendingKey);
    [self.delegate imagePageViewController:self willTransitionToKey:pendingKey];
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
        NSLog(@"%s previousKey=%@ complete %@",__PRETTY_FUNCTION__, previousKey, viewController.key);
        [self setImageScrollViewController:viewController];
    } else {
        NSLog(@"%s previousKey=%@ incomplete",__PRETTY_FUNCTION__, previousKey);
    }
    [self.delegate imagePageViewController:self
                        didFinishAnimating:finished
                               previousKey:previousKey
                       transitionCompleted:completed];
}

@end
