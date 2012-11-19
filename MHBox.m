#import "MHBox.h"

@interface MHBox ()

@property (nonatomic, readwrite) int volumeInSquareMeters;
@property (nonatomic, readwrite) MHHazmatFlags hazmatFlags;
@property (nonatomic, strong) NSString *name;

@end

@implementation MHBox

- (id)initWithName:(NSString *)name andVolumeInSquareMeters:(int)volume andHazmatFlags:(MHHazmatFlags)hazmatFlags {
    if (self = [super init]) {
        self.name = name;
        self.volumeInSquareMeters = volume;
        self.hazmatFlags = hazmatFlags;
    }
    return self;
}

- (NSString *)description {
    return self.name;
}

@end
