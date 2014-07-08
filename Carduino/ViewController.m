//
//  ViewController.m
//  Carduino
//
//  Created by Ladvien on 6/21/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

//  STUFF TO ADD:
// 1. Periodic refresh timer on devices list.  Then, remove "Scan" button.  This will refresh device list for RSSI as well.
// 2. Change fade in / fade out to a method.
// 3.

#import "ViewController.h"
#import "CarduinoViewCell.h"

@interface ViewController () 

@property (nonatomic, retain) NSString *rxData;
@property int previousAccelerationSlider;
@property int counter;

// Timers.
@property (nonatomic, retain) NSTimer *steerSliderRecoilTimer;
@property (nonatomic, retain) NSTimer *accelerationSliderRecoilTimer;
@property (nonatomic, retain) NSTimer *rssiTimer;
@property (nonatomic, retain) NSTimer *rxResponseTimer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//Outlets.
@property (strong, nonatomic) IBOutlet UIView *mainView;
@property (strong, nonatomic) IBOutlet UILabel *steerLabel;
@property (strong, nonatomic) IBOutlet UISlider *steerSlider;
@property (strong, nonatomic) IBOutlet UISlider *accelerationSlider;
@property (strong, nonatomic) IBOutlet UILabel *accelerationLabel;


@property (strong, nonatomic) IBOutlet UIView *devicesView;
@property (strong, nonatomic) IBOutlet UILabel *RSSI;
@property (strong, nonatomic) IBOutlet UILabel *rxDataLabel;

//Buttons in Devices Table.
@property (strong, nonatomic) IBOutlet UIButton *backFromDevices;
@property (strong, nonatomic) IBOutlet UIButton *test;

//BLE
@property (strong, nonatomic) IBOutlet UIButton *scanForDevices;

@property (assign) uint8_t accelerationByte;
@property (assign) uint8_t steeringByte;

//Steer slider.
- (IBAction)steerSlider:(id)sender;
- (IBAction)steerSliderTouchUp:(id)sender;
- (IBAction)steerSliderTouchUpOutside:(id)sender;
- (IBAction)steerSliderTouchDown:(id)sender;


// Accceleration slider.
- (IBAction)accelerationSlider:(id)sender;
- (IBAction)accelerationSliderTouchUp:(id)sender;
- (IBAction)accelerationSliderTouchUpOutside:(id)sender;
- (IBAction)accelerationSliderTouchDown:(id)sender;

// Menu
- (IBAction)menuButtonTouchUp:(id)sender;




@end

@implementation ViewController
{
    NSArray *deviceList;
}
@synthesize centralManager = _centralManager;
@synthesize devices = _devices;
@synthesize characteristics = _characteristics;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Setup shadow for Devices TableView.
    self.devicesView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.devicesView.layer.shadowOpacity = 0.5f;
    self.devicesView.layer.shadowOffset = CGSizeMake(20.0f, 20.0f);
    self.devicesView.layer.shadowRadius = 5.0f;
    self.devicesView.layer.masksToBounds = NO;
    
    // Setup border for view backdrop.
    //self.devicesView.layer.cornerRadius = 30;
    self.devicesView.layer.borderWidth = 20.0;
    self.devicesView.layer.borderColor = [UIColor colorWithRed:.10588 green:.25098 blue:.46666 alpha:1].CGColor;
    
    // Set the steer slider's thumb control image.
    [self.steerSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    // This is a redneck way of removing the steer slider track.
    [self.steerSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    
    // Do the same for the acceleration control.
    [self.accelerationSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    [self.accelerationSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];

    // Turns the acceleration slider vertical.
    self.accelerationSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    self.steerSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    //Let's set a timer to refresh RSSI.
    self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                       target:self
                                                     selector:@selector(steerSliderTick)
                                                     userInfo:nil
                                                      repeats:YES];
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    
    
    //UIView *rectView = [[UIView alloc] initWithFrame:CGRectMake(15,15,40,40)];
    //rectView.backgroundColor = [UIColor clearColor];
    //rectView.layer.borderColor = [[UIColor blueColor] CGColor];
    //rectView.layer.borderWidth = 40;
    //rectView.layer.cornerRadius = 25;
    //rectView.layer.
    //[self.mainView addSubview:rectView];
    // Create a view CGRect frame = [UIScreen mainScreen].bounds;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark - BLE

////////////////////// Bluetooth Low Energy /////////////////////

- (int)readRSSI
{
    CBPeripheral *thisPer = _selectedPeripheral;
    [thisPer readRSSI];
    
    int RSSI = [thisPer.RSSI intValue];
    return RSSI;
}

// Make sure iOS BT is on.  Then start scanning.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        // In case Bluetooth is off.
        return;
        // Need to add code here stating unable to access Bluetooth.
    }
    if (central.state == CBCentralManagerStatePoweredOn) {
        //If it's on, scan for devices.
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
    }
}

// Report what devices have been found.
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    // Set peripheral.
    _discoveredPeripheral = peripheral;
    
    // Create a string for the conneceted peripheral.
    NSString * uuid = [[peripheral identifier] UUIDString];
    
    if (uuid) //Make sure we got the UUID.
    {
        //This sets the devices object.peripheral = uuid
        [self.devices setObject:peripheral forKey:uuid];
    }
    
    // Discover services for peripheral.
    [peripheral discoverServices:nil];
    
    //Refresh data in the table.
    [self.tableView reloadData];
}

- (NSMutableDictionary *)devices
{
    // Make sure the device dictionary is empty.
    if (_devices == nil)
    {
        // Let's get the top 6 devices.
        _devices = [NSMutableDictionary dictionaryWithCapacity:6];
    }
    // Return a dictionary of devices.
    return _devices;
}

- (void)setCentralManager:(CBCentralManager *)myCentralManager
{
    //NSLog(@"setCentralManager");
    
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    // Run this whenever we have connected to a device.
    NSLog(@"Connected");
    // Set the peripheral to ???
    peripheral.delegate = self;
    // Set the peripheral method's discoverServices to nil.
    // Does this keep the code from looking for new devices?
    [peripheral discoverServices:nil];
    
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService * service in [peripheral services])
    {
        [_selectedPeripheral discoverCharacteristics:nil forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic * character in [service characteristics])
    {
        [_selectedPeripheral discoverDescriptorsForCharacteristic:character];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverDescriptorsForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    //Store data from the UUID in byte format, save in the bytes variable.
    const char * bytes =[(NSData*)[[characteristic UUID] data] bytes];
    //Check to see if it is two bytes long, and they are both FF, FF.
    if (bytes && strlen(bytes) == 2 && bytes[0] == (char)255 && bytes[1] == (char)225)
    {
        NSLog(@"%s", bytes);
        //Stop the search animation
        //Setup a MainViewController reference
        //?
        //Send the peripheral data to the MainViewController.
        _selectedPeripheral = peripheral;
        for (CBService * service in [_selectedPeripheral services])
        {

            for (CBCharacteristic * characteristic in [service characteristics])
            {            //NSLog(@"Blah!!");
                [_selectedPeripheral setNotifyValue:true forCharacteristic:characteristic];
            }
        }
    }
}

- (void)sendValue:(NSString *) str
{
    for (CBService * service in [_selectedPeripheral services])
    {
        for (CBCharacteristic * characteristic in [service characteristics])
        {
            // Round the float.
            steeringValue = lroundf(self.steerSlider.value);
            accelerationValue = lroundf(self.accelerationSlider.value);
            
            // SEND STRING
            //  DIR-MA    DIR-MB    PWM-MA  PWMA-MB EOTC
            //  CON Byte  CON Byte   0-255   0-255    :
            NSMutableData *myData = [NSMutableData data];
            
            // CONTROL BYTE
            //  BIT: 7=CAN'T BE USED
            //  BIT: 6=
            //  BIT: 5=Breaklights ON
            //  BIT: 4=Headlights ON
            //  BIT: 3=127+ MOTOR B
            //  BIT: 2=127+ MOTOR A
            //  BIT: 1=MOTOR B DIR
            //  BIT: 0=MOTOR A DIR
            NSUInteger controlByte = 0;
            
            //NSLog(@"Begin: %i", controlByte);
            
            //Steer value is negative number.
            if(steeringValue < 0)
            {
                // Set the reverse bit.
                controlByte |= 1 << 0;
                steeringValue = (steeringValue * -1);
                //NSLog(@"%i", controlByte);
                NSLog(@"STEER -");
            }
            
            // Acceleration value is a negative number.
            if(accelerationValue < 0)
            {
                // Set the reverse bit.
                controlByte |= 1 << 1;
                accelerationValue = (accelerationValue * -1);
                //NSLog(@"%i", controlByte);
                NSLog(@"ACCEL -");
            }

            // If steer motor is greater than 127.
            if (steeringValue > 127) {
                // Set the bit indicating 128-255.
                controlByte |= 1 << 2;
                // Remove excess from text.label
                steeringValue -= 128;
                //NSLog(@"%i", controlByte);
                NSLog(@"STEER +127");
            }

            // If steer motor is greater than 127.
            if (accelerationValue > 127) {
                // Set the bit indicating 128-255.
                controlByte |= 1 << 3;
                // Remove excess from text.label
                accelerationValue -= 128;
                //NSLog(@"%x", controlByte);
                NSLog(@"ACCEL +127");
            }
            
            //NSLog(@"After: %i", controlByte);
            // Breaklights
            //controlByte |= 1 << 5;
            // Headlights
            //controlByte |= 1 << 4;
            
            
            //////////// Convert RSSI Data to Color //////////////////////
            
            ViewController * numberMapper = [[ViewController alloc] init];
            [_selectedPeripheral readRSSI];
            int rssiRawValue = [_selectedPeripheral.RSSI integerValue];
            rssiRawValue = rssiRawValue * -1;
            float rssiColorValue = [numberMapper mapNumber:rssiRawValue minimumIn:55 maximumIn:100 mimimumOut:0 maximumOut:1];
            NSLog(@"%f", [numberMapper mapNumber:rssiRawValue minimumIn:50 maximumIn:110 mimimumOut:0 maximumOut:1]);

            /////////End Convert RSSI Data to Color //////////////////////
            
            [myData appendBytes:&controlByte length:sizeof(unsigned char)];
            [myData appendBytes:&steeringValue length:sizeof(unsigned char)];
            [myData appendBytes:&accelerationValue length:sizeof(unsigned char)];
            
            NSString * strData = [[NSString alloc] initWithData:myData encoding:NSASCIIStringEncoding];
            
            //NSLog(@"Control: %i Steer: %i, Acc: %i", controlByte, steeringValue, accelerationValue);
            
            str = [NSString stringWithFormat:@"%@:", strData];
            
            if ([self.rxData  isEqual: @""]) {
                //NSLog(@"RX CHECK!");
                self.rxData = 0;
            }
            
            //NSLog(@"%i", [str length]);
            
            [_selectedPeripheral writeValue:[str dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
                self.rxData = @" ";
            
            //counter++;
            //NSLog(@"%i", counter);
        }
    }
}


-(void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    NSString * str = [[NSString alloc] initWithData:[characteristic value] encoding:NSUTF8StringEncoding];
    self.rxData = str;
    self.rxDataLabel.text = [NSString stringWithFormat:@"%@", str];
}

////////////////////// Bluetooth Low Energy End //////////////////


# pragma mark - table controller
////////////////////// Device Table View //////////////////

- (NSInteger)numberOfSectionsInTableView: (UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //This counts how many items are in the deviceList array.
    return [self.devices count];
}


- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // This gets a sorted array from NSMutableDictionary.
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    
    // Setup a devices instance.
    CBPeripheral * devices = nil;
    
    
    // Go until we run out of devices.
    if ([indexPath row] < [uuids count])
    {
        // Set the peripherals based upon indexPath # from uuids array.
        devices = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
    }
    
    /////////////////////////LOADS CUSTOM CELL/////////////////////////////
    
    // This is a handle for the tableView.
    static NSString * carduinoTableIdentifier = @"iPadCarduinoTableCell";
    
    
    // Get cell objects.;
    CarduinoViewCell *cell = (CarduinoViewCell *)[tableView dequeueReusableCellWithIdentifier:carduinoTableIdentifier];
    // If cell is equal to nil....
    if (cell == nil){
        // Load the custom cell.
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:carduinoTableIdentifier owner:self options:nil];
        // Use the prototype.
        cell = [nib objectAtIndex:0];
    }
    
    /////////////////////////END/////////////////////////////
    
    // List all the devices in the table view.
    if([indexPath row] < [uuids count]){
        // Don't list a device if there isn't one.
        if (devices)
        {
            cell.deviceNameLabel.text = [devices name];
            cell.uuidLabel.text = [uuids objectAtIndex:[indexPath row]];
        }
    }
    
    // Add image on the left of each cell.
    cell.deviceImage.image = [UIImage imageNamed:@"oshw-logo-black.png"];
    // Sets background color for the cells.  Alpha = opacity.  Float, 0-1.
    // Will be used for device distance indication.  Let's have it as a base int.
    
    // Set the background color of the cells.
    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:(1) alpha:1];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Create a sorted array of the found UUIDs.
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];

    // Only get enough devices or listed cells.
    if ([indexPath row] < [uuids count])
    {
        // Set the peripheral based upon the indexPath; uuid being the array.
        _selectedPeripheral = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
        
        // If there is a peripheral.
        if (_selectedPeripheral)
        {
            // Close current connection.
            [_centralManager cancelPeripheralConnection:_selectedPeripheral];
            // Connect to selected peripheral.
            [_centralManager connectPeripheral:_selectedPeripheral options:nil];
            // Hide the devices list.            
            [UIView beginAnimations:@"fade in" context:nil];
            [UIView setAnimationDuration:1.0];
            self.devicesView.alpha = 0;
            [UIView commitAnimations];
        }
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //Sets the height for each row to 90, the same size as the custom cell.
    return 60;
}

////////////////////// Device Table View End///////////////

# pragma mark - Steer Slider

////////////////////// Steer Slider /////////////////////

// Slider changes value.
- (IBAction)steerSlider:(id)sender {
    

    
    // Round the float.
    steeringValue = lroundf(self.steerSlider.value);
    
    // Set steerLabel text to float value.
    self.steerLabel.text = [NSString stringWithFormat:@"%i", steeringValue];
    [self sendValue:[NSString stringWithFormat:@"%i", steeringValue]];

}


// User touches Steer Slider.
- (IBAction)steerSliderTouchDown:(id)sender {
    
    // Cancel the slider-recoil timer.
    [self.steerSliderRecoilTimer invalidate];
    self.steerSliderRecoilTimer = nil;
  
    // Enlarge thumb tracker image.
    [self.steerSlider setThumbImage:[UIImage imageNamed:@"track-thumb-grown.png"] forState:UIControlStateNormal];
    
}

// User touches up inside Steer slider.
- (IBAction)steerSliderTouchUp:(id)sender {
    
    // Check to make sure timer isn't going.
    if(!self.steerSliderRecoilTimer){
        // Start Steer Slider recoil timer.
        self.steerSliderRecoilTimer = [NSTimer scheduledTimerWithTimeInterval:.0001 target:self selector:@selector(steerSliderTick) userInfo:nil repeats:YES];
        
        // Shrink thumb tracker image.
        [self.steerSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    }
    steeringValue = 0;
    [self sendValue:[NSString stringWithFormat:@"%i", accelerationValue]];

}

// User touches up outside Steer Slider.
- (IBAction)steerSliderTouchUpOutside:(id)sender {
    // Check to make sure timer isn't going.
    if(!self.steerSliderRecoilTimer){
        // Start Steer Slider recoil-timer.
        self.steerSliderRecoilTimer = [NSTimer scheduledTimerWithTimeInterval:.0001 target:self selector:@selector(steerSliderTick) userInfo:nil repeats:YES];

        // Shrink thumb tracker image.
        [self.steerSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
        
    }
    steeringValue = 0;
    [self sendValue:[NSString stringWithFormat:@"%i", accelerationValue]];
}

// Timer tick method to control Steer Slider recoil.
- (void)steerSliderTick{
    {
        // Round the Steer Slider value.
        steeringValue = lroundf(self.steerSlider.value);
        
        // Slider is at middle.
        if(steeringValue == 0)
        {
            // Only cancel the timer if it is going.
            if (self.steerSliderRecoilTimer) {
                // Cancel recoil-timer.
                [self.steerSliderRecoilTimer invalidate];
                self.steerSliderRecoilTimer = nil;
                // Update Steer Slider label.
                self.steerLabel.text = [NSString stringWithFormat:@"%i", steeringValue];
                //NSLog(@"Invalidated");
                [self sendValue:[NSString stringWithFormat:@"%i", accelerationValue]];
            }
        }
        
        else if (steeringValue > 0)
        {
            // De-increment Steer Slider.
            self.steerSlider.value--;
        }
        else if (steeringValue < 0)
        {
            // Increment Steer Slider.
            self.steerSlider.value++;
        }
    }
}
////////////////////// Steer Slider End //////////////////


# pragma mark - Acceleration Slider
///////////////////// Acceleration Slider ///////////////

- (IBAction)accelerationSlider:(id)sender {
    // Round the float.
    accelerationValue = self.accelerationSlider.value;
    
    // Set Acceleration text to float value.
    if (_previousAccelerationSlider != accelerationValue) {
        self.accelerationLabel.text = [NSString stringWithFormat:@"%i", accelerationValue];
        [self sendValue:[NSString stringWithFormat:@"%i", accelerationValue]];
    }
    _previousAccelerationSlider = accelerationValue;
}

- (IBAction)accelerationSliderTouchDown:(id)sender {
    // Cancel the slider-recoil timer.
    [self.accelerationSliderRecoilTimer invalidate];
    self.accelerationSliderRecoilTimer = nil;
    
    // Enlarge thumb tracker image.
    [self.accelerationSlider setThumbImage:[UIImage imageNamed:@"track-thumb-grown.png"] forState:UIControlStateNormal];
}


- (IBAction)accelerationSliderTouchUp:(id)sender {
    // Check to make sure timer isn't going.
    if(!self.accelerationSliderRecoilTimer){
        // Start Acceleration Slider recoil timer.
        self.accelerationSliderRecoilTimer = [NSTimer scheduledTimerWithTimeInterval:.0001 target:self selector:@selector(accelerationSliderTick) userInfo:nil repeats:YES];

        // Shrink thumb tracker image.
        [self.accelerationSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    }
    //accelerationValue = 0;
    //[self sendValue:[NSString stringWithFormat:@"%i", accelerationValue]];
}

- (IBAction)accelerationSliderTouchUpOutside:(id)sender {
    // Check to make sure timer isn't going.
    if(!self.accelerationSliderRecoilTimer){
        // Start Acceleration Slider recoil timer.
        self.accelerationSliderRecoilTimer = [NSTimer scheduledTimerWithTimeInterval:.0001 target:self selector:@selector(accelerationSliderTick) userInfo:nil repeats:YES];

        // Shrink thumb tracker image.
        [self.accelerationSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    }
    //accelerationValue = 0;
    //[self sendValue:[NSString stringWithFormat:@"%i", accelerationValue]];
}

// 
- (void)accelerationSliderTick
{
    // Round the Acceleration Slider value.
    accelerationValue = lroundf(self.accelerationSlider.value);
    
    // Slider is at middle.
    if(accelerationValue == 0)
    {
        // Only cancel the timer if it is going.
        if (self.accelerationSliderRecoilTimer) {
            [self sendValue:[NSString stringWithFormat:@"%i", accelerationValue]];
            // Cancel recoil-timer.
            [self.accelerationSliderRecoilTimer invalidate];
            self.accelerationSliderRecoilTimer = nil;
            // Update Acceleration Slider label.
            self.accelerationLabel.text = [NSString stringWithFormat:@"%i", accelerationValue];
            //NSLog(@"Invalidated");
            
        }
    }
    
    else if (accelerationValue > 0)
    {
        // De-increment Acceleration Slider.
        self.accelerationSlider.value--;
    }
    else if (accelerationValue < 0)
    {
        // Increment Acceleration Slider.
        self.accelerationSlider.value++;
    }
}
///////////////////// Acceleration Slider End ///////////

# pragma mark - misc

// Menu button
- (IBAction)menuButtonTouchUp:(id)sender {
    //ViewController * fade = [[ViewController alloc] init];
    //[fade fadeDeviceMenuIn];
    
    // Hide the devices list.
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:.30];
    self.devicesView.alpha = 1;
    [UIView commitAnimations];
}

- (IBAction)backFromDevices:(id)sender
{

    // Hide the devices list.
    [UIView beginAnimations:@"fade in" context:nil];
    [UIView setAnimationDuration:.30];
    self.devicesView.alpha = 0;
    [UIView commitAnimations];
}

- (IBAction)test:(id)sender
{
    [self sendValue:[NSString stringWithFormat:@"%c:", 250]];
}

- (void)fadeDeviceMenuIn;
{

}
- (void)fadeDeviceMenuOut;
{
    
}

-(float)mapNumber: (float)x minimumIn:(float)minIn maximumIn:(float)maxIn mimimumOut:(float)minOut maximumOut:(float)maxOut;
{
    return ((x - minIn) * (maxOut - minOut)/(maxIn - minIn) + minOut);
}
@end

