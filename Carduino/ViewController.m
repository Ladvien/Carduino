//
//  ViewController.m
//  Carduino
//
//  Created by Ladvien on 6/21/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "ViewController.h"
#import "CarduinoViewCell.h"

@interface ViewController () <CBPeripheralDelegate, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>

// Timers.
@property (nonatomic, retain) NSTimer *steerSliderRecoilTimer;
@property (nonatomic, retain) NSTimer *accelerationSliderRecoilTimer;
@property (nonatomic, retain) NSTimer *rssiTimer;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

//Outlets.
@property (strong, nonatomic) IBOutlet UIImageView *steerSliderThumbImage;
@property (strong, nonatomic) IBOutlet UILabel *steerLabel;
@property (strong, nonatomic) IBOutlet UISlider *steerSlider;
@property (strong, nonatomic) IBOutlet UISlider *accelerationSlider;
@property (strong, nonatomic) IBOutlet UILabel *accelerationLabel;

@property (strong, nonatomic) IBOutlet UIView *devicesView;

//Buttons in Devices Table.
@property (strong, nonatomic) IBOutlet UIButton *backFromDevices;

//BLE
@property (strong, nonatomic) IBOutlet UIButton *scanForDevices;

// Steer slider.
- (IBAction)steerSlider:(id)sender;
- (IBAction)steerSliderTouchUp:(id)sender;
- (IBAction)steerSliderTouchUpOutside:(id)sender;
- (IBAction)steerSliderTouchDown:(id)sender;

// Accceleration slider.
- (IBAction)accelerationSlider:(id)sender;
- (IBAction)accelerationSliderTouchUp:(id)sender;
- (IBAction)accelerationSliderTouchUpOutside:(id)sender;
- (IBAction)accelerationSliderTouchDown:(id)sender;
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
	// Do any additional setup after loading the view, typically from a nib.
    
    
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
    
    //Let's set a timer to refresh RSSI.
    self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                       target:self
                                                     selector:@selector(steerSliderTick)
                                                     userInfo:nil
                                                      repeats:YES];
    
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
# pragma mark - BLE

////////////////////// Bluetooth Low Energy /////////////////////

//Make sure iOS BT is on.  Then start scanning.
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    // You should test all scenarios
    if (central.state != CBCentralManagerStatePoweredOn) {
        //In case Bluetooth is off.
        return;
        //Need to add code here stating unable to access Bluetooth.
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
    
    //Stop looking for devices.
    [_centralManager connectPeripheral:peripheral options:nil];
    
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

-(int)readRSSI
{
    CBPeripheral * RSSI = nil;
    return [RSSI.RSSI intValue];
}



- (UITableViewCell *)tableView: (UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSLog(@"BLAHAHAHAHAHAHA!!");
    
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
    
    //This is a handle for the tableView.
    static NSString * carduinoTableIdentifier = @"iPadCarduinoTableCell";
    
    
    //Get cell objects.;
    CarduinoViewCell *cell = (CarduinoViewCell *)[tableView dequeueReusableCellWithIdentifier:carduinoTableIdentifier];
    //If cell is equal to nil....
    if (cell == nil){
        
        //cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:carduinoTableIdentifier];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:carduinoTableIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }    /////////////////////////END/////////////////////////////
    
    if([indexPath row] < [uuids count]){
        if (devices)
        {
            cell.deviceNameLabel.text = [devices name];
            cell.uuidLabel.text = [uuids objectAtIndex:[indexPath row]];
        }
    }
    
    //Set the text of the cell to the deviceList.
    //cell.deviceNameLabel.text = [deviceList objectAtIndex:indexPath.row];
    
    //Add image on the left of each cell.
    cell.deviceImage.image = [UIImage imageNamed:@"oshw-logo-black.png"];
    //Sets background color for the cells.  Alpha = opacity.  Float, 0-1.
    //Will be used for device distance indication.  Let's have it as a base int.
    
    //[devices readRSSI];
    
    //NSNumber *blah = devices.RSSI;
    //intRSSI = [devices.RSSI;
    
    //Let's go ahead and convert it from a negative number.
    //intRSSI = intRSSI * -1;
    
    //Print it out for fun.
    //NSLog(@"%@", blah);
    
    cell.backgroundColor = [UIColor colorWithRed:1 green:1 blue:(1) alpha:1];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * uuids = [[self.devices allKeys] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
        return [obj1 compare:obj2];
    }];
    //CBPeripheral * selectedPeripheral = nil;
    //CBService * service = nil;
    if ([indexPath row] < [uuids count])
    {
        
        _selectedPeripheral = [self.devices objectForKey:[uuids objectAtIndex:[indexPath row]]];
        //service = [peri.services ]
        
        if (_selectedPeripheral)
        {
            [_centralManager connectPeripheral:_selectedPeripheral options:nil];
            //NSString * periChar = peri.services.
            
            //[self.conindicator startAnimating];
        }
        //[peri discoverCharacteristics:characteristics forService:service]; //[uuids objectAtIndex:[indexPath row]]];
        //for (int i = 0; i < [characteristics count]; i++){
        
        
        
        
        //NSLog(@"%@ ", [characteristics objectAtIndex:i]);
        
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
    int steerSliderAsInt = lroundf(self.steerSlider.value);
    // Set steerLabel text to float value.
    self.steerLabel.text = [NSString stringWithFormat:@"%i", steerSliderAsInt];
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
}

// Timer tick method to control Steer Slider recoil.
- (void)steerSliderTick{
    {
        // Round the Steer Slider value.
        int steerSliderAsInt = lroundf(self.steerSlider.value);
        
        // Slider is at middle.
        if(steerSliderAsInt == 125)
        {
            // Only cancel the timer if it is going.
            if (self.steerSliderRecoilTimer) {
                // Cancel recoil-timer.
                [self.steerSliderRecoilTimer invalidate];
                self.steerSliderRecoilTimer = nil;
                // Update Steer Slider label.
                self.steerLabel.text = [NSString stringWithFormat:@"%i", steerSliderAsInt];
                NSLog(@"Invalidated");
            }
        }
        
        else if (steerSliderAsInt > 125)
        {
            // De-increment Steer Slider.
            self.steerSlider.value--;
        }
        else if (steerSliderAsInt < 125)
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
    int accelerationSliderAsInt = lroundf(self.accelerationSlider.value);
    // Set Acceleration text to float value.
    self.accelerationLabel.text = [NSString stringWithFormat:@"%i", accelerationSliderAsInt];
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
}

- (IBAction)accelerationSliderTouchUpOutside:(id)sender {
    // Check to make sure timer isn't going.
    if(!self.accelerationSliderRecoilTimer){
        // Start Acceleration Slider recoil timer.
        self.accelerationSliderRecoilTimer = [NSTimer scheduledTimerWithTimeInterval:.0001 target:self selector:@selector(accelerationSliderTick) userInfo:nil repeats:YES];

        // Shrink thumb tracker image.
        [self.accelerationSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    }
}

// 
- (void)accelerationSliderTick
{
    // Round the Acceleration Slider value.
    int accelerationSliderAsInt = lroundf(self.accelerationSlider.value);
    
    // Slider is at middle.
    if(accelerationSliderAsInt == 125)
    {
        // Only cancel the timer if it is going.
        if (self.accelerationSliderRecoilTimer) {
            // Cancel recoil-timer.
            [self.accelerationSliderRecoilTimer invalidate];
            self.accelerationSliderRecoilTimer = nil;
            // Update Acceleration Slider label.
            self.accelerationLabel.text = [NSString stringWithFormat:@"%i", accelerationSliderAsInt];
            NSLog(@"Invalidated");
        }
    }
    
    else if (accelerationSliderAsInt > 125)
    {
        // De-increment Acceleration Slider.
        self.accelerationSlider.value--;
    }
    else if (accelerationSliderAsInt < 125)
    {
        // Increment Acceleration Slider.
        self.accelerationSlider.value++;
    }
}
///////////////////// Acceleration Slider End ///////////


// Menu button
- (IBAction)menuButtonTouchUp:(id)sender {
    
    // Reveal the devices list.
    self.devicesView.hidden = FALSE;
}

- (IBAction)backFromDevices:(id)sender
{
    // Hide the devices list.
    self.devicesView.hidden = TRUE;
}


@end

