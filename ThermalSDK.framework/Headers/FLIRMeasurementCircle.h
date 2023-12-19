//
//  FLIRMeasurementCircle.h
//  FLIR Thermal SDK
//
//  Copyright © 2019 Teledyne FLIR. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>
#import "FLIRMeasurementArea.h"

/**
 *  Defines the circle measurement tool shape.
 *  Circle is described by a surrounding rectangle.
 *  This tool allows to measure temperature in circle area.
 *  It gives the possibility to find area's minimum, maximum and average temperature.
 *  There is functionality to find the exact location for minimum and maximum values.
 */
@interface FLIRMeasurementCircle : FLIRMeasurementArea

/**
 *  Gets x,y positon
 */
- (CGPoint)getPosition;

/**
 * Sets position
 */

- (BOOL)setPosition:(CGPoint)position error:(out NSError * _Nullable *_Nullable)error;

/**
 *  Gets radius
 */
- (int)getRadius;

/**
 * Sets radius
 */
- (BOOL)setRadius: (int)radius error:(out NSError * _Nullable *_Nullable)error;

/**
 *  Sets both position and radius
 */
- (BOOL)setPosition:(CGPoint)position radius:(int)radius error:(out NSError * _Nullable *_Nullable)error;

@end
