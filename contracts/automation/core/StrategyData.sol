pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

contract StrategyData {

    struct Trigger {
        address contractAddr;
        bytes data;
    }

    struct Action {
        address contractAddr;
        bytes data;
    }

    struct Strategy {
        Trigger[] triggers;
        Action[] actions;
        bool active;
    }
}
