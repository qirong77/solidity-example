// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
/* 
# 在remix中传入数组地址的参数
eg: ["0x123456789ABCDEF123456789ABCDEF123456789A", "0x987654321FEDCBA987654321FEDCBA987654321F"]
 */
contract MultiSignWallet {
    struct Transaction {
        address to;
        uint256 value;
        bytes data; // 如果交易的目标是一个合约，可以进行额外操作
        bool executed;
    }

    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;
    Transaction[] public transactions;
    mapping(address => mapping(uint256 => bool)) private _approveMapping;

    event Deposit(address indexed sender, uint256 amount);
    event Submit(uint256 indexed txId);
    event Approve(address indexed owner, uint256 indexed txId);
    event Revoke(address indexed owner, uint256 indexed txId);
    event Execute(uint256 indexed txId);

    modifier OnlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    modifier IsExists(uint256 id) {
        require(id < transactions.length, "not a transaction");
        _;
    }

    modifier NotExecuted(uint256 id) {
        require(!transactions[id].executed, "transaction already executed");
        _;
    }

    modifier NotApprove(uint256 id) {
        require(!_approveMapping[msg.sender][id], "already approved");
        _;
    }

    modifier IsApprove(uint256 id) {
        require(_approveMapping[msg.sender][id], "not approved");
        _;
    }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid required number");

        for (uint256 i = 0; i < _owners.length; i++) {
            address o = _owners[i];
            require(o != address(0), "invalid address");
            require(!isOwner[o], "repeated address");
            isOwner[o] = true;
            owners.push(o);
        }

        required = _required;
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }

    function approve(uint256 _txId) external OnlyOwner IsExists(_txId) NotExecuted(_txId) NotApprove(_txId) {
        _approveMapping[msg.sender][_txId] = true;
        emit Approve(msg.sender, _txId);

        if (getApprovalCount(_txId) >= required) {
            execute(_txId);
        }
    }

    function revoke(uint256 _txId) external OnlyOwner IsExists(_txId) NotExecuted(_txId) IsApprove(_txId) {
        _approveMapping[msg.sender][_txId] = false;
        emit Revoke(msg.sender, _txId);
    }

    function execute(uint256 _txId) internal IsExists(_txId) NotExecuted(_txId) {
        require(getApprovalCount(_txId) >= required, "not enough approvals");

        Transaction storage transaction = transactions[_txId];
        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(transaction.data);
        require(success, "transaction failed");

        emit Execute(_txId);
    }

    function submit(
        address _to,
        uint256 _value,
        bytes calldata _data
    ) external OnlyOwner {
        transactions.push(Transaction({to: _to, value: _value, data: _data, executed: false}));
        emit Submit(transactions.length - 1);
    }

    function getApprovalCount(uint256 _txId) public view returns (uint256) {
        uint256 count = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (_approveMapping[owners[i]][_txId]) {
                count++;
            }
        }
        return count;
    }
}
