pragma solidity 0.4.24;

contract multisig{

    uint MAX_OWNERS = 50;

    struct Transaction{
        address destination;
        uint value;
        bytes data;
        bool executed;
        bool rejected;
    }

    /* 
    ---------------------------
    Mappings
    --------------------------- 
    */

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (uint => mapping (address => bool)) public rejections;
    mapping (address => bool) public isOwner;

    /* 
    ---------------------------
    Global variables
    --------------------------- 
    */

    uint public required;
    uint public transactionCount;
    address[] public owners;

    /* 
    ---------------------------
    Events
    --------------------------- 
    */

    event addOwner(address newOwner);
    event removedOwner(address oldOwner);
    event requirementChanged(uint required);
    event transactionSubmit(uint transactionId);
    event valueDeposited(address sender, uint value);
    event transactionConfirmed(address confirmer,uint transactionId)
    event transactionRejected(address confirmer,uint transactionId)
    event transactionExecuted(uint transactionId);
    event transactionNotExecuted(uint transactionId);

    /* 
    ---------------------------
    Modifiers
    --------------------------- 
    */
 
    modifier isNotAnOwner(address _owner){
        require(isOwner[_owner] == false, "Owner already exists");
        _;
    }

    modifier isAnOwner(address _owner){
        require(isOwner[_owner] == true, "Owner does not exist");
        _;
    }

    modifier notNull(address _address) {
        require(_address == 0, "Null Address");
        _;
    }

    modifier notRejected(uint _transactionId){
        require(transactions[transactionId].rejected == false, "Transaction has been rejected");
    }

    /*
    ---------------------------
    Functions
    ---------------------------
    */

     //check max length, check if address is valid
    constructor(address[] _owners, uint _required) public{
        for(uint i = 0; i<_owners.length; i++)
            isOwner[_owners[i]] = true;

        owners = _owners;
        required = _required;
    }


    // fallback function to deposit ethers
    function () payable public {
        if(msg.value > 0)
            emit valueDeposited(msg.sender,msg.value);
    }

    
    //check max length, check if owner does not already exists, check if address is valid
    function addNewOwner(address _owner) public notNull(_owner) isNotAnOwner(_owner) {
        isOwner[_owner] = true;
        owners.push(_owner);
        emit addOwner(_owner);
    }

    //check if owner exists
    function removeOwner(address _owner) public notNull(_owner) isAnOwner(_owner) {
        isOwner[_owner] = false;
        for(uint i = 0; i<owners.length; i++){
            if(owners[i] == _owner){
                owners[i] = owners[owners.length - 1];
                break;
            }
        }
        owners.length -= 1;
        if(required > owners.length)
            changeRequired(owners.length);
        emit removedOwner(_owner);
    }


    //check if owner exists, check if new owner does not exist
    function replaceOwner(address _owner, address _newOwner) public notNull(_owner) notNull(_newOwner) isAnOwner(_owner) isNotAnOwner(_newOwner) {
        for(uint i = 0; i<owners.length; i++){
            if(owners[i] == _owner){
                owners[i] = _newOwner;
                break;
            }

            isOwner[_owner] = false;
            isOwner[_newOwner] = true;
            emit removedOwner(_owner);
            emit addOwner(_newOwner);
        }
    }

    //check max length
    function changeRequired(uint _required) public{
        required = _required;
        emit requirementChanged(_required);
    }



    /*
    -------------------------------
    Transaction functions
    -------------------------------
    */


    function addTransaction(address _destination, uint _value, bytes _data) internal returns(uint){
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false,
            rejected: false
        });
        transactionCount += 1;
        emit transactionSubmit(transactionId);
        return transactionId;
    }

    function submitTransaction(address _destination, uint _value, bytes _data) public returns (uint) {
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
        return transactionId;
    }

    function confirmTransaction(uint transactionId) public isAnOwner(msg.sender) notRejected(transactionId){
        confirmations[transactionId][msg.sender] = true;
        rejections[transactionId][msg.sender] = false;
        emit transactionConfirmed(msg.sender, transactionId);
        executeTransaction(transactionId);
    }

    function revokeConfirmation(uint transactionId) public isAnOwner(msg.sender){
        confirmations[transactionId][msg.sender] = false;
        rejections[transactionId][msg.sender] = true;
        emit transactionRejected(msg.sender, transactionId);
    }

    function isConfirmed(uint transactionId) internal view returns (bool){
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }

    function isRejected(uint transactionId) public {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (rejections[transactionId][owners[i]])
                count += 1;
            if (count == required)
                transactions[transactionId].rejected = true;
        }
    }

    function executeTransaction(uint transactionId) public {
        if (isConfirmed(transactionId)) {
            Transaction tx = transactions[transactionId];
            tx.executed = true;
            if (tx.destination.call.value(tx.value)(tx.data))
                emit transactionExecuted(transactionId);
            else {
                emit transactionNotExecuted(transactionId);
                tx.executed = false;
            }
        }
    }


    /* 
    ---------------------------
    Data retrieval functions
    --------------------------- 
    */

    // get no. of confirmations for a transaction
    function getConfirmations(uint transactionId) public external view returns(uint){
        uint confirmationCount = 0
        
        for(uint i = 0; i < owners.length; i++)
        {
            if(confirmations[transactionId][owners[i]])
                confirmationCount += 1;
        }

        return confirmationCount;   
    }

    // return list of addresses of owners of the wallet
    function getOwners() public external view returns(address[]){
        return owners;
    }

    // return list of addresses of owners who have confirmed a transaction
    function getOwnerConfirmations(uint transactionId) public external view returns (address[])
    {
        address[] memory ownerConfirmationsTemp = new address[](owners.length);
        uint count = 0;
        for (uint i=0; i < owners.length; i++)
            if (confirmations[transactionId][owners[i]]) {
                ownerConfirmationsTemp[count] = owners[i];
                count += 1;
            }
        ownerConfirmations = new address[](count);
        for (uint i=0; i < count; i++)
            ownerConfirmations[i] = ownerConfirmationsTemp[i];

        return ownerConfirmations;
    }
}
