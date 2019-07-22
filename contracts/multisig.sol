pragma solidity v0.4.24;

contract multisig{

    struct Transaction{
        address destination;
        uint value;
        bytes data;
        bool executed;
    }

    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    mapping (address => bool) public isOwner;
    uint public required;
    uint public transactionCount;
    address[] public owners;

    event addOwner(address newOwner);
    event removeOwner(address oldOwner);
    event requirementChanged(uint required);

    //check max length, check if address is valid
    function multisig(address[] _owners, uint _required) public{
        for(uint i = 0; i<_owners.length; i++)
            isOwner[_owners[i]] = true;

        owners = _owners;
        required = _required;
    }

    //check max length, check if owner does not already exists, check if address is valid
    function addNewOwner(address _owner) public{
        isOwner[_owner] = true;
        owners.push(_owner);
        addOwner(_owner);
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
        onwers.length -= 1;
        if(required > owners.length)
            changeRequired(owners.length);
        removeOwner(_owner);
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
            removeOwner(_owner);
            addOwner(_newOwner);
        }
    }

    //check max length
    function changeRequired(uint _required) public{
        required = _required;
        requirementChanged(_required);
    }

}
