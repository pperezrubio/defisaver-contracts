pragma solidity ^0.6.0;

import "../../interfaces/DSProxyInterface.sol";

contract AuthorizedProxy {

    function callExecute(address _proxy, address _actionAddr, bytes memory _data) public {
        DSProxyInterface(_proxy).execute(_actionAddr, _data);
    }

    // TODO: all the upgradable logic
}
