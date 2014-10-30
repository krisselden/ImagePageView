//
//  IPVPhotosDataSource.h
//  ImagePageView
//
//  Created by Kris Selden on 10/21/14.
//  Copyright (c) 2014 Kris Selden. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IPVImagePageViewController.h>

@class IPVPhoto;

@interface IPVPhotosDataSource : NSObject<IPVImagePageViewControllerDataSource>

@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, getter=isFinished) BOOL finished;

@property (nonatomic, readonly) long count;

- (void)loadWithBlock:(void(^)())completion;

- (IPVPhoto *)photoAtIndex:(long)index;
- (IPVPhoto *)photoBefore:(IPVPhoto *)photo;
- (IPVPhoto *)photoAfter:(IPVPhoto *)photo;

- (BOOL)thumbnailForPhoto:(IPVPhoto *)photo
          progressHandler:(void (^)(float progress))progressHandler
        completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler;

- (BOOL)imageForPhoto:(IPVPhoto *)photo
      progressHandler:(void (^)(float progress))progressHandler
    completionHandler:(void (^)(UIImage *image, NSError *error))completionHandler;
@end
