
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;
interface IAnimal {
    function makeSound() external view returns (string memory);
}
abstract contract Animal {
    function describe() public virtual returns (string memory){
        return "this is an animal";
    }
}
contract Dog is Animal, IAnimal {
    function makeSound() public pure override(IAnimal) returns(string memory){
        return "Wow";
    }
    function describe() public pure override(Animal) returns(string memory) {
        return "this is dog";
    }
}