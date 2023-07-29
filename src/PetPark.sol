// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    enum AnimalType { None, Dog, Cat, Fish, Rabbit, Parrot }
    enum Gender { Male, Female }

    struct Borrower {
        PetPark.AnimalType animalBorrowed;
        bool hasBorrowed;
        uint8 age;
    }

    address public owner;
    mapping(address => Borrower) public borrowers;
    mapping(AnimalType => uint256) public animalCountsMapping;  // To store the counts of different types of animals


    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can access this function.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    event Added(PetPark.AnimalType animalType, uint256 animalCount);
    event Borrowed(PetPark.AnimalType animalType);
    event Returned(PetPark.AnimalType animalType);

    function add(PetPark.AnimalType _animalType, uint256 _animalCount) public onlyOwner {
        require(_animalType != PetPark.AnimalType.None, "Invalid animal");
        emit Added(_animalType, _animalCount);

        // Update the count of the added animal type
        animalCountsMapping[_animalType] += _animalCount;

        // Add the implementation to shelter animals in our park
        // ...
    }

    function borrow(Gender _gender, uint8 _age, PetPark.AnimalType _animalType) public {
        // Check if the address has called this function before using other values for Gender and Age
        //require(borrowers[msg.sender].age == _age, "Invalid Age");
        require(!borrowers[msg.sender].hasBorrowed, "Already adopted a pet");
        require(_animalType != PetPark.AnimalType.None, "Invalid animal type");
        require(_age > 0, "Invalid age");

        // Check borrowing eligibility based on Age and Gender
        if (_gender == Gender.Male) {
            require(_animalType == PetPark.AnimalType.Dog || _animalType == PetPark.AnimalType.Fish, "Invalid animal for men");
        } else {
            if (_age < 40) {
                require(_animalType != PetPark.AnimalType.Cat, "Invalid animal for women under 40");
            }
        }

        // Decrease the count of the borrowed animal type
        require(animalCountsMapping[_animalType] > 0, "Selected animal not available");
        animalCountsMapping[_animalType]--;

        // Mark the user as having borrowed and track the animal type borrowed
        borrowers[msg.sender].hasBorrowed = true;
        borrowers[msg.sender].animalBorrowed = _animalType;
        borrowers[msg.sender].age = _age; // Store the borrower's age


        emit Borrowed(_animalType);
    }

    function giveBackAnimal() public {
        // Throw an error if the user hasn't borrowed before
        require(borrowers[msg.sender].hasBorrowed, "No borrowed pets");

        // Get the borrowed animal type
        PetPark.AnimalType borrowedAnimal = borrowers[msg.sender].animalBorrowed;

        // Mark the user as no longer having borrowed
        borrowers[msg.sender].hasBorrowed = false;
        animalCountsMapping[borrowedAnimal]++;

        emit Returned(borrowedAnimal);
    }

    // Renamed the function to "animalCounts" to match your request
    function animalCounts(PetPark.AnimalType _animalType) public view returns (uint256) {
        return animalCountsMapping[_animalType];
    }

}