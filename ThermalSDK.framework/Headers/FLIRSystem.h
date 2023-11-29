//
//  FLIRSystem.h
//  ThermalSDK
//
//  Created by FLIR on 2020-07-02.
//  Copyright © 2020 Teledyne FLIR. All rights reserved.
//

#import <Foundation/Foundation.h>

/** system parameters for the camera */
@interface FLIRSystem : NSObject

/** get the a flag indicating the system is running */
- (BOOL) getSystemUp;
/** get the date and time for the camera */
- (NSDateComponents* _Nullable)getTime;
/** get the time zone name for the camera */
- (NSString* _Nullable)getTimeZoneName;
/** set the date and time for the camera (note that some cameras do not respect setting the time's seconds and arbitrary set them to 0)*/
- (BOOL)setTime:(NSDateComponents* _Nonnull)dateComponents error:(out NSError * _Nullable *_Nullable)error;
/** set the time zone name for the camera (note that not all cameras support this) */
- (BOOL)setTimeZoneName:(NSString* _Nonnull)timeZoneName error:(out NSError * _Nullable *_Nullable)error;

- (BOOL) setWiFiSSID:(NSString * _Nonnull) ssid;

- (void) reboot;

@end
