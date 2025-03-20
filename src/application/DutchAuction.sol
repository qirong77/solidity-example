// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract DutchAuction {
    address public seller; // 卖家地址
    uint256 public startingPrice; // 起始价格
    uint256 public reservePrice; // 保留价格
    uint256 public duration; // 拍卖持续时间
    uint256 public startedAt; // 拍卖开始时间
    bool public isSold; // 是否已售出

    event AuctionEnded(address winner, uint256 price);

    constructor(
        uint256 _startingPrice,
        uint256 _reservePrice,
        uint256 _duration
    ) {
        require(_startingPrice > _reservePrice, "Starting price must be higher than reserve price");
        require(_duration > 0, "Duration must be greater than 0");

        seller = msg.sender;
        startingPrice = _startingPrice;
        reservePrice = _reservePrice;
        duration = _duration;
        startedAt = block.timestamp;
        isSold = false;
    }

    function getCurrentPrice() public view returns (uint256) {
        uint256 elapsed = block.timestamp - startedAt;
        if (elapsed >= duration) {
            return reservePrice;
        } else {
            return startingPrice - ((startingPrice - reservePrice) * elapsed / duration);
        }
    }

    function buy() external payable {
        require(!isSold, "Auction is already sold");
        require(block.timestamp <= startedAt + duration, "Auction has ended");

        uint256 price = getCurrentPrice();
        require(msg.value >= price, "Not enough ETH sent");

        isSold = true;
        payable(seller).transfer(msg.value);

        emit AuctionEnded(msg.sender, price);
    }

    function withdraw() external {
        require(msg.sender == seller, "Only seller can withdraw");
        require(isSold, "Auction is not sold yet");

        payable(seller).transfer(address(this).balance);
    }
}