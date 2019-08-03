import "./factory.sol";
import "./multisig.sol";

contract multisigFactory is factory{
    
    function create(address[] _owners, uint _required) public returns (address)
    {
        address wallet = new multisig(_owners, _required);
        register(wallet);
    }
}