//
//  FLIRColorizer.h
//  ThermalSDK
//
//  Created by FLIR on 2021-10-27.
//  Copyright © 2021 Teledyne FLIR. All rights reserved.
//

#import "FLIRRenderer.h"

@class FLIRRange;

/**
 *  Protocol for classes colorizing thermal images or streams
 */
@protocol FLIRColorizer<FLIRRenderer>

/**
 *  Autromatic scale
 *
 *  If true rendered images will have scale automatically set based on the min and max values in the image.
 *  @note auto-adjusted scale is disabled by default
 */
@property (nonatomic, assign) BOOL autoScale;

/**
 *  Render scale
 *
 *  If true the scale will be rendered when the image is rendered
 *  @note scale rendering is disabled by default
 */
@property (nonatomic, assign) BOOL renderScale;

/**
 *  Get an image with the scale
 *
 *  @note if scale rendering was disabled during last call to @ref update, the result from this function may be out of sync .
 *  @note For getting rendered image without scale, see @ref getImage
 *  @return Returns an UIImage, or nil if update hasn't been called with scale rendering enabled
 */
- (UIImage * _Nullable)getScaleImage;

/**
 *  Get the range of the scale
 *
 *  If auto scale is on, get the min and max temperature
 *  @return FLIRRange with min and max
 */

- (FLIRRange * _Nullable)getScaleRange;

@end
