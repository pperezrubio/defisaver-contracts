pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../auth/AdminAuth.sol";
import "../actions/ActionInterface.sol";
import "./StrategyData.sol";

contract ActionRegistry is StrategyData, AdminAuth {

    struct ActionMetaData {
        string name;
        address contractAddr;
        bool active;
    }

    mapping (address => ActionMetaData) public registredActions;

    function callActions(Action[] memory actions) public returns (bool) {
        for(uint i = 0; i < actions.length; ++i) {
            require(isRegistred(actions[i].contractAddr), "Action contract not active/registred");


        }

        return true;
    }

    function isRegistred(address _contractAddr) public view returns (bool) {
        return registredActions[_contractAddr].active;
    }

    ////////////////////////////// ONLY OWNER FUNCTIONS //////////////////////////////

    function addTriggerContract(ActionMetaData memory _actionData) public onlyOwner {
        registredActions[_actionData.contractAddr] = _actionData;
    }

    function removeTriggerContract(address _contractAddr) public onlyOwner {
        delete registredActions[_contractAddr];
    }
}
