#import "MHWarehouse.h"
#import "MHBox.h"
#import "MHRoom.h"

@interface MHWarehouse ()

@property(nonatomic, strong) NSArray *rooms;

@end

@implementation MHWarehouse

- (id)initWithRooms:(NSArray *)rooms {
    if (self = [super init]) {
        self.rooms = rooms;
    }
    return self;
}

- (NSArray *)addBoxes:(NSArray *)boxes {
    return nil;
}

@end
