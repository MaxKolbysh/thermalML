//
//  FLIRStreamer.h
//  ThermalSDK
//
//  Created by FLIR on 2021-10-12.
//  Copyright © 2021 Teledyne FLIR. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLIRRendererImpl.h"
#import "FLIRColorizer.h"
#import "FLIRCamera.h"

@class FLIRStream;
@class FLIRThermalImage;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Streamer class
 */
@interface FLIRStreamer : FLIRRendererImpl

@end

/**
 *  Streamer class for thermal data
 */
@interface FLIRThermalStreamer : FLIRStreamer<FLIRColorizer>

/**
 *  Create a thermal streamer on a stream
 *
 *  @param stream the stream to be streamed
 *
 *  The stream should contain thermal data. This will also contain a colorizer to provide a visual image
 *  from the thermal stream.
 */
- (instancetype)initWithStream:(FLIRStream *)stream;

/**
 *  Create a thermal streamer on a stream
 *
 *  @param stream the stream to be streamed
 *  @param streamingOptions options for streaming, currently the only option is STREAMING_NO_OPENGL
 *     which creates a pipeline using only CPU filters, avoiding openGL rendering
 *
 *  The stream should contain thermal data. This will also contain a colorizer to provide a visual image
 *  from the thermal stream.
 */
- (instancetype)initWithStream:(FLIRStream *)stream options: (StreamingOptions)streamingOptions;

/**
 *  call a function with a @ref FLIRThermalImage from the stream
 *
 *  @param imageBlock a block with an image parameter
 */
- (void)withThermalImage:(void (^)(FLIRThermalImage *))imageBlock;

@end

/**
 *  Streamer class for visual data
 */
@interface FLIRVisualStreamer : FLIRStreamer
/**
 *  Create a visual streamer on a stream
 *
 *  @param stream the stream to be streamed
 *
 *  The stream should contain visual data.
 */
- (instancetype)initWithStream:(FLIRStream *)stream;

@end

NS_ASSUME_NONNULL_END
