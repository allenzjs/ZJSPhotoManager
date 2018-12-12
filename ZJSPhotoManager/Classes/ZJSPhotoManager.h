//
//  ZJSPhotoManager.h
//  Pods-ZJSPhotoManager_Example
//
//  Created by 查俊松 on 2018/12/12.
//

#import <Photos/Photos.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^ZJSSearchPhotosResultHandler)(UIImage *result, NSDictionary *info);
typedef void (^ZJSAddPhotoCompletionHandler)(BOOL finish, NSError *error);
typedef void (^ZJSAddVideoCompletionHandler)(BOOL finish, NSError *error);

@interface ZJSPhotoManager : NSObject

// 查询所有照片（相机胶卷）
+ (void)zjs_searchAllImagesInCameraRollWithResultHandler:(ZJSSearchPhotosResultHandler)resultHandler;
// 查询某个自定义相簿中的所有照片
+ (void)zjs_searchAllImagesInAssetCollection:(NSString *)localizedTitle resultHandler:(ZJSSearchPhotosResultHandler)resultHandler;
// 获得某个自定义相簿（如果不存在，则新建一个自定义相簿）
+ (PHAssetCollection *)zjs_assetCollectionWithLocalizedTitle:(NSString *)localizedTitle;
// 将某个图片存入相机胶卷
+ (void)zjs_addToCameraRollWithImage:(UIImage *)image completionHandler:(ZJSAddPhotoCompletionHandler)completionHandler;
// 将某个图片存入相机胶卷，并且放到指定的自定义相簿中
+ (void)zjs_addToAssetCollection:(NSString *)localizedTitle withImage:(UIImage *)image completionHandler:(ZJSAddPhotoCompletionHandler)completionHandler;
// 将某个视频存入相机胶卷，并且放到指定的自定义相簿中
+ (void)zjs_addToAssetCollection:(NSString *)localizedTitle withVideo:(NSURL *)path completionHandler:(ZJSAddVideoCompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
