pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../auth/AdminAuth.sol";
import "../triggers/TriggerInterface.sol";
import "./StrategyData.sol";

contract TriggerRegistry is StrategyData, AdminAuth {

    struct TriggerMetaData {
        string name;
        address contractAddr;
        bool active;
    }

    mapping (address => TriggerMetaData) public registredTriggers;

    function isTriggerActive(Trigger[] memory triggers) public returns (bool) {
        for(uint i = 0; i < triggers.length; ++i) {
            require(isRegistred(triggers[i].contractAddr), "Trigger contract not active/registred");

            bool isTriggered = TriggerInterface(triggers[i].contractAddr).isTriggered(triggers[i].data);

            if (!isTriggered) return false;
        }

        return true;
    }

    function isRegistred(address _contractAddr) public view returns (bool) {
        return registredTriggers[_contractAddr].active;
    }

    ////////////////////////////// ONLY OWNER FUNCTIONS //////////////////////////////

    function addTriggerContract(TriggerMetaData memory _triggerData) public onlyOwner {
        registredTriggers[_triggerData.contractAddr] = _triggerData;
    }

    function removeTriggerContract(address _contractAddr) public onlyOwner {
        delete registredTriggers[_contractAddr];
    }
}
