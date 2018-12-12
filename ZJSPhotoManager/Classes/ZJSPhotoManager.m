//
//  ZJSPhotoManager.m
//  Pods-ZJSPhotoManager_Example
//
//  Created by 查俊松 on 2018/12/12.
//

#import "ZJSPhotoManager.h"
#import "ALAssetsLibrary+ZJSUtil.h"

@implementation ZJSPhotoManager

#pragma mark - 查询某个相簿中的所有照片（内部方法）
+ (void)zjs_searchAllImagesInCollection:(PHAssetCollection *)collection resultHandler:(ZJSSearchPhotosResultHandler)resultHandler
{
    // 安全判断
    if (!collection) {
        return;
    }
    // 采取同步获取图片（只获得一次图片）
    PHImageRequestOptions *imageRequestOptions = [[PHImageRequestOptions alloc] init];
    imageRequestOptions.synchronous = YES;
    // 获取这个相簿中的所有图片
    PHFetchResult<PHAsset *> *fetchAssetsResult = [PHAsset fetchAssetsInAssetCollection:collection options:nil];
    // 遍历这个相簿中的所有图片
    for (PHAsset *asset in fetchAssetsResult) {
        // 过滤非图片类型
        if (asset.mediaType != PHAssetMediaTypeImage) continue;
        // 返回原始尺寸
        CGSize targetSize = CGSizeMake(asset.pixelWidth, asset.pixelHeight);
        // 返回图片
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:targetSize contentMode:PHImageContentModeDefault options:imageRequestOptions resultHandler:resultHandler];
    }
}

#pragma mark - 查询所有照片（相机胶卷）
+ (void)zjs_searchAllImagesInCameraRollWithResultHandler:(ZJSSearchPhotosResultHandler)resultHandler
{
    // 请求授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        // 没有获得授权
        if (status != PHAuthorizationStatusAuthorized) return;
        // 授权通过
        dispatch_async(dispatch_get_main_queue(), ^{
            // 获得相机胶卷
            PHFetchResult<PHAssetCollection *> *fetchAssetCollectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in fetchAssetCollectionsResult) {
                // 过滤非相机胶卷
                if (![collection.localizedTitle isEqualToString:@"Camera Roll"]) continue;
                // 查询所有照片（相机胶卷）
                [ZJSPhotoManager zjs_searchAllImagesInCollection:collection resultHandler:resultHandler];
                break;
            }
        });
    }];
}

#pragma mark - 查询某个自定义相簿中的所有照片
+ (void)zjs_searchAllImagesInAssetCollection:(NSString *)localizedTitle resultHandler:(ZJSSearchPhotosResultHandler)resultHandler
{
    // 安全判断
    if (!localizedTitle || !localizedTitle.length) {
        return;
    }
    // 请求授权
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        // 没有获得授权
        if (status != PHAuthorizationStatusAuthorized) return;
        // 授权通过
        dispatch_async(dispatch_get_main_queue(), ^{
            // 获得指定的相簿
            PHFetchResult<PHAssetCollection *> *fetchAssetCollectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
            for (PHAssetCollection *collection in fetchAssetCollectionsResult) {
                // 过滤非指定的相簿
                if (![collection.localizedTitle isEqualToString:localizedTitle]) continue;
                // 查询指定相簿中的所有照片
                [ZJSPhotoManager zjs_searchAllImagesInCollection:collection resultHandler:resultHandler];
                break;
            }
        });
    }];
}

#pragma mark - 获得某个自定义相簿（如果不存在，则新建一个自定义相簿）
+ (PHAssetCollection *)zjs_assetCollectionWithLocalizedTitle:(NSString *)localizedTitle
{
    // 安全判断
    if (!localizedTitle || !localizedTitle.length) {
        return nil;
    }
    // 先查找已存在的相簿中是否有指定的自定义相簿
    PHFetchResult<PHAssetCollection *> *fetchAssetCollectionsResult = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    for (PHAssetCollection *collection in fetchAssetCollectionsResult) {
        if ([collection.localizedTitle isEqualToString:localizedTitle]) {
            // 已存在指定的自定义相簿
            return collection;
        }
    }
    
    // 指定的自定义相簿不存在，则新建一个自定义相簿
    __block NSString *collectionID = nil;
    NSError *error = nil;
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        collectionID = [PHAssetCollectionChangeRequest creationRequestForAssetCollectionWithTitle:localizedTitle].placeholderForCreatedAssetCollection.localIdentifier;
    } error:&error];
    // 判断新建自定义相簿是否成功
    if (error || !collectionID || !collectionID.length) {
        // 新建失败
        return nil;
    } else {
        // 新建成功
        PHAssetCollection *collection = [PHAssetCollection fetchAssetCollectionsWithLocalIdentifiers:@[collectionID] options:nil].lastObject;
        return collection;
    }
}

#pragma mark - 将某个图片存入相机胶卷
+ (void)zjs_addToCameraRollWithImage:(UIImage *)image completionHandler:(ZJSAddPhotoCompletionHandler)completionHandler
{
    // 安全判断
    if (!image || !image.size.width || !image.size.height) {
        return;
    }
    // 系统版本判断，iOS9以下的版本用ALAssetsLibrary，iOS9及以上的版本用PHPhotoLibrary
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
        [[ALAssetsLibrary new] zjs_saveImage:image toAlbum:nil completion:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                // 存储成功
                completionHandler(YES, error);
            } else {
                // 存储失败
                completionHandler(NO, error);
            }
        } failure:^(NSError *error) {
            if (!error) {
                // 存储成功
                completionHandler(YES, error);
            } else {
                // 存储失败
                completionHandler(NO, error);
            }
        }];
    } else {
        // 请求授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 没有获得授权
            if (status != PHAuthorizationStatusAuthorized) {
                completionHandler(NO, nil);
                return;
            }
            // 授权通过
            dispatch_async(dispatch_get_main_queue(), ^{
                // 将某个图片存入相机胶卷
                NSError *error = nil;
                __block PHObjectPlaceholder *createdAsset = nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
                } error:&error];
                if (error || !createdAsset) {
                    // 存储失败
                    completionHandler(NO, error);
                } else {
                    // 存储成功
                    completionHandler(YES, error);
                }
            });
        }];
    }
}

