pragma solidity ^0.5.0;

import "../../interfaces/DSProxyInterface.sol";

/// @title Implements logic for calling MCDSaverProxy always from same contract
contract MCDMonitorProxyV2 {

    uint public CHANGE_PERIOD;
    address public monitor;
    address public owner;
    address public newMonitor;
    address public lastMonitor;
    address public admin;
    uint public changeRequestedTimestamp;

    mapping(address => bool) public allowed;

    event MonitorChangeInitiated(address oldMonitor, address newMonitor);
    event MonitorChangeCanceled();
    event MonitorChangeFinished(address monitor);
    event MonitorChangeReverted(address monitor);

    // if someone who is allowed become malicious, owner can't be changed
    modifier onlyAllowed() {
        require(allowed[msg.sender] || msg.sender == owner);
        _;
    }

    modifier onlyMonitor() {
        require (msg.sender == monitor);
        _;
    }

    constructor(uint _changePeriod) public {
        owner = msg.sender;
        CHANGE_PERIOD = _changePeriod * 1 days;
    }

    /// @notice Admin is set by owner first time, after that admin is super role and has permission to change owner
    /// @param _admin Address of multisig that becomes admin
    function setAdminByOwner(address _admin) public {
        require(msg.sender == owner);
        require(_admin == address(0));

        admin = _admin;
    }

    /// @notice Admin is able to set new admin
    /// @param _admin Address of multisig that becomes new admin
    function setAdminByAdmin(address _admin) public {
        require(msg.sender == admin);

        admin = _admin;
    }

    /// @notice Admin is able to change owner
    /// @param _owner Address of new owner
    function setOwnerByAdmin(address _owner) public {
        require(msg.sender == admin);

        owner = _owner;
    }

    /// @notice Admin is able to set change period to any value
    /// @param _periodInDays Period in representing days needed to complete change of new monitor
    function setChangePeriodByAdmin(uint _periodInDays) public {
        require(msg.sender == admin);

        CHANGE_PERIOD = _periodInDays * 1 days;
    }

    /// @notice Allowed users are able to set Monitor contract without any waiting period first time
    /// @param _monitor Address of Monitor contract
    function setMonitor(address _monitor) public onlyAllowed {
        require(monitor == address(0));
        monitor = _monitor;
    }

    /// @notice Only monitor contract is able to call execute on users proxy
    /// @param _owner Address of cdp owner (users DSProxy address)
    /// @param _saverProxy Address of MCDSaverProxy
    /// @param _data Data to send to MCDSaverProxy
    function callExecute(address _owner, address _saverProxy, bytes memory _data) public onlyMonitor {
        // execute reverts if calling specific method fails
        DSProxyInterface(_owner).execute(_saverProxy, _data);
    }

    /// @notice Allowed users are able to start procedure for changing monitor
    /// @dev after CHANGE_PERIOD needs to call confirmNewMonitor to actually make a change
    /// @param _newMonitor address of new monitor
    function changeMonitor(address _newMonitor) public onlyAllowed {
        require(changeRequestedTimestamp == 0);

        changeRequestedTimestamp = now;
        lastMonitor = monitor;
        newMonitor = _newMonitor;

        emit MonitorChangeInitiated(lastMonitor, newMonitor);
    }

    /// @notice At any point allowed users are able to cancel monitor change
    function cancelMonitorChange() public onlyAllowed {
        require(changeRequestedTimestamp > 0);

        changeRequestedTimestamp = 0;
        newMonitor = address(0);

        emit MonitorChangeCanceled();
    }

    /// @notice Anyone is able to confirm new monitor after CHANGE_PERIOD if process is started
    function confirmNewMonitor() public onlyAllowed {
        require((changeRequestedTimestamp + CHANGE_PERIOD) < now);
        require(changeRequestedTimestamp != 0);
        require(newMonitor != address(0));

        monitor = newMonitor;
        newMonitor = address(0);
        changeRequestedTimestamp = 0;

        emit MonitorChangeFinished(monitor);
    }

    /// @notice Its possible to revert monitor to last used monitor
    function revertMonitor() public onlyAllowed {
        require(lastMonitor != address(0));

        monitor = lastMonitor;

        emit MonitorChangeReverted(monitor);
    }


    /// @notice Allowed users are able to add new allowed user
    /// @param _user Address of user that will be allowed
    function addAllowed(address _user) public onlyAllowed {
        allowed[_user] = true;
    }

    /// @notice Allowed users are able to remove allowed user
    /// @dev owner is always allowed even if someone tries to remove it from allowed mapping
    /// @param _user Address of allowed user
    function removeAllowed(address _user) public onlyAllowed {
        allowed[_user] = false;
    }

    function setChangePeriod(uint _periodInDays) public onlyAllowed {
        require(_periodInDays * 1 days > CHANGE_PERIOD);

        CHANGE_PERIOD = _periodInDays * 1 days;
    }
}
