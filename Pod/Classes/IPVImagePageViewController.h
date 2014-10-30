@import UIKit;

@class IPVImagePageViewController;

@protocol IPVImagePageViewControllerDataSource <NSObject>
- (id)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                 keyBeforeKey:(id)key;

- (id)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                  keyAfterKey:(id)key;

- (BOOL)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                    imageForKey:(id)key
                progressHandler:(void (^)(int64_t bytesReceived, int64_t bytesExpectedToReceive))progressHandler
              completionHandler:(void (^)(UIImage *image))completionHandler;

@optional

- (NSString *)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                          titleForKey:(id)key;
@end

@protocol IPVImagePageViewControllerDelegate <NSObject>

@optional

- (void)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
            willTransitionToKey:(id)key;

- (void)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
             didFinishAnimating:(BOOL)finished
                    previousKey:(id)previousKey
            transitionCompleted:(BOOL)completed;

- (void)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                   didDisappear:(BOOL)animated;

- (void)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                   willAppear:(BOOL)animated;

@end

@interface IPVImagePageViewController : UIViewController

@property(nonatomic, assign) IBOutlet id<IPVImagePageViewControllerDataSource> dataSource;
@property(nonatomic, assign) IBOutlet id<IPVImagePageViewControllerDelegate> delegate;

@property(nonatomic, assign) IBInspectable CGFloat interPageSpacing;

@property(readonly) id key;

@property(readonly) UIImage *image;

- (void)setKey:(id)key
     direction:(UIPageViewControllerNavigationDirection)direction
      animated:(BOOL)animated
    completion:(void (^)(BOOL finished))completion;

@end
