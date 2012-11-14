#import <GHUnitIOS/GHTestCase.h>
#import "MHWarehouse.h"
#import "MHRoom.h"
#import "MHBox.h"
#import "MHHazmatFlags.h"

@interface MHWarehouseTest : GHTestCase {
    MHRoom *loadingDock;
    MHRoom *mainStorage;
    MHRoom *chemStorage;
    MHRoom *chemLoft;
    MHRoom *basement;
    MHRoom *microWMDStorage;
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
    microWMDStorage = [[MHRoom alloc] initWithName:@"Micro Weapons of Mass Destruction Containment Unit" andCapacityInSquareMeters:100 andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear requiresStairs:NO];
    vault = [[MHRoom alloc] initWithName:@"Valut" andCapacityInSquareMeters:150 andHazmatFlags:MHHazmatFlagsChemical | MHHazmatFlagsNuclear requiresStairs:NO];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testWhenOneBoxIsAddedToOneRoomThenTheRoomContainsTheBox {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];
    
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1]];
    
    GHAssertEqualObjects(loadingDock.boxes, @[box1], nil);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxesAreAddedThenTheyAreAddedToFirstRoomFirstUntilCapacityIsReached {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:70 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:15 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box3];
    GHAssertEqualObjects(loadingDock.boxes, expected, nil);
    GHAssertEqualObjects(mainStorage.boxes, @[box4], nil);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxOver50VolumeIsLoadedThenItIsNotLoadedInARoomRequiringStairs {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[basement, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:51 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box4];
    GHAssertEqualObjects(basement.boxes, expected, nil);
    GHAssertEqualObjects(mainStorage.boxes, @[box3], nil);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenBoxesExceedCapacityThenFinalBoxesAreRejected {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:40 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:40 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:40 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4]];

    NSArray *expected = @[box1, box2, box4];
    GHAssertEqualObjects(loadingDock.boxes, expected, nil);
    GHAssertEqualObjects(rejectedBoxes, @[box3], nil);
}

- (void)testWhenChemicalBoxIsLoadedItIsLoadedInSafeRoom {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemStorage]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];

    NSArray *expected = @[box1, box3];
    GHAssertEqualObjects(loadingDock.boxes, expected, nil);
    GHAssertEqualObjects(chemStorage.boxes, @[box2], nil);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testWhenHazmatHasNoSafeRoomThenItIsRejected {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNone];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3]];

    NSArray *expected = @[box1, box3];
    GHAssertEqualObjects(loadingDock.boxes, expected, nil);
    GHAssertEqualObjects(mainStorage.boxes, @[], nil);
    GHAssertEqualObjects(rejectedBoxes, @[box2], nil);
}

- (void)testDifferentHazmatBoxesCanBeStoredInDifferentRoomsWhileStillRespectingSizeAndStairs {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[loadingDock, chemLoft, vault]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear];
    MHBox *box4 = [[MHBox alloc] initWithVolumeInSquareMeters:10 andHazmatFlags:MHHazmatFlagsNuclear | MHHazmatFlagsChemical];
    MHBox *box5 = [[MHBox alloc] initWithVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];
    MHBox *box6 = [[MHBox alloc] initWithVolumeInSquareMeters:50 andHazmatFlags:MHHazmatFlagsChemical];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5, box6]];

    GHAssertEqualObjects(loadingDock.boxes, @[], nil);
    NSArray *expected = @[box1, box5];
    GHAssertEqualObjects(chemLoft.boxes, expected, nil);
    expected = @[box2, box3, box4, box6];
    GHAssertEqualObjects(vault.boxes, expected, nil);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testBoxesAreNotPlacedSuchThatAHazmatWillHaveNoPlaceToGoWhenThereIsEnoughRoom {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];

    NSArray *expected = @[box1, box5];
    GHAssertEqualObjects(vault.boxes, expected, nil);
    expected = @[box2, box3, box4];
    GHAssertEqualObjects(mainStorage.boxes, expected, nil);
    GHAssertNil(rejectedBoxes, nil);
}

- (void)testOrderForBoxesIsPreservedWhenThereIsEnoughRoom {
    MHWarehouse *testObject = [[MHWarehouse alloc] initWithRooms:@[vault, mainStorage]];
    MHBox *box1 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box2 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box3 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box4 = [[MHBox alloc] initWithVolumeInSquareMeters:30 andHazmatFlags:MHHazmatFlagsNone];
    MHBox *box5 = [[MHBox alloc] initWithVolumeInSquareMeters:60 andHazmatFlags:MHHazmatFlagsChemical];

    NSArray *rejectedBoxes = [testObject addBoxes:@[box1, box2, box3, box4, box5]];

    NSArray *expected = @[box1, box4, box5];
    GHAssertEqualObjects(vault.boxes, expected, nil);
    expected = @[box2, box3];
    GHAssertEqualObjects(mainStorage.boxes, expected, nil);
    GHAssertNil(rejectedBoxes, nil);
}


@end
