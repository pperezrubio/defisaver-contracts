pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "./StrategyData.sol";

contract Subscriptions is StrategyData {

    // if mcd-ratio for id #4545 is under 190%, repay to 220%

    mapping (address => uint[]) userStrategies;
    Strategy[] internal strategies;

    function subscribe(Strategy memory newStrategy) public {

    }

    function unsubscribe(Strategy memory newStrategy) public {

    }

    function getStrategy(uint _strategyId) public view returns (Strategy memory) {
        return strategies[_strategyId];
    }
}
