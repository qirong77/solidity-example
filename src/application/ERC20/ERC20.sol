// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
// import { IERC20 } from "./InterfaceERC20.sol";
contract ERC20 {
    uint private _totalSupply;
    mapping(address => uint) private _balanceMapping;
    string private _tokenName;
    mapping(address => mapping(address => uint)) private _allowance;
    constructor(string memory tokenName, uint totalSupply) {
        _tokenName = tokenName;
        _totalSupply = totalSupply;
    }
    function approve(address spender, uint amout) external returns (bool) {
        _allowance[msg.sender][spender] += amout;
        return true;
    }
    function transferFrom(address spender, address recipient, uint amout) external returns (bool) {
        _allowance[spender][msg.sender] -= amout;
        _balanceMapping[spender] -= amout;
        _balanceMapping[recipient] += amout;
        return true;
    }
    function _mint(address to, uint256 amount) internal {
        _balanceMapping[to] += amount;
        _totalSupply += amount;
    }
    function transfer(address to, uint amout) external returns (bool) {
        _balanceMapping[msg.sender] -= amout;
        _balanceMapping[to] += amout;
        return true;
    }
    function getTotalSupply() external view returns (uint) {
        return _totalSupply;
    }
    function getBalance(address ad) external view returns (uint) {
        return _balanceMapping[ad];
    }
}
