// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.2 <0.9.0;
contract IterationDev {
    function forIteration() external pure  returns(uint[] memory) {
        uint[] memory array = new uint[](10);
        for (uint i = 0; i < array.length; i++) {
            array[i] += i;
        }
        return  array;
    }
}
