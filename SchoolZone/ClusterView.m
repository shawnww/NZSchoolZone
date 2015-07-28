//
//  ClusterView.m
//  SchoolZone
//
//  Created by Shawn on 4/7/15.
//  Copyright (c) 2015 Shawn. All rights reserved.
//

#import "ClusterView.h"
@interface ClusterView()
@property (nonatomic, strong) UILabel *numberLabel;
@end

@implementation ClusterView


- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier  {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.image = [UIImage imageNamed:@"anchor_blue_ok"];
        
        
        self.numberLabel = [[UILabel alloc]initWithFrame:CGRectMake(1, -5, 20, 32)];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.textColor = [UIColor whiteColor];
        self.numberLabel.font = [UIFont systemFontOfSize:10];
        [self addSubview:self.numberLabel];
    }
    return self;
}

- (void)setNumber:(int)number
{
    //NSLog(@"set cluster count %d", number);
    _number = number;
    self.numberLabel.text = [NSString stringWithFormat:@"%d", number];
}
@end
