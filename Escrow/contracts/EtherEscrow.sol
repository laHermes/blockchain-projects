//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.5;

import "./interfaces/IERC20.sol";
import "./interfaces/WETHGateway.sol";
import "./UserDatabase.sol";

contract EtherEscrow {
    address public arbiter;
    address public  depositor;
    address public beneficiary;
    uint public initialDeposit;

    uint64  public creationTime;
    uint64  public timeOfExpiration;

    UserDatabase userDb;
    IERC20 constant aWETH = IERC20(0x87b1f4cf9BD63f7BBD3eE1aD04E8F52540349347);
    WETHGateway constant gateway = WETHGateway(0xA61ca04DF33B72b235a8A28CfB535bb7A5271B70);
    address public constant lendingPool = 0xE0fBa4Fc209b4948668006B2bE61711b7f465bAe;

    bool locked;
    modifier noReentrancy() {
        require(!locked, "Expired Contract!");
        locked = true;
        timeOfExpiration = uint64(block.timestamp);
        _;
    }

      modifier onlyArbiter{
        require(msg.sender == arbiter, "Approve must be called by the arbiter!");
        _;
      }

      constructor(address _arbiter, address _beneficiary, address _userDatabase) payable {
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;
        initialDeposit = msg.value;
        
        userDb = UserDatabase(_userDatabase);
        userDb.addEscrow(address(this), _arbiter, msg.sender, _beneficiary);
        
        creationTime = uint64(block.timestamp);

        gateway.depositETH{value: msg.value}(lendingPool,address(this), 0);
      }

    receive() external payable {}

    function approve() external onlyArbiter noReentrancy{
        uint balance = aWETH.balanceOf(address(this));

        aWETH.approve(address(gateway), balance);
        gateway.withdrawETH(lendingPool, balance, address(this));

        (bool beneficiarySuccess,) = beneficiary.call{value: initialDeposit}("");
        require(beneficiarySuccess);

        (bool depositorSuccess,) = depositor.call{value: address(this).balance}("");
        require(depositorSuccess);
    }

    function getAwethBalance() external view returns(uint){
      return aWETH.balanceOf(address(this));
    }
}