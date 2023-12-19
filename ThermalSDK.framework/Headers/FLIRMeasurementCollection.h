//
//  MeasurementCollection.h
//  FLIR Thermal SDK
//
//  Copyright © 2019 Teledyne FLIR. All rights reserved.
//

#import "FLIRMeasurementSpot.h"
#import "FLIRMeasurementRectangle.h"
#import "FLIRMeasurementCircle.h"
#import "FLIRMeasurementLine.h"
#import "FLIRMeasurementDelta.h"
#import "FLIRMeasurementReference.h"

/**
 *  Container for a different type of MeasurementShapes.
 *  It provides access to all measurements added to an image.
 *  It also allows to add a new measurements to an existing image.
 *  The collection is obtained FLIRThermalImage.Measurements.
 */
@interface FLIRMeasurementCollection : NSObject

/**
 *  Gets all measurement circles
 */
- (NSArray<FLIRMeasurementCircle *> * _Nonnull)getAllCircles;

/**
 *  Gets all measurement lines
 */
- (NSArray<FLIRMeasurementLine *> * _Nonnull)getAllLines;

/**
 *  Gets all measurement rectangles
 */
- (NSArray<FLIRMeasurementRectangle *> * _Nonnull)getAllRectangles;

/**
 *  Gets all measurement spots
 */
- (NSArray<FLIRMeasurementSpot *> * _Nonnull)getAllSpots;

/**
 *  Gets all measurement deltas
 */
- (NSArray<FLIRMeasurementDelta *> * _Nonnull)getAllDeltas;

/**
 *  Gets all measurement references
 */
- (NSArray<FLIRMeasurementReference *> * _Nonnull)getAllReferences;

/**
 *  Adds a new MeasurementSpot to the collection.
 *
 *  @param point The location of the spot.
 *
 *  @return The MeasurementSpot object added to the collection.
 */
- (FLIRMeasurementSpot * _Nullable)addSpot:(CGPoint)point
                                     error:(out NSError * _Nullable * _Nullable)error;


/**
 *  Adds a new MeasurementRectangle to the collection.
 *
 *  @param rect The MeasurementRectangles position and size
 *  @return FLIRMeasurementRectangle
 */
- (FLIRMeasurementRectangle * _Nullable)addRectangle:(CGRect)rect
                                               error:(out NSError * _Nullable * _Nullable)error;


/**
 *  Adds a new MeasurementCircle to the collection.
 *
 *  @param position Center position of the Circle
 *  @param radius Radius of the circle
 *  @return FLIRMeasurementCircle
 */
- (FLIRMeasurementCircle * _Nullable)addCircle:(CGPoint)position
                                        radius:(int)radius
                                         error:(out NSError * _Nullable * _Nullable)error;


/**
 *  Adds a new MeasurementLine to the collection.
 *
 *  @param y y position of the line
 *  @return FLIRMeasurementLine
 */
- (FLIRMeasurementLine * _Nullable)addHorizontalLine:(int)y
                                               error:(out NSError * _Nullable * _Nullable)error;

/**
 *  Adds a new MeasurementLine to the collection.
 *
 *  @param x x position of the line
 *  @return FLIRMeasurementLine
 */
- (FLIRMeasurementLine * _Nullable)addVerticalLine:(int)x
                                             error:(out NSError * _Nullable * _Nullable)error;

/**
 *  Adds a new MeasurementLine to the collection.
 *
 *  @param from starting point
 *  @param to ending point
 *  @return FLIRMeasurementLine
 */
- (FLIRMeasurementLine * _Nullable)addLineFrom:(CGPoint)start
                                            to:(CGPoint)end
                                         error:(out NSError * _Nullable * _Nullable)error;

/**
 *  Adds a new MeasurementDelta to the collection
 *  @param member1
 *  @param member1DeltaValueType
 *  @param member2
 *  @param member2DeltaValueType
 *  @return FLIRMeasurementDelta
 */
- (FLIRMeasurementDelta * _Nullable)addMeasurementDeltaMember1:(FLIRMeasurementShape * _Nonnull)member1
                                              member1DeltaType:(DeltaMemberValueType)member1DeltaValueType
                                                       member2:(FLIRMeasurementShape * _Nonnull)member2
                                              member2DeltaType:(DeltaMemberValueType)member2DeltaValueType
                                                         error:(out NSError * _Nullable * _Nullable)error;

/**
 *  Adds a new MeasurementReference to the collection
 *  @param value the thermal alue for the reference
 *  @return FLIRMeasurementReference
 */
- (FLIRMeasurementReference * _Nullable)addReference:(FLIRThermalValue * _Nonnull)value
                                               error:(out NSError * _Nullable * _Nullable)error;

/**
 *  Removes the specified measurement shape from the collection.
 *
 *  @param shape The Measurement shape (line, spot, rectangle or circle)
 *  @return true if shape removed (i.e. the shape was in the collection)
 */
- (BOOL)remove:(FLIRMeasurementShape * _Nonnull)shape
         error:(out NSError * _Nullable * _Nullable)error;
@end
