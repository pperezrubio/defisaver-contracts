pragma solidity ^0.6.0;

import "../../auth/AdminAuth.sol";

contract AuthorizedCaller is AdminAuth {

    mapping (address => bool) public approvedCallers;

    modifier onlyAuthCallers {
        require(approvedCallers[msg.sender], "Must be authorized caller");
        _;
    }

    /// @notice Adds a new bot address which will be able to call repay/boost
    /// @param _caller Bot address
    function addCaller(address _caller) public onlyOwner {
        approvedCallers[_caller] = true;
    }

    /// @notice Removes a bot address so it can't call repay/boost
    /// @param _caller Bot address
    function removeCaller(address _caller) public onlyOwner {
        approvedCallers[_caller] = false;
    }

}
