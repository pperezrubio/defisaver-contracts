pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../exchange/SaverExchangeCore.sol";
import "../../loggers/CompoundLogger.sol";
import "../helpers/CompoundSaverHelper.sol";

/// @title Contract that implements repay/boost functionality
contract CompoundSaverProxy is CompoundSaverHelper, SaverExchangeCore {

    /// @notice Withdraws collateral, converts to borrowed token and repays debt
    /// @dev Called through the DSProxy
    function repay(
        SaverExchangeCore.ExchangeData memory _exchangeData,
        address _cCollAddress,
        address _cBorrowAddress,
        uint gasCost
        // uint[5] memory _data, // amount, minPrice, exchangeType, gasCost, 0xPrice
        // address[3] memory _addrData, // cCollAddress, cBorrowAddress, exchangeAddress
        // bytes memory _callData
    ) public payable {
        enterMarket(_cCollAddress, _cBorrowAddress);

        address payable user = address(uint160(getUserAddress()));

        uint maxColl = getMaxCollateral(_cCollAddress, address(this));

        uint collAmount = (_exchangeData.srcAmount > maxColl) ? maxColl : _exchangeData.srcAmount;

        require(CTokenInterface(_cCollAddress).redeemUnderlying(collAmount) == 0);

        address collToken = getUnderlyingAddr(_cCollAddress);
        address borrowToken = getUnderlyingAddr(_cBorrowAddress);

        (, uint swapAmount) = _sell(_exchangeData);

        swapAmount -= getFee(swapAmount, user, gasCost, _cBorrowAddress);

        paybackDebt(swapAmount, _cBorrowAddress, borrowToken, user);

        // handle 0x fee
        user.transfer(address(this).balance);

        CompoundLogger(COMPOUND_LOGGER).LogRepay(user, _exchangeData.srcAmount, swapAmount, collToken, borrowToken);
    }

    /// @notice Borrows token, converts to collateral, and adds to position
    /// @dev Called through the DSProxy
    function boost(
        SaverExchangeCore.ExchangeData memory _exchangeData,
        address _cCollAddress,
        address _cBorrowAddress,
        uint gasCost
        // uint[5] memory _data, // amount, minPrice, exchangeType, gasCost, 0xPrice
        // address[3] memory _addrData, // cCollAddress, cBorrowAddress, exchangeAddress
        // bytes memory _callData
    ) public payable {
        enterMarket(_cCollAddress, _cBorrowAddress);

        address payable user = address(uint160(getUserAddress()));

        uint maxBorrow = getMaxBorrow(_cBorrowAddress, address(this));
        uint borrowAmount = (_exchangeData.srcAmount > maxBorrow) ? maxBorrow : _exchangeData.srcAmount;

        require(CTokenInterface(_cBorrowAddress).borrow(borrowAmount) == 0);

        address collToken = getUnderlyingAddr(_cCollAddress);
        address borrowToken = getUnderlyingAddr(_cBorrowAddress);

        borrowAmount -= getFee(borrowAmount, user, gasCost, _cBorrowAddress);

        (, uint swapAmount) = _sell(_exchangeData);

        approveCToken(collToken, _cCollAddress);

        if (collToken != ETH_ADDRESS) {
            require(CTokenInterface(_cCollAddress).mint(swapAmount) == 0);
        } else {
            CEtherInterface(_cCollAddress).mint{value: swapAmount}(); // reverts on fail
        }

        // handle 0x fee
        user.transfer(address(this).balance);

        CompoundLogger(COMPOUND_LOGGER).LogBoost(user, _exchangeData.srcAmount, swapAmount, collToken, borrowToken);
    }

}
