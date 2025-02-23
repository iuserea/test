pragma solidity ^0.8.0;

contract ReEntrancyGuard {
    bool internal locked;

    modifier noReentrant() {
        require(!locked, "No re-entrancy");
        locked = true;
        _;
        locked = false;
    }
}

contract SimpleBank is ReEntrancyGuard {
    mapping(address => uint256) public balances;

    function deposit() public payable noReentrant {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) public noReentrant {
        // Checks: Ensure that the user has enough balance to withdraw the requested amount
        require(balances[msg.sender] >= amount, "Insufficient balance");

        // Effects: Update the user's balance
        balances[msg.sender] -= amount;

        // Interactions: Transfer the requested amount to the user
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Withdrawal failed");
    }
}