pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./StrategyData.sol";
import "./AuthorizedCaller.sol";
import "./TriggerRegistry.sol";

contract Executor is AuthorizedCaller, StrategyData {

    address constant public TRIGGER_REGISTRY = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
    address constant public ACTION_REGISTRY = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    // TODO:

    function callStrategy(Strategy calldata _strategy) external onlyAuthCallers {
        //TODO: burn gas tokens

        // check if triggers are true
        bool triggered = TriggerRegistry(TRIGGER_REGISTRY).triggersActivated(_strategy.triggers);
        require(triggered, "Triggers arent active");

        // call actions
        // for (uint i = 0; i < _strategy.actions.length; ++i) {

        // }

        //TODO: logs
    }
}
