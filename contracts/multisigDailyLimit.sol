pragma solidity 0.4.24;
import "./multisig.sol";

contract multisigDailyLimit is multisig {

    event dailyLimitChange(uint dailyLimit);

    uint public dailyLimit;
    uint public lastDay;
    uint public spentToday;

    function executeTransaction(uint TransactionId) public {
        bool confirmed = isConfirmed()
    }

}
