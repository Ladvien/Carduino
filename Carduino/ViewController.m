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
- (IBAction)steerSliderTouchDown:(id)sender;

//Actions
- (IBAction)steerSlider:(id)sender;
- (IBAction)steerSliderTouchUp:(id)sender;
- (IBAction)steerSliderTouchUpOutside:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.steerSlider setThumbImage:[UIImage imageNamed:@"track-thumb.png"] forState:UIControlStateNormal];
    [self.steerSlider setMaximumTrackImage:[UIImage alloc] forState:UIControlStateNormal];
    


}

- (void)tick{
    {

        int steerSliderAsInt = lroundf(self.steerSlider.value);
        
        if(steerSliderAsInt == 125)
        {
            [self.startTimer invalidate];
            self.startTimer = nil;
            NSLog(@"Invalidated");
        }
        
        else if (steerSliderAsInt > 125)
        {
            self.steerSlider.value = (self.steerSlider.value -1);
            //self.steerSlider.value = 125;
        }
        else if (steerSliderAsInt < 125)
        {
            self.steerSlider.value = (self.steerSlider.value + 1);
            //self.steerSlider.value = 125;
        }

        self.steerLabel.text = [NSString stringWithFormat:@"%i", steerSliderAsInt];
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
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:.0001
                                                       target:self
                                                     selector:@selector(tick)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (IBAction)steerSliderTouchUpOutside:(id)sender {
    self.startTimer = [NSTimer scheduledTimerWithTimeInterval:.0001
                                                       target:self
                                                     selector:@selector(tick)
                                                     userInfo:nil
                                                      repeats:YES];
    
    CATransition *transition = [CATransition animation];
}
- (IBAction)steerSliderTouchDown:(id)sender {
    [self.startTimer invalidate];
    self.startTimer = nil;
}
@end
