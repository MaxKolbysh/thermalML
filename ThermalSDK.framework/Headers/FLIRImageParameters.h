//
//  FLIRImageParameters.h
//  FLIR Thermal SDK
//
//  Copyright © 2019 Teledyne FLIR. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLIRThermalValue.h"

/** FLIRImageParameters */
@interface FLIRImageParameters : NSObject

/** Gets or sets the default emissivity for the IR Image. */
@property (nonatomic, readwrite) float emissivity;
/** Gets or sets the distance from camera to focused object. */
@property (nonatomic, readwrite) float objectDistance;
/** Gets or sets the reflected temperature. */
@property (nonatomic, readwrite, nonnull) FLIRThermalValue* reflectedTemperature;
/** Gets or sets the atmospheric temperature. */
@property (nonatomic, readwrite, nonnull) FLIRThermalValue* atmosphericTemperature;
/** Gets or sets the external optics temperature. */
@property (nonatomic, readwrite, nonnull) FLIRThermalValue* externalOpticsTemperature;
/** Gets or sets the external optics transmission. */
@property (nonatomic, readwrite) float externalOpticsTransmission;
/** Gets or sets the atmospheric transmission. */
@property (nonatomic, readwrite) float transmission;
/** Gets or sets the relative humidity (0.0 - 1.0). */
@property (nonatomic, readwrite) float relativeHumidity;

@end
