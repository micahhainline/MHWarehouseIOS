#import "MHBox.h"

@interface MHBox ()

@property (nonatomic, readwrite) int volumeInSquareMeters;
@property (nonatomic, readwrite) MHHazmatFlags hazmatFlags;

@end

@implementation MHBox

- (id)initWithVolumeInSquareMeters:(int)volume andHazmatFlags:(MHHazmatFlags)hazmatFlags {
    if (self = [super init]) {
        self.volumeInSquareMeters = volume;
        self.hazmatFlags = hazmatFlags;
    }
    return self;
}

@end