#pragma mark - 将某个图片存入相机胶卷，并且放到指定的自定义相簿中
+ (void)zjs_addToAssetCollection:(NSString *)localizedTitle withImage:(UIImage *)image completionHandler:(ZJSAddPhotoCompletionHandler)completionHandler
{
    // 安全判断
    if (!localizedTitle || !localizedTitle.length || !image || !image.size.width || !image.size.height) {
        return;
    }
    // 系统版本判断，iOS9以下的版本用ALAssetsLibrary，iOS9及以上的版本用PHPhotoLibrary
    if ([UIDevice currentDevice].systemVersion.floatValue < 9.0) {
        [[ALAssetsLibrary new] zjs_saveImage:image toAlbum:localizedTitle completion:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                // 存储成功
                completionHandler(YES, error);
            } else {
                // 存储失败
                completionHandler(NO, error);
            }
        } failure:^(NSError *error) {
            if (!error) {
                // 存储成功
                completionHandler(YES, error);
            } else {
                // 存储失败
                completionHandler(NO, error);
            }
        }];
    } else {
        // 请求授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 没有获得授权
            if (status != PHAuthorizationStatusAuthorized) {
                completionHandler(NO, nil);
                return;
            }
            // 授权通过
            dispatch_async(dispatch_get_main_queue(), ^{
                // 获得指定的自定义相簿（如果不存在，则新建一个自定义相簿）
                PHAssetCollection *collection = [ZJSPhotoManager zjs_assetCollectionWithLocalizedTitle:localizedTitle];
                // 判断获得指定自定义相簿是否成功
                if (!collection) {
                    // 获得指定自定义相簿失败
                    completionHandler(NO, nil);
                    return;
                }
                // 将某个图片存入相机胶卷
                NSError *error = nil;
                __block PHObjectPlaceholder *createdAsset = nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    // 存入相机胶卷
                    createdAsset = [PHAssetCreationRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset;
                } error:&error];
                if (error || !createdAsset) {
                    // 存储失败
                    completionHandler(NO, error);
                    return;
                }
                // 存入指定自定义相簿
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    // 存入指定自定义相簿
                    if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
                        [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] addAssets:@[createdAsset]];
                    }
                    // [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
                } error:&error];
                if (error) {
                    // 存储失败
                    completionHandler(NO, error);
                } else {
                    // 存储成功
                    completionHandler(YES, error);
                }
            });
        }];
    }
}

#pragma mark - 将某个视频存入相机胶卷，并且放到指定的自定义相簿中
+ (void)zjs_addToAssetCollection:(NSString *)localizedTitle withVideo:(NSURL *)path completionHandler:(ZJSAddVideoCompletionHandler)completionHandler
{
    // 安全判断
    if (!localizedTitle || !localizedTitle.length || !path) {
        return;
    }
    // 系统版本判断，iOS9以下的版本用ALAssetsLibrary，iOS9及以上的版本用PHPhotoLibrary
    if ([[[UIDevice currentDevice] systemVersion] compare:@"9.0" options:NSNumericSearch] == NSOrderedAscending) {
        [[ALAssetsLibrary new] zjs_saveVideo:path toAlbum:localizedTitle completion:^(NSURL *assetURL, NSError *error) {
            if (!error) {
                // 存储成功
                completionHandler(YES, error);
            } else {
                // 存储失败
                completionHandler(NO, error);
            }
        } failure:^(NSError *error) {
            if (!error) {
                // 存储成功
                completionHandler(YES, error);
            } else {
                // 存储失败
                completionHandler(NO, error);
            }
        }];
    } else {
        // 请求授权
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            // 没有获得授权
            if (status != PHAuthorizationStatusAuthorized) {
                completionHandler(NO, nil);
                return;
            }
            // 授权通过
            dispatch_async(dispatch_get_main_queue(), ^{
                // 获得指定的自定义相簿（如果不存在，则新建一个自定义相簿）
                PHAssetCollection *collection = [ZJSPhotoManager zjs_assetCollectionWithLocalizedTitle:localizedTitle];
                // 判断获得指定自定义相簿是否成功
                if (!collection) {
                    // 获得指定自定义相簿失败
                    completionHandler(NO, nil);
                    return;
                }
                // 将某个视频存入相机胶卷
                NSError *error = nil;
                __block PHObjectPlaceholder *createdAsset = nil;
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    // 存入相机胶卷
                    createdAsset = [PHAssetCreationRequest creationRequestForAssetFromVideoAtFileURL:path].placeholderForCreatedAsset;
                } error:&error];
                if (error || !createdAsset) {
                    // 存储失败
                    completionHandler(NO, error);
                    return;
                }
                // 存入指定自定义相簿
                [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
                    // 存入指定自定义相簿
                    if ([collection canPerformEditOperation:PHCollectionEditOperationAddContent]) {
                        [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] addAssets:@[createdAsset]];
                    }
                    // [[PHAssetCollectionChangeRequest changeRequestForAssetCollection:collection] insertAssets:@[createdAsset] atIndexes:[NSIndexSet indexSetWithIndex:0]];
                } error:&error];
                if (error) {
                    // 存储失败
                    completionHandler(NO, error);
                } else {
                    // 存储成功
                    completionHandler(YES, error);
                }
            });
        }];
    }
}

@end
