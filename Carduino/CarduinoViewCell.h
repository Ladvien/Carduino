//
//  CarduinoViewCell.h
//  Carduino_v01
//
//  Created by Ladvien on 6/14/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CarduinoViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *deviceNameLabel;
@property (nonatomic, weak) IBOutlet UILabel *uuidLabel;
@property (nonatomic, weak) IBOutlet UIImageView *deviceImage;

@end
