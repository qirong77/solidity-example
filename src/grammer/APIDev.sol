// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract APIDev {
    // 编码函数：将多个参数编码为字节数组
    function encode(uint256 a, address b, string memory c) public pure returns (bytes memory) {
        return abi.encode(a, b, c);
    }

    // 解码函数：将字节数组解码为原始数据类型
    function decode(bytes memory data) public pure returns (uint256, address, string memory) {
        (uint256 a, address b, string memory c) = abi.decode(data, (uint256, address, string));
        return (a, b, c);
    }
}