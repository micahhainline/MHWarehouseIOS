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
    NSMutableArray *rejectedBoxes = [NSMutableArray array];
    for (int boxIndex = 0; boxIndex < boxes.count; boxIndex++) {
        MHBox *box = boxes[boxIndex];
        NSArray *remainingBoxes = [boxes subarrayWithRange:NSMakeRange(boxIndex, boxes.count - boxIndex)];
        BOOL foundRoom = NO;
        for (int roomIndex = 0; roomIndex < self.rooms.count && !foundRoom; roomIndex++) {
            MHRoom *room = self.rooms[roomIndex];
            BOOL spaceIsReservedForHazmat = room.hazmatFlags && !box.hazmatFlags && ([self remainingHazmatVolumeOfRooms] - [self remainingHazmatVolumeOfBoxes:remainingBoxes] < box.volumeInSquareMeters);
            foundRoom = [room canSafelyHold:box] && !spaceIsReservedForHazmat;
            if (foundRoom) {
                [room.boxes addObject:box];
            }
        }
        if (!foundRoom) {
            [rejectedBoxes addObject:box];
        }
    }
    return rejectedBoxes;
}

- (int)remainingHazmatVolumeOfBoxes:(NSArray *)boxes {
    int volume = 0;
    for (MHBox *box in boxes) {
        if (box.hazmatFlags) {
            volume += box.volumeInSquareMeters;
        }
    }
    return volume;
}

- (int)remainingHazmatVolumeOfRooms {
    int volume = 0;
    for (MHRoom *room in self.rooms) {
        if (room.hazmatFlags) {
            volume += room.remainingVolumeInSquareMeters;
        }
    }
    return volume;
}

@end
