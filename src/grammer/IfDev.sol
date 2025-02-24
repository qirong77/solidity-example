// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract IfDev {
    mapping(address => bool) m;
    function ifMapping() external view  returns (bool) {
        if (m[msg.sender]) {
            return true;
        }
        return m[msg.sender];
    }
}
