//
//  ALAssetsLibrary+ZJSUtil.h
//  Pods-ZJSPhotoManager_Example
//
//  Created by 查俊松 on 2018/12/12.
//

#import <AssetsLibrary/AssetsLibrary.h>

NS_ASSUME_NONNULL_BEGIN

@interface ALAssetsLibrary (ZJSUtil)

/*! Write the image data to the assets library (camera roll).
 *
 * \param image The target image to be saved
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to write the image data to the assets library (camera roll)
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
- (void)zjs_saveImage:(UIImage *)image
              toAlbum:(NSString *)albumName
           completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
              failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! write the video to the assets library (camera roll).
 *
 * \param videoUrl The target video to be saved
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed to write the image data to the assets library (camera roll)
 * \param failure block to be executed when failed to add the asset to the custom photo album
 */
- (void)zjs_saveVideo:(NSURL *)videoUrl
              toAlbum:(NSString *)albumName
           completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
              failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! Write the image data with meta data to the assets library (camera roll).
 *
 * \param imageData The image data to be saved
 * \param albumName Custom album name
 * \param metadata Meta data for image
 * \param completion Block to be executed when succeed to write the image data
 * \param failure block to be executed when failed to add the asset to the custom photo album
 */
- (void)zjs_saveImageData:(NSData *)imageData
                  toAlbum:(NSString *)albumName
                 metadata:(NSDictionary *)metadata
               completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                  failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! Write the asset to the assets library (camera roll).
 *
 * \param assetURL The asset URL
 * \param albumName Custom album name
 * \param failure Block to be executed when failed to add the asset to the custom photo album
 */
- (void)zjs_addAssetURL:(NSURL *)assetURL
                toAlbum:(NSString *)albumName
             completion:(ALAssetsLibraryWriteImageCompletionBlock)completion
                failure:(ALAssetsLibraryAccessFailureBlock)failure;

/*! Loads assets w/ desired property from the assets group (album)
 *
 * \param property   Property for the asset, refer to ALAsset.h, if not offered, just return instances of ALAsset
 * \param albumName  Custom album name
 * \param completion Block to be executed when succeed or failed to load assets from target album
 */
- (void)zjs_loadAssetsForProperty:(NSString *)property
                        fromAlbum:(NSString *)albumName
                       completion:(void (^)(NSMutableArray *array, NSError *error))completion;

/*! Loads assets from the assets group (album)
 *
 * \param albumName Custom album name
 * \param completion Block to be executed when succeed or failed to load images from target album
 */
- (void)zjs_loadImagesFromAlbum:(NSString *)albumName
                     completion:(void (^)(NSMutableArray *images, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
