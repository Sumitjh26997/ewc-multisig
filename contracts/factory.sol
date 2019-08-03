pragma solidity 0.4.24;

contract factory{

    mapping(address => bool) public isInstantiation;
    mapping(address => address[]) public instantiations;
    
    event contractInstantiation(address sender, address contract);

    function getInstantiationCount(address _creator) external view returns(uint){
        return instantiations[_creator].length;
    }

    function register(address instantiation) internal
    {
        isInstantiation[instantiation] = true;
        instantiations[msg.sender].push(instantiation);
        contractInstantiation(msg.sender, instantiation);
    }

}