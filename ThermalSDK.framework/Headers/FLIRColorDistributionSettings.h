//
//  FLIRColorDistributionSettings.h
//  ThermalSDK
//
//  Created by FLIR on 2021-09-03.
//  Copyright © 2022 Teledyne FLIR. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 *  Specifies the color distributions used when running the colorizer on an image.
 */
@interface FLIRColorDistributionSettings : NSObject

@end

/**
 *  The color information in the image is distributed linear to the temperature values of the image.
 *
 *  @note The palette colors used for each pixel is mapped in a linear fashion between the min and max temperatures of the image.
 *  Pixels above and below min and max will contain a color defined in the @ref atlas::image::Palette.
 */
@interface FLIRTemperatureLinearSettings : FLIRColorDistributionSettings

@end

/**
 *  The colors are evenly distributed over the existing temperatures of the image and enhance the contrast.
 *
 *  This color distribution can be particularly successful when the image contains few peaks of very low or
 *  high temperature's values.
 */
@interface FLIRHistogramEqualizationSettings : FLIRColorDistributionSettings

@end

/**
 *  The color information in the image is distributed linear to the signal values of the image.
 *
 *  @note The palette colors used for each pixel is mapped in a linear fashion between the min and max signal values of the image. Pixels above and below min and max will contain a color defined in the @ref atlas::image::Palette.
*/
@interface FLIRSignalLinearSettings : FLIRColorDistributionSettings

@end

/**
 *  Specifies parameters for the plateau histogram equalization mode.
 *
 *  The colors are evenly distributed over the existing temperatures of the image and enhance the contrast.
 *  @note This color distribution can be particularly successful when the image contains few peaks
 *  of very low or high temperature's values.
 */
@interface FLIRPlateauHistogramEqSettings : FLIRColorDistributionSettings

/** Limits the maximum slope of the mapping function. */
@property (nonatomic, assign) float maxGain;
/** Limits the population of any single histogram bin. */
@property (nonatomic, assign) float percentPerBin;
/** Increasing values of Linear Percent more accurately preserves the visual representation of an object */
@property (nonatomic, assign) float linearPercent;
/** Determines the percentage of the histogram tails which are not ignored when generating the mapping function.*/
@property (nonatomic, assign) float outlierPercent;
/** Used to adjust the perceived brightness of the image. */
@property (nonatomic, assign) float gamma;

@end

/**
 *  Specifies parameters for the Digital Detail Enhancement (DDE) and Entropy modes.
 *  Entropy modes reserve more shades of gray/colors for areas with more entropy by assigning areas with lower entropy lesser gray shades.
 *
 *  @note In this mode one color might not map to a specific temperature. Which means that the output
 *  scale is not radiometric accurate.
 */
@interface FLIRDDESettings : FLIRPlateauHistogramEqSettings

/** Detail to background ratio. */
@property (nonatomic, assign) float detailToBackground;
/** DDE smoothing factor */
@property (nonatomic, assign) float smoothingFactor;
/** Headroom for detail at dynamic range extremes */
@property (nonatomic, assign) float detailHeadroom;

@end


/**
 *  Specifies parameters for Entropy modes.
 *  Entropy modes reserve more shades of gray/colors for areas with more entropy by assigning areas
 *  with lower entropy lesser gray shades.
 *
 *  @note In this mode one color might not map to a specific temperature. Which means that the output
 *  scale is not radiometric accurate.
 */
@interface FLIREntropySettings : FLIRDDESettings

@end

/**
 *  Specifies parameters for the Adaptive Detail Enhancement (ADE) mode.
 *  Adaptive detail enhancement which is using a edge-preserving and noise-reducing smoothing filter
 *  to enhance the contrast in the image.
 *
 *  @note In this mode one color might not map to a specific temperature. Which means that the
 *  output scale is not radiometric accurate.
 */
@interface FLIRADESettings : FLIRColorDistributionSettings

/** Noise amplification limit (LF) (Low value=Disable this feature) */
@property (nonatomic, assign) float alphaNoise;
/** Edge preserving limit (LF); Too avoid halos around sharp edges (High value=Disable this feature). */
@property (nonatomic, assign) float betaLf;
/** Edge preserving limit (HF); Too avoid halos around sharp edges (High value=Disable this feature). */
@property (nonatomic, assign) float betaHf;
/** LF/HF crossover level; Low value=Only HF enhancement;High value=Only LF enhancement. */
@property (nonatomic, assign) float betaMix;
/** Amount of the high pass filter that should be used. */
@property (nonatomic, assign) float hpBlendingAmount;
/** Low part of the histogram that is discarded. */
@property (nonatomic, assign) float lowLimit;
/** High part of the histogram that is discarded. */
@property (nonatomic, assign) float highLimit;
/** Headroom for details at dynamic range extremes. */
@property (nonatomic, assign) float headRoom;
/** Footroom for details at dynamic range extremes. */
@property (nonatomic, assign) float footRoom;
/** Limits the maximum slope of the mapping function. */
@property (nonatomic, assign) float gain;
/** Linear portion used for mapping the colors. */
@property (nonatomic, assign) float linearMix;

@end

/**
 *  Specifies parameters for the FSX mode.
 *  FSX is using a edge-preserving and noise-reducing smoothing filter
 *  to enhance the contrast in the image.
 */
@interface FLIRFSXSettings : FLIRColorDistributionSettings

/** Maximum allowed difference in the bilateral filtering. */
@property (nonatomic, assign) float sigmaR;
/** The weight factor applied to image details. */
@property (nonatomic, assign) unsigned short alpha;

@end

NS_ASSUME_NONNULL_END
