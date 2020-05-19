pragma solidity ^0.6.0;

import "./TriggerInterface.sol";

contract McdRatioTrigger is TriggerInterface {

    struct ParamData {
        uint cdpId;
        uint ratio;
    }

    function parseParamData(bytes memory _data) public override {

    }

    function isTriggered(bytes memory _data) public override returns (bool) {
        return true;
    }
}
