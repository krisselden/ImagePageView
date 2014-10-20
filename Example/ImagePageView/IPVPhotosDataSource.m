//
//  IPVPhotosDataSource.m
//  ImagePageView
//
//  Created by Kris Selden on 10/21/14.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import "IPVPhotosDataSource.h"
#import "IPVPhoto.h"
#import "IPVImageDownloader.h"

@implementation IPVPhotosDataSource {
    IPVImageDownloader *_imageDownloader;
    NSMutableArray *_photos;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageDownloader = [[IPVImageDownloader alloc] init];
        _photos = [NSMutableArray array];
    }
    return self;
}

- (long)count
{
    return (long)_photos.count;
}

- (void)loadWithBlock:(void(^)())completion
{
    if (_loading || _finished) {
        return;
    }
    _loading = YES;
    UIApplication* app = [UIApplication sharedApplication];
    app.networkActivityIndicatorVisible = YES;
    [IPVPhoto getPhotos:^(NSArray *photos, NSError *error) {
        _loading = NO;
        _finished = YES;
        app.networkActivityIndicatorVisible = NO;
        if (error) {
            NSLog(@"Flickr getRecent failed: %@", [error localizedDescription]);
        } else {
            [_photos addObjectsFromArray:photos];
        }
        completion();
    }];
}

- (IPVPhoto *)photoAtIndex:(long)index
{
    return _photos[index];
}

- (IPVPhoto *)photoBefore:(IPVPhoto *)photo
{
    long beforeIndex = photo.index - 1;
    if (beforeIndex >= 0) {
        return _photos[beforeIndex];
    }
    return nil;
}

- (IPVPhoto *)photoAfter:(IPVPhoto *)photo
{
    long afterIndex = photo.index + 1;
    if (afterIndex < _photos.count) {
        return _photos[afterIndex];
    }
    return nil;
}

- (BOOL)thumbnailForPhoto:(IPVPhoto *)photo
          progressHandler:(void (^)(int64_t bytesReceived, int64_t bytesExpectedToReceive))progressHandler
        completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler
{
    return [_imageDownloader downloadURL:photo.thumbnailURL
                         progressHandler:progressHandler
                       completionHandler:completionHandler];
}

- (BOOL)imageForPhoto:(IPVPhoto *)photo
      progressHandler:(void (^)(int64_t bytesReceived, int64_t bytesExpectedToReceive))progressHandler
    completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler
{
    return [_imageDownloader downloadURL:photo.photoURL
                         progressHandler:progressHandler
                       completionHandler:completionHandler];
}

#pragma mark - IPVImagePageViewControllerDataSource

- (id)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                 keyBeforeKey:(id)key
{
    return [self photoBefore:key];
}

- (id)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                  keyAfterKey:(id)key
{
    return [self photoAfter:key];
}

- (BOOL)imagePageViewController:(IPVImagePageViewController *)imagePageViewController
                    imageForKey:(id)key
                progressHandler:(void (^)(int64_t bytesReceived, int64_t bytesExpectedToReceive))progressHandler
              completionHandler:(void (^)(UIImage *image))completionHandler
{
    return [self imageForPhoto:key
               progressHandler:progressHandler completionHandler:^(UIImage *image, NSError *error) {
        if (error) {
            NSLog(@"Failed to load image: %@", [error localizedDescription]);
        }
        completionHandler(image);
    }];
}

-(NSString *)imagePageViewController:(IPVImagePageViewController *)imagePageViewController titleForKey:(id)key
{
    IPVPhoto *photo = key;
    return [NSString stringWithFormat:@"%ld of %ld", photo.index+1, self.count];
}

@end
