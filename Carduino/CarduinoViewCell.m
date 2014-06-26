//
//  CarduinoViewCell.m
//  Carduino_v01
//
//  Created by Ladvien on 6/14/14.
//  Copyright (c) 2014 Honeysuckle Hardware. All rights reserved.
//

#import "CarduinoViewCell.h"

@implementation CarduinoViewCell

@synthesize deviceNameLabel = _deviceNameLabel;
@synthesize uuidLabel = _uuidLabel;
@synthesize deviceImage = _deviceImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
