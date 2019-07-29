pragma solidity 0.4.24;

contract multisig{

    uint MAX_OWNERS = 50;

    struct Transaction{
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    /* 
    ---------------------------
    Mappings
    --------------------------- 
    */

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
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
    event Deposit(address sender, uint value);

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


    // fallback function to deposit ethers
    function () payable public {
        if(msg.value > 0)
            emit Deposit(msg.sender,msg.value);
    }

    
    //check max length, check if address is valid
    constructor(address[] _owners, uint _required) public{
        for(uint i = 0; i<_owners.length; i++)
            isOwner[_owners[i]] = true;

        owners = _owners;
        required = _required;
    }

    //check max length, check if owner does not already exists, check if address is valid
    function addNewOwner(address _owner) isNotAnOwner(_owner) public{
        isOwner[_owner] = true;
        owners.push(_owner);
        emit addOwner(_owner);
    }

    //check if owner exists
    function removeOwner(address _owner) public{
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
    function replaceOwner(address _owner, address _newOwner) public{
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

    function addTransaction(address _destination, uint _value, bytes _data) internal returns(uint){
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: _destination,
            value: _value,
            data: _data,
            executed: false
        });
        transactionCount += 1;
        emit transactionSubmit(transactionId);
        return transactionId;
    }

    // function submitTransaction(address _destination, uint _value, bytes _data) public{
    // }



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
