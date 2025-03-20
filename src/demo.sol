// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract UniswapV2Like {
    using SafeMath for uint256;

    // 代币A和代币B，假设他们都是ERC20代币
    IERC20 public tokenA;
    IERC20 public tokenB;

    // 流动性提供者的质押份额（类似LP代币）
    mapping(address => uint256) public shares;
    uint256 public totalShares;

    // 资金池余额
    uint256 public reserveA;
    uint256 public reserveB;

    // 系统参数：交易手续费千分之几
    uint256 public swapFee = 3; // 0.3%

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event Swap(address indexed user, uint256 amountIn, uint256 amountOut);

    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    // 添加流动性
    function addLiquidity(uint256 amountA, uint256 amountB) external {
        require(amountA > 0 && amountB > 0, "Amounts must be >0");

        // 收取代币A和代币B
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transferFrom(msg.sender, address(this), amountB);

        // 计算份额
        uint256 shares_;
        if (totalShares == 0) {
            shares_ = amountA; // 初始份额
        } else {
            shares_ = amountA.mul(totalShares).div(reserveA);
            require(amountB.mul(totalShares) >= shares_.mul(reserveB), "Insufficient balance");
        }

        // 更新余额和份额
        reserveA = reserveA.add(amountA);
        reserveB = reserveB.add(amountB);
        shares[msg.sender] = shares[msg.sender].add(shares_);
        totalShares = totalShares.add(shares_);

        emit LiquidityAdded(msg.sender, amountA, amountB);
    }

    // 移除流动性
    function removeLiquidity(uint256 _shares) external {
        require(_shares > 0, "Shares must be >0");
        require(shares[msg.sender] >= _shares, "Insufficient shares");

        // 计算对应代币数量
        uint256 amountA = reserveA.mul(_shares).div(totalShares);
        uint256 amountB = reserveB.mul(_shares).div(totalShares);

        // 返回代币
        tokenA.transfer(msg.sender, amountA);
        tokenB.transfer(msg.sender, amountB);

        // 更新余额和份额
        reserveA = reserveA.sub(amountA);
        reserveB = reserveB.sub(amountB);
        shares[msg.sender] = shares[msg.sender].sub(_shares);
        totalShares = totalShares.sub(_shares);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    // 代币A兑换代币B
    function swapAtoB(uint256 amountA) external {
        require(amountA > 0, "Amount must be >0");

        // 计算代币B的输出量（带手续费）
        uint256 inputAvailable = amountA.sub(amountA.mul(swapFee).div(1000)); // 0.3%手续费
        uint256 outputB = computeOutput(inputAvailable, reserveA, reserveB);

        // 更新余额
        reserveA = reserveA.add(amountA);
        reserveB = reserveB.sub(outputB);

        // 转移代币
        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transfer(msg.sender, outputB);

        emit Swap(msg.sender, amountA, outputB);
    }

    // 代币B兑换代币A
    function swapBtoA(uint256 amountB) external {
        require(amountB > 0, "Amount must be >0");

        // 计算代币A的输出量（带手续费）
        uint256 inputAvailable = amountB.sub(amountB.mul(swapFee).div(1000));
        uint256 outputA = computeOutput(inputAvailable, reserveB, reserveA);

        // 更新余额
        reserveB = reserveB.add(amountB);
        reserveA = reserveA.sub(outputA);

        // 转移代币
        tokenB.transferFrom(msg.sender, address(this), amountB);
        tokenA.transfer(msg.sender, outputA);

        emit Swap(msg.sender, amountB, outputA);
    }

    // 计算代币兑换输出量（恒定乘积公式：x*y=k）
    function computeOutput(uint256 input, uint256 inputReserve, uint256 outputReserve) internal pure returns (uint256) {
        require(inputReserve > 0 && outputReserve > 0, "Reserves must be >0");

        uint256 numerator = input.mul(inputReserve);
        uint256 denominator = outputReserve.add(input);
        return numerator / denominator;
    }
}