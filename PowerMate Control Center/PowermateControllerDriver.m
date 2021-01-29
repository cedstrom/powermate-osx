//
//  PowermateControllerDriver.m
//  PowerMate Control Center
//
//  Created by Chris Edstrom on 1/25/21.
//  Copyright © 2021 Chris Edstrom. All rights reserved.
//

#import <AVKit/AVKit.h>

#import "PowermateControllerDriver.h"

NSString* const kPowermateServiceUUID = @"25598CF7-4240-40A6-9910-080F19F91EBC";
NSString* const kPowermateReadCharacteristicUUID = @"9cf53570-ddd9-47f3-ba63-09acefc60415";
NSString* const kPowermateLedCharacteristicUUID = @"847d189e-86ee-4bd2-966f-800832b1259d";

NSString* const kPowermateKnobNotification = @"kPowermateKnobNotification";

#define POWERMATE_KNOB_STATES \
  X(kPowermateKnobPress, 0x65) \
  X(kPowermateKnobRelease, 0x66) \
  X(kPowermateKnobCounterClockwise, 0x67) \
  X(kPowermateKnobClockwise, 0x68) \
  X(kPowermateKnobPressedCounterClockwise, 0x69) \
  X(kPowermateKnobPressedClockwise, 0x70) \
  X(kPowermateKnobPressed1Second, 0x72) \
  X(kPowermateKnobPressed2Second, 0x73) \
  X(kPowermateKnobPressed3Second, 0x74) \
  X(kPowermateKnobPressed4Second, 0x75) \
  X(kPowermateKnobPressed5Second, 0x76) \
  X(kPowermateKnobPressed6Second, 0x77)

typedef NS_ENUM(uint8_t, PowermateInputState) {
#define X(name, value) name = value,
  POWERMATE_KNOB_STATES
#undef X
};

@interface PowermateControllerDriver ()

@property (retain) CBCentralManager* manager;
@property (retain) CBPeripheral* peripheral;

@property (retain) CBPeripheral* controller;
@property (retain) CBCharacteristic* writeCharacteristic;

@property (retain) id<PowermateControllerDelegate> delegate;

@end

@implementation PowermateControllerDriver

-(void) dealloc {
  if(_peripheral) {
    [_manager cancelPeripheralConnection:_peripheral];
  }
}

#pragma mark - Map "Constants"

+(NSString*) nameForState:(PowermateInputState) state {
  static NSMutableDictionary* nameMap = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    nameMap = [NSMutableDictionary dictionary];
  
#define str(a) #a
#define X(name, value) [nameMap setObject:@ #name forKey:[NSNumber numberWithInteger:value]];
    POWERMATE_KNOB_STATES
#undef X
  });
  
  return [nameMap objectForKey:[NSNumber numberWithInteger:state]];
}

+(CBUUID*) serviceUUID {
  static CBUUID* serviceUUID = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    serviceUUID = [CBUUID UUIDWithString:kPowermateServiceUUID];
  });
  return serviceUUID;
}

-(instancetype) init {
  _manager = [[CBCentralManager alloc] initWithDelegate:self queue: nil];
  
  [self updateConnectionState:false];
  
  return self;
}

-(PowermateControllerDriver*) initWithDelegate:(id<PowermateControllerDelegate>) delegate {
  PowermateControllerDriver* this = [self init];
  _delegate = delegate;
  return this;
}

#pragma mark - Connection Management
-(void) startScan {
  NSArray *powermateService = [NSArray arrayWithObject:[PowermateControllerDriver serviceUUID]];
  [_manager scanForPeripheralsWithServices:powermateService options:nil];
}

-(void) updateConnectionState:(BOOL) state {
  _connected = state;
  if(_delegate) {
    [_delegate controller:self didChangeState:state];
  }
}

#pragma mark - Processing loop

-(void) process:(PowermateInputState)value {
  [[NSDistributedNotificationCenter defaultCenter] postNotificationName:kPowermateKnobNotification object:[PowermateControllerDriver nameForState:value]];
}

