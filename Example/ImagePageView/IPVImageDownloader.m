//
//  IPVImageDownloader.m
//  ImagePageView
//
//  Created by Kris Selden on 10/21/14.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import "IPVImageDownloader.h"

@interface IPVImageDownload : NSObject

- (instancetype)initWithSession:(NSURLSession *)session
                       imageURL:(NSURL *)imageURL;

- (void)addProgressHandler:(void (^)(float progress))progressHandler;
- (void)addCompletionHandler:(void (^)(UIImage *image, NSError *error))completionHandler;

@property (readonly, nonatomic) NSURL *location;

@end

@implementation IPVImageDownloader{
    NSURLSession *_session;
    NSMutableDictionary *_downloads;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _session = [NSURLSession sharedSession];
        _downloads = [NSMutableDictionary dictionary];
    }
    return self;
}

-(BOOL)downloadURL:(NSURL *)imageURL
   progressHandler:(void (^)(float progress))progressHandler
 completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler
{
    IPVImageDownload *download = _downloads[imageURL];
    if (!download) {
        download = _downloads[imageURL] = [[IPVImageDownload alloc] initWithSession:_session
                                                                           imageURL:imageURL];
    }
    [download addProgressHandler:progressHandler];
    [download addCompletionHandler:completionHandler];
    return download.location != nil;
}

@end

static const char *countOfBytesReceivedKey = "countOfBytesReceivedKey";
static const char *countOfBytesExpectedToReceiveKey = "countOfBytesExpectedToReceiveKey";

@implementation IPVImageDownload {
    NSURLSession *_session;
    NSURL *_imageURL;
    NSMutableArray *_progressHandlers;
    NSMutableArray *_completionHandlers;
    NSURLSessionTask *_task;
    int64_t _bytesReceived;
    int64_t _bytesExpectedToReceive;
    BOOL _isFlushing;
}

- (instancetype)initWithSession:(NSURLSession *)session
                       imageURL:(NSURL *)imageURL
{
    self = [super init];
    if (self) {
        _session = session;
        _imageURL = imageURL;
        _progressHandlers = [NSMutableArray array];
        _completionHandlers = [NSMutableArray array];
    }
    return self;
}

- (void)addProgressHandler:(void (^)(float progress))progressHandler
{
    NSAssert([NSThread isMainThread], @"addProgressHandler should be called on main");
    if (progressHandler) {
        [_progressHandlers addObject:progressHandler];
    }
}

- (void)addCompletionHandler:(void (^)(UIImage *image, NSError *error))completionHandler
{
    NSAssert([NSThread isMainThread], @"addCompletionHandler should be called on main");
    [_completionHandlers addObject:completionHandler];
    [self resolve];
}

- (void)resolve
{
    NSAssert([NSThread isMainThread], @"resolve should be called on main");
    if (_isFlushing) return;
    if (_location) {
        [self flush:_location error:nil];
        return;
    }
    [self download];
}

- (void)download
{
    if (!_task) {
        _task = [_session downloadTaskWithURL:_imageURL
                            completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                [self downloadComplete:location error:error];
                            }];
        [_task addObserver:self forKeyPath:@"countOfBytesExpectedToReceive" options:NSKeyValueObservingOptionNew context:&countOfBytesExpectedToReceiveKey];
        [_task addObserver:self forKeyPath:@"countOfBytesReceived" options:NSKeyValueObservingOptionNew context:&countOfBytesReceivedKey];
        [_task resume];
    }
}

- (void)downloadComplete:(NSURL *)location
                   error:(NSError *)error
{
    [_task removeObserver:self forKeyPath:@"countOfBytesExpectedToReceive"];
    [_task removeObserver:self forKeyPath:@"countOfBytesReceived"];
    [self flush:location error:error];
}

- (void)flush:(NSURL *)location error:(NSError *)error
{
    _isFlushing = YES;
    void (^flush)(UIImage *image, NSError *error) = ^(UIImage *image, NSError *error){
        _isFlushing = NO;
        for (void (^handler)(UIImage *image, NSError *error) in _completionHandlers) {
            handler(image, error);
        }
        if (error) {
            // retry next time
            _location = nil;
            _task = nil;
        } else {
            _location = location;
        }
        [_progressHandlers removeAllObjects];
        [_completionHandlers removeAllObjects];
    };

    if (error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            flush(nil, error);
        });
    } else {
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0), ^{
            NSError *error;
            NSData *data = [NSData dataWithContentsOfURL:location options:0 error:&error];
            UIImage *image;
            if (error) {
                image = nil;
            } else {
                image = [UIImage imageWithData:data];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                flush(image, error);
            });
        });
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == &countOfBytesExpectedToReceiveKey) {
        NSNumber *num = change[@"new"];
        _bytesExpectedToReceive = num.longLongValue;
    } else if (context == &countOfBytesReceivedKey) {
        NSNumber *num = change[@"new"];
        _bytesReceived = num.longLongValue;
    } else {
        return [super observeValueForKeyPath:keyPath
                                    ofObject:object
                                      change:change
                                     context:context];
    }
    int64_t bytesReceived = _bytesReceived;
    int64_t bytesExpectedToReceive = _bytesExpectedToReceive;
    if (_bytesExpectedToReceive == NSURLSessionTransferSizeUnknown) {
        return;
    }
    float progress = bytesReceived / (float)bytesExpectedToReceive;
    dispatch_async(dispatch_get_main_queue(), ^{
        for (void (^handler)(float progress) in _progressHandlers) {
            handler(progress);
        }
    });
}

@end