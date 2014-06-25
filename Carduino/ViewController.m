//
//  ViewController.m
//  Carduino
//
//  Created by Ladvien on 6/21/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "ViewController.h"


@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

// Timers.
@property (nonatomic, retain) NSTimer *steerSliderRecoilTimer;
@property (nonatomic, retain) NSTimer *accelerationSliderRecoilTimer;
@property (nonatomic, retain) NSTimer *rssiTimer;

//Outlets.
@property (strong, nonatomic) IBOutlet UIImageView *steerSliderThumbImage;
@property (strong, nonatomic) IBOutlet UILabel *steerLabel;
@property (strong, nonatomic) IBOutlet UISlider *steerSlider;
@property (strong, nonatomic) IBOutlet UISlider *accelerationSlider;
@property (strong, nonatomic) IBOutlet UILabel *accelerationLabel;
@property (strong, nonatomic) IBOutlet UITableView *bleScanTableView;
@property (strong, nonatomic) IBOutlet UIView *devicesView;

//Buttons in Devices Table.
- (IBAction)backFromDevices:(id)sender;

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
    self.devicesView.layer.cornerRadius = 30;
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return nil;
}

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

- (IBAction)backFromDevices:(id)sender {

    // Hide the devices list.
    self.devicesView.hidden = TRUE;
}
@end