#pragma mark - LED State management

-(void) setLedRawValue:(const uint8_t)brightness {
  NSLog(@"set led to 0x%x", brightness);
  NSData* brightnessData = [NSData dataWithBytes:&brightness length:1];
  [_controller writeValue:brightnessData forCharacteristic:_writeCharacteristic type:CBCharacteristicWriteWithResponse];
}

-(void) setLedBrightness:(float) intensity
  {
    uint8_t brightness = ((0xbf - 0xa1) * intensity) + 0xa1;
    if(intensity <= 0) {
      brightness = 0x80;
    }
    if(intensity >= 1) {
      brightness = 0xbf;
    }
    NSLog(@"led brightness=0x%x", brightness);
    [self setLedRawValue:brightness];
  }

-(void) setLedOn {
  [self setLedRawValue:0x81];
}

-(void) setLedOff {
  [self setLedRawValue:0x80];
}

-(void) quickBlinkLed
{
  [self setLedRawValue:0xa0];
}

-(void) blinkLedAtSpeed:(int) speed {
  if(speed > 63) {
    speed = 63;
  }
  [self setLedRawValue:0xff - speed];
}

#pragma mark - CBPeripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverServices:(NSError *)error {
  for (CBService* service in peripheral.services) {
    if([service.UUID isEqual:[PowermateControllerDriver serviceUUID]]) {
      [peripheral discoverCharacteristics:nil forService:service];
    }
  }
}

- (void)peripheral:(CBPeripheral *)peripheral
didDiscoverCharacteristicsForService:(CBService *)service
             error:(NSError *)error {
  for (CBCharacteristic* characteristic in service.characteristics) {
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kPowermateReadCharacteristicUUID]]) {
      if(!characteristic.isNotifying) {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
      }
    }
    if([characteristic.UUID isEqual:[CBUUID UUIDWithString:kPowermateLedCharacteristicUUID]]) {
      _writeCharacteristic = characteristic;
      [self setLedOff];
    }
  }
  [self updateConnectionState:true];
}

- (void)peripheral:(CBPeripheral *)peripheral
didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic
             error:(NSError *)error
{
  uint8_t value;
  [characteristic.value getBytes:&value length:sizeof(value)];
  [self process:value];
}

#pragma mark - CBCentralManager Delegate

- (void)centralManager:(CBCentralManager *)central
didDisconnectPeripheral:(CBPeripheral *)peripheral
                 error:(NSError *)error {
  [self updateConnectionState:false];
  [self startScan];
}

- (void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central {
  switch ([_manager state])
  {
      case CBManagerStateUnsupported:
          _errorReason = @"The platform/hardware doesn't support Bluetooth Low Energy.";
          break;
      case CBManagerStateUnauthorized:
          _errorReason = @"The app is not authorized to use Bluetooth Low Energy.";
          break;
      case CBManagerStatePoweredOff:
          _errorReason = @"Bluetooth is currently powered off.";
          break;
      case CBManagerStatePoweredOn:
          _errorReason = @"";
          [self startScan];
      break;
      case CBManagerStateUnknown:
          _errorReason = @"Bluetooth state is unknown.";
      default:
          _errorReason = @"An unknown Bluetooth error occurred.";
          break;
          
  }
}

- (void)centralManager:(CBCentralManager *)central
didDiscoverPeripheral:(CBPeripheral *)peripheral
    advertisementData:(NSDictionary<NSString *,id> *)advertisementData
                  RSSI:(NSNumber *)RSSI {
  NSLog(@"discovered!");
  _peripheral = peripheral;
  [_manager connectPeripheral:peripheral options:nil];
}

- (void)centralManager:(CBCentralManager *)central
  didConnectPeripheral:(CBPeripheral *)peripheral
{
  self.controller = peripheral;
  self.controller.delegate = self;
  
  NSArray *powermateService = [NSArray arrayWithObject:[PowermateControllerDriver serviceUUID]];
  [_controller discoverServices:powermateService];
  [_manager stopScan];
}
@end
