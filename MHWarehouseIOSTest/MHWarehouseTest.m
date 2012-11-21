#import <GHUnitIOS/GHTestCase.h>
#import "MHWarehouse.h"
#import "MHRoom.h"
#import "MHBox.h"
#import "MHHazmatFlags.h"

#define GHAssertEqualContents(FIRST__, SECOND__) GHAssertEqualObjects([NSSet setWithArray:FIRST__], [NSSet setWithArray:SECOND__], nil)

@interface MHWarehouseTest : GHTestCase

@end

@implementation MHWarehouseTest

- (void)testWhenOneBoxIsAddedToOneRoomThenTheRoomContainsTheBox {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];
    
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10];

    [testObject addBoxes:@[box1]];
    GHAssertEqualContents(loadingDock.boxes, @[box1]);
}

- (void)testWhenBoxesAreAddedThenTheyAreAddedToFirstRoomFirstUntilCapacityIsReached {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:70];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:15];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box3];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(mainStorage.boxes, @[box4]);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxOver50VolumeIsLoadedThenItIsNotLoadedInARoomRequiringStairs {
    MHRoom *basement = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:YES];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:50];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:51];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[basement, mainStorage]];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box4];
    GHAssertEqualContents(basement.boxes, expected);
    GHAssertEqualContents(mainStorage.boxes, @[box3]);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxesExceedCapacityThenFinalBoxesAreRejected {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:40];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:40];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:40];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box4];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(rejectedBoxes, @[box3]);
}

- (void)testWhenChemicalBoxIsLoadedItIsLoadedInSafeRoom {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHRoom *chemStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemStorage]];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];

    NSArray *expected = @[box1, box3];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(chemStorage.boxes, @[box2]);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenHazmatHasNoSafeRoomThenItIsRejected {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];

    NSArray *expected = @[box1, box3];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(mainStorage.boxes, @[]);
    GHAssertEqualContents(rejectedBoxes, @[box2]);
}

- (void)testDifferentHazmatBoxesCanBeStoredInDifferentRoomsWhileStillRespectingSizeAndStairs {
    MHRoom *loadingDock = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHRoom *chemLoft = [[MHRoom alloc] initWithVolumeInSquareMeters:100 andStairs:YES andHazmatFlags:MHHazmatFlagsChemical];
    MHRoom *vault = [[MHRoom alloc] initWithVolumeInSquareMeters:150 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear | MHHazmatFlagsChemical];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box6 = [[MHBox alloc] initWithName:@"box6" andVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemLoft, vault]];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5, box6]];

    GHAssertEqualContents(loadingDock.boxes, @[]);
    NSArray *expected = @[box1, box5];
    GHAssertEqualContents(chemLoft.boxes, expected);
    expected = @[box2, box3, box4, box6];
    GHAssertEqualContents(vault.boxes, expected);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testBoxesAreNotPlacedSuchThatAHazmatWillHaveNoPlaceToGoWhenThereIsEnoughRoom {
    MHRoom *vault = [[MHRoom alloc] initWithVolumeInSquareMeters:150 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];

    NSArray *expected = @[box1, box5];
    GHAssertEqualContents(vault.boxes, expected);
    expected = @[box2, box3, box4];
    GHAssertEqualContents(mainStorage.boxes, expected);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testOrderForBoxesIsPreservedWhenThereIsEnoughRoom {
    MHRoom *vault = [[MHRoom alloc] initWithVolumeInSquareMeters:150 andStairs:NO andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear];
    MHRoom *mainStorage = [[MHRoom alloc] initWithVolumeInSquareMeters:1000 andStairs:NO andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:30 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];

    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];

    NSArray *expected = @[box1, box4, box5];
    GHAssertEqualContents(vault.boxes, expected);
    expected = @[box2, box3];
    GHAssertEqualContents(mainStorage.boxes, expected);
    GHAssertNil(rejectedBoxes, nil);
}

@end
