//
//  ViewController.m
//  Carduino
//
//  Created by Ladvien on 6/21/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

//Outlets
@property (strong, nonatomic) IBOutlet UIImageView *steerSliderThumbImage;
@property (strong, nonatomic) IBOutlet UILabel *steerLabel;
@property (strong, nonatomic) IBOutlet UISlider *steerSlider;
@property (strong, nonatomic) IBOutlet UISlider *accelerationSlider;


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


@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.steerSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    [self.steerSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    
    [self.accelerationSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    [self.accelerationSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    self.accelerationSlider.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    self.rssiTimer = [NSTimer scheduledTimerWithTimeInterval:.1
                                                       target:self
                                                     selector:@selector(tick)
                                                     userInfo:nil
                                                      repeats:YES];

}

- (void)tick{
    {

        int steerSliderAsInt = lroundf(self.steerSlider.value);
        
        if(steerSliderAsInt == 125)
        {
            if (self.startTimer) {
                [self.startTimer invalidate];
                self.startTimer = nil;
                self.steerLabel.text = [NSString stringWithFormat:@"%i", steerSliderAsInt];
                NSLog(@"Invalidated");
            }
        }
        else if (steerSliderAsInt > 125)
        {
            self.steerSlider.value--;
        }
        else if (steerSliderAsInt < 125)
        {
            self.steerSlider.value++;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}


- (IBAction)steerSlider:(id)sender {
    int steerSliderAsInt = lroundf(self.steerSlider.value);
    self.steerLabel.text = [NSString stringWithFormat:@"%i", steerSliderAsInt];
}

- (IBAction)steerSliderTouchUp:(id)sender {
    if(!self.startTimer){
        self.startTimer = [NSTimer scheduledTimerWithTimeInterval:.0001
                                                       target:self
                                                     selector:@selector(tick)
                                                     userInfo:nil
                                                      repeats:YES];
    }
}

- (IBAction)steerSliderTouchUpOutside:(id)sender {
    if(!self.startTimer){
        self.startTimer = [NSTimer scheduledTimerWithTimeInterval:.0001
                                                           target:self
                                                         selector:@selector(tick)
                                                         userInfo:nil
                                                          repeats:YES];
    }
}

- (IBAction)steerSliderTouchDown:(id)sender {
    [self.startTimer invalidate];
    self.startTimer = nil;
}
- (IBAction)accelerationSlider:(id)sender {
}

- (IBAction)accelerationSliderTouchUp:(id)sender {
}



- (IBAction)accelerationSliderTouchUpOutside:(id)sender {

}

- (IBAction)accelerationSliderTouchDown:(id)sender {
}
@end
