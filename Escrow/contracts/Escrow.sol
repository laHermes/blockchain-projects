//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.5;

import "./interfaces/IERC20.sol";
import "./interfaces/ILendingPool.sol";
import "./UserDatabase.sol";

contract Escrow {
    address public arbiter;
    address public depositor;
    address public beneficiary;
    address public database;
    uint public  initialDeposit;

    uint public creationTime;
    uint public timeOfExpitarion;

    ILendingPool pool;
    IERC20 aDai;
    IERC20 dai;
    UserDatabase userDb;

    modifier onlyArbiter{
      require(msg.sender == arbiter, "Approve must be called by the arbiter!");
      _;
    }

    constructor(ILendingPool _pool, IERC20 _aDai, IERC20 _dai, address _arbiter, address _beneficiary, uint _amount, address _database) {
				pool = _pool;
				aDai = _aDai;
				dai = _dai;

        creationTime = block.timestamp;

        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = msg.sender;

        database = _database;
        userDb = UserDatabase(database);
        userDb.addEscrow(address(this), _arbiter, msg.sender, _beneficiary);

        initialDeposit = _amount;

        dai.transferFrom(msg.sender, address(this), _amount);
        dai.approve(address(pool), _amount);

        pool.deposit(address(dai), _amount, address(this), 0);
        
   	}

	 	event Approved();

  	function approve() external onlyArbiter {

        uint balance = aDai.balanceOf(address(this));

        aDai.approve(address(pool), balance);

        pool.withdraw(address(dai), initialDeposit, beneficiary);

        pool.withdraw(address(dai), type(uint).max, depositor);

        timeOfExpitarion = block.timestamp;

				emit Approved();
    }
}
