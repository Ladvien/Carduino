//
//  ViewController.h
//  Carduino
//
//  Created by Ladvien on 6/21/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "CarduinoViewCell.h"

@interface ViewController : UIViewController 
@property (strong, nonatomic) CBCentralManager *centralManager;
@property (strong, nonatomic) NSMutableDictionary *devices;
@property (strong, nonatomic) CBPeripheral *discoveredPeripheral;
@property (strong, nonatomic) NSMutableData *data;
@property (strong, nonatomic) CBPeripheral *selectedPeripheral;
@property (strong, nonatomic) CBCharacteristic *characteristics;
@property (readonly, nonatomic) CFUUIDRef UUID;

- (void)fadeDeviceMenuIn;
- (void)fadeDeviceMenuOut;
@end

//Holds steering slider value as an integer.
short int steeringValue;

//Holds acceleration slider value as an integer.
short int accelerationValue;
