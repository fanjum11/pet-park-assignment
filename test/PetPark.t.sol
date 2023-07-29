// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/PetPark.sol";

// to run single test 
//forge test -vv  --match-test testBorrowCountDecrement

contract PetParkTest is Test, PetPark {
    PetPark petPark;
    
    address testOwnerAccount;

    address testPrimaryAccount;
    address testSecondaryAccount;

    function setUp() public {
        petPark = new PetPark();

        testOwnerAccount = msg.sender;
        testPrimaryAccount = address(0xABCD);
        testSecondaryAccount = address(0xABDC);
    }

    function testOwnerCanAddAnimal() public {
        petPark.add(AnimalType.Fish, 5);
    }

    function testCannotAddInvalidAnimal() public {
        vm.expectRevert("Invalid animal");
        petPark.add(AnimalType.None, 5);
    }



    function testExpectEmitAddEvent() public {
        vm.expectEmit(false, false, false, true);

        emit Added(AnimalType.Fish, 5);
        petPark.add(AnimalType.Fish, 5);
    }


    function testCannotBorrowUnavailableAnimal() public {
        vm.expectRevert("Selected animal not available");

        petPark.borrow(Gender.Male, 24, AnimalType.Fish);
    }

    function testCannotBorrowInvalidAnimal() public {
        vm.expectRevert("Invalid animal type");

        petPark.borrow(Gender.Male, 24, AnimalType.None);
    }

    function testCannotBorrowCatForMen() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(Gender.Male, 24, AnimalType.Cat);
    }

    function testCannotBorrowRabbitForMen() public {
        petPark.add(AnimalType.Rabbit, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(Gender.Male, 24, AnimalType.Rabbit);
    }

    function testCannotBorrowParrotForMen() public {
        petPark.add(AnimalType.Parrot, 5);

        vm.expectRevert("Invalid animal for men");
        petPark.borrow(Gender.Male, 24, AnimalType.Parrot);
    }

    function testCannotBorrowForWomenUnder40() public {
        petPark.add(AnimalType.Cat, 5);

        vm.expectRevert("Invalid animal for women under 40");
        petPark.borrow(Gender.Female, 24, AnimalType.Cat);
    }

    function testCannotBorrowTwiceAtSameTime() public {
        petPark.add(AnimalType.Fish, 5);
        petPark.add(AnimalType.Cat, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(Gender.Male, 24, AnimalType.Fish);

		vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(Gender.Male, 24, AnimalType.Fish);

        vm.expectRevert("Already adopted a pet");
        vm.prank(testPrimaryAccount);
        petPark.borrow(Gender.Male, 24, AnimalType.Cat);
    }

    function testCannotBorrowWhenAddressDetailsAreDifferent() public {
        petPark.add(AnimalType.Fish, 5);

        vm.prank(testPrimaryAccount);
        petPark.borrow(Gender.Male, 24, AnimalType.Fish);

		vm.expectRevert("Invalid Age");
        vm.prank(testPrimaryAccount);
        // PROBABLY I AM TAKING THE EASY WAY OUT BY CHANGING AGE TO 0 here
        petPark.borrow(Gender.Male, 23, AnimalType.Fish);

		vm.expectRevert("Invalid Gender");
        vm.prank(testPrimaryAccount);
        petPark.borrow(Gender.Female, 24, AnimalType.Fish);
    }

    function testExpectEmitOnBorrow() public {
        petPark.add(AnimalType.Fish, 5);
        vm.expectEmit(false, false, false, true);

        emit Borrowed(AnimalType.Fish);
        petPark.borrow(Gender.Male, 24, AnimalType.Fish);
    }

    function testCannotGiveBack() public {
        vm.expectRevert("No borrowed pets");
        petPark.giveBackAnimal();
    }

    function testPetCountIncrement() public {
        petPark.add(AnimalType.Fish, 5);

        petPark.borrow(Gender.Male, 24, AnimalType.Fish);
        uint reducedPetCount = petPark.animalCounts(AnimalType.Fish);

        petPark.giveBackAnimal();
        uint currentPetCount = petPark.animalCounts(AnimalType.Fish);

		assertEq(reducedPetCount, currentPetCount - 1);
    }

    // 1. Test that any non-owner account cannot add animals using the add function
    function testCannotAddAnimalWhenNonOwner() public {
        vm.expectRevert("Only contract owner can access this function.");
        vm.prank(testPrimaryAccount);
        petPark.add(AnimalType.Fish, 5);
    }

    // 2. Test that the borrow function fails when called with an age equal to 0.
    function testCannotBorrowWhenAgeZero() public {
        vm.expectRevert("Invalid Age");
        petPark.borrow(Gender.Male, 0, AnimalType.Fish);
    }

    // 3. Test that the count of animal decreases correctly when the borrow function is called.
    function testBorrowCountDecrement() public {
        petPark.add(AnimalType.Fish, 5);

        // Borrow an animal
        petPark.borrow(Gender.Male, 24, AnimalType.Fish);
        uint256 reducedPetCount = petPark.animalCounts(AnimalType.Fish);

        // Print the reducedPetCount value
        console.log("Reduced Pet Count console:", reducedPetCount);

        // Emit event for reducedPetCount
        emit log_uint(reducedPetCount);

        // Give back the animal
        petPark.giveBackAnimal();
        uint256 currentPetCount = petPark.animalCounts(AnimalType.Fish);

        // Print the currentPetCount value
        console.log("Current Pet Count console:", currentPetCount);

        // Emit event for currentPetCount
        emit LogValue("Current Pet Count", currentPetCount);

        // Assert that the counts are equal
        assertEq(reducedPetCount, currentPetCount-1, "reducedPetCount and currentPetCount are not equal.");

        //assertEq(reducedPetCount, currentPetCount);
    }

    event LogValue(string message, uint256 value);

}
