//
//  PowermateControllerDriver.h
//  PowerMate Control Center
//
//  Created by Chris Edstrom on 1/25/21.
//  Copyright © 2021 Chris Edstrom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString* const kPowermateServiceUUID;

@class PowermateControllerDriver;

@protocol PowermateControllerDelegate <NSObject>

-(void) controller:(PowermateControllerDriver*) driver didChangeState:(BOOL) connected;

@end

@interface PowermateControllerDriver : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

+(CBUUID*) serviceUUID;

-(void) startScan;
@property (assign, readonly) BOOL connected;
@property (atomic, retain) NSString* errorReason;

-(PowermateControllerDriver*) initWithDelegate:(id<PowermateControllerDelegate>) delegate;

-(void) setLedBrightness:(float) intensity;
-(void) setLedOn;
-(void) setLedOff;
-(void) quickBlinkLed;
-(void) blinkLedAtSpeed:(int) speed;
@end

NS_ASSUME_NONNULL_END
