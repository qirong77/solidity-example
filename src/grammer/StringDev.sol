// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract StringDev {
    function getStringLength(string memory s) external pure returns (uint256) {
        return bytes(s).length;
    }
    function concatTwoString() external pure returns (string memory){
        return string.concat("hello","world");
    }
}
