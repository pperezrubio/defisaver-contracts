pragma solidity ^0.6.0;
pragma experimental ABIEncoderV2;

import "../../exchange/SaverExchangeCore.sol";
import "../../utils/GasBurner.sol";
import "../../flashloan/aave/ILendingPool.sol";
import "./CompoundSaverProxy.sol";
import "../../flashloan/FlashLoanLogger.sol";
import "../../auth/ProxyPermission.sol";

/// @title Entry point for the FL Repay Boosts, called by DSProxy
contract CompoundFlashLoanTaker is CompoundSaverProxy, ProxyPermission, GasBurner {
    ILendingPool public constant lendingPool = ILendingPool(0x398eC7346DcD622eDc5ae82352F02bE94C62d119);

    address payable public constant COMPOUND_SAVER_FLASH_LOAN = 0x632cfd9245B7A4692F03b3D562Ed01E5cff94898;

    // solhint-disable-next-line const-name-snakecase
    FlashLoanLogger public constant logger = FlashLoanLogger(
        0xb9303686B0EE92F92f63973EF85f3105329D345c
    );

    /// @notice Repays the position with it's own fund or with FL if needed
    function repayWithLoan(
        SaverExchangeCore.ExchangeData memory _exchangeData,
        address _cCollAddress,
        address _cBorrowAddress,
        uint gasCost
        // uint[5] calldata _data, // amount, minPrice, exchangeType, gasCost, 0xPrice
        // address[3] calldata _addrData, // cCollAddress, cBorrowAddress, exchangeAddress
        // bytes memory _callData
    ) public payable burnGas(25) {
        uint maxColl = getMaxCollateral(_cCollAddress, address(this));

        if (_exchangeData.srcAmount <= maxColl) {
            repay(_exchangeData, _cCollAddress, _cBorrowAddress, gasCost);
        } else {
            // 0x fee
            COMPOUND_SAVER_FLASH_LOAN.transfer(msg.value);

            uint loanAmount = (_exchangeData.srcAmount - maxColl);
            bytes memory paramsData = abi.encode(_exchangeData, _cCollAddress, _cBorrowAddress, gasCost, true, address(this));

            givePermission(COMPOUND_SAVER_FLASH_LOAN);

            lendingPool.flashLoan(COMPOUND_SAVER_FLASH_LOAN, getUnderlyingAddr(_cCollAddress), loanAmount, paramsData);

            removePermission(COMPOUND_SAVER_FLASH_LOAN);

            logger.logFlashLoan("CompoundFlashRepay", loanAmount, _exchangeData.srcAmount, _cCollAddress);
        }
    }

    /// @notice Boosts the position with it's own fund or with FL if needed
    function boostWithLoan(
        SaverExchangeCore.ExchangeData memory _exchangeData,
        address _cCollAddress,
        address _cBorrowAddress,
        uint gasCost
    ) public payable burnGas(20) {
        uint maxBorrow = getMaxBorrow(_cBorrowAddress, address(this));

        if (_exchangeData.srcAmount <= maxBorrow) {
            boost(_exchangeData, _cCollAddress, _cBorrowAddress, gasCost);
        } else {
            // 0x fee
            COMPOUND_SAVER_FLASH_LOAN.transfer(msg.value);

            uint loanAmount = (_exchangeData.srcAmount - maxBorrow);
            bytes memory paramsData = abi.encode(_exchangeData, _cCollAddress, _cBorrowAddress, gasCost, false, address(this));

            givePermission(COMPOUND_SAVER_FLASH_LOAN);

            lendingPool.flashLoan(COMPOUND_SAVER_FLASH_LOAN, getUnderlyingAddr(_cBorrowAddress), loanAmount, paramsData);

            removePermission(COMPOUND_SAVER_FLASH_LOAN);

            logger.logFlashLoan("CompoundFlashBoost", loanAmount, _exchangeData.srcAmount, _cBorrowAddress);
        }

    }

}
