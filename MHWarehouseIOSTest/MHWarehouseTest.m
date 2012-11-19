#import <GHUnitIOS/GHTestCase.h>
#import "MHWarehouse.h"
#import "MHRoom.h"
#import "MHBox.h"
#import "MHHazmatFlags.h"

#define GHAssertEqualContents(FIRST__, SECOND__) GHAssertEqualObjects([NSSet setWithArray:FIRST__], [NSSet setWithArray:SECOND__], nil)

@interface MHWarehouseTest : GHTestCase {
    MHRoom *loadingDock;
    MHRoom *mainStorage;
    MHRoom *chemStorage;
    MHRoom *chemLoft;
    MHRoom *basement;
    MHRoom *vault;
}

@end

@implementation MHWarehouseTest

- (void)setUp {
    [super setUp];
    loadingDock = [[MHRoom alloc] initWithName:@"Loading Dock" andCapacityInSquareMeters:100 andHazmatFlags:MHHazmatFlagsNone requiresStairs:NO];
    mainStorage = [[MHRoom alloc] initWithName:@"Main Storage Room" andCapacityInSquareMeters:1000 andHazmatFlags:MHHazmatFlagsNone requiresStairs:NO];
    chemStorage = [[MHRoom alloc] initWithName:@"Chemical Storage" andCapacityInSquareMeters:100 andHazmatFlags:MHHazmatFlagsChemical requiresStairs:NO];
    chemLoft = [[MHRoom alloc] initWithName:@"Chemical Loft" andCapacityInSquareMeters:100 andHazmatFlags:MHHazmatFlagsChemical requiresStairs:YES];
    basement = [[MHRoom alloc] initWithName:@"Basement" andCapacityInSquareMeters:1000 andHazmatFlags:MHHazmatFlagsNone requiresStairs:YES];
    vault = [[MHRoom alloc] initWithName:@"Valut" andCapacityInSquareMeters:150 andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear requiresStairs:NO];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testWhenOneBoxIsAddedToOneRoomThenTheRoomContainsTheBox {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];
    
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1]];
    GHAssertEqualContents(loadingDock.boxes, @[box1]);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxesAreAddedThenTheyAreAddedToFirstRoomFirstUntilCapacityIsReached {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:70 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:15 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box3];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(mainStorage.boxes, @[box4]);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxOver50VolumeIsLoadedThenItIsNotLoadedInARoomRequiringStairs {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[basement, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:51 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box4];
    GHAssertEqualContents(basement.boxes, expected);
    GHAssertEqualContents(mainStorage.boxes, @[box3]);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxesExceedCapacityThenFinalBoxesAreRejected {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:40 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:40 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:40 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box4];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(rejectedBoxes, @[box3]);
}

- (void)testWhenChemicalBoxIsLoadedItIsLoadedInSafeRoom {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemStorage]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];

    NSArray *expected = @[box1, box3];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(chemStorage.boxes, @[box2]);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenHazmatHasNoSafeRoomThenItIsRejected {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];

    NSArray *expected = @[box1, box3];
    GHAssertEqualContents(loadingDock.boxes, expected);
    GHAssertEqualContents(mainStorage.boxes, @[]);
    GHAssertEqualContents(rejectedBoxes, @[box2]);
}

- (void)testDifferentHazmatBoxesCanBeStoredInDifferentRoomsWhileStillRespectingSizeAndStairs {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemLoft, vault]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear | MHHazmatFlagsChemical];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box6 = [[MHBox alloc] initWithName:@"box6" andVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5, box6]];

    GHAssertEqualContents(loadingDock.boxes, @[]);
    NSArray *expected = @[box1, box5];
    GHAssertEqualContents(chemLoft.boxes, expected);
    expected = @[box2, box3, box4, box6];
    GHAssertEqualContents(vault.boxes, expected);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testBoxesAreNotPlacedSuchThatAHazmatWillHaveNoPlaceToGoWhenThereIsEnoughRoom {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];

    NSArray *expected = @[box1, box5];
    GHAssertEqualContents(vault.boxes, expected);
    expected = @[box2, box3, box4];
    GHAssertEqualContents(mainStorage.boxes, expected);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testOrderForBoxesIsPreservedWhenThereIsEnoughRoom {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithName:@"box1" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithName:@"box2" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithName:@"box3" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithName:@"box4" andVolumeInSquareMeters:30 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithName:@"box5" andVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];

    NSArray *expected = @[box1, box4, box5];
    GHAssertEqualContents(vault.boxes, expected);
    expected = @[box2, box3];
    GHAssertEqualContents(mainStorage.boxes, expected);
    GHAssertNil(rejectedBoxes, nil);
}

@end
