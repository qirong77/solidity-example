// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract EtherWallet {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    function deposit() external payable returns (bool) {
        require(msg.value > 0, "empty value");
        return true;
    }

    function withDraw(uint256 amount) external returns (bool success) {
        require(msg.sender == owner, "not owner");
        (success, ) = payable(msg.sender).call{value: amount}("");
        return success;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
