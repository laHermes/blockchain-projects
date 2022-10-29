// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CustomReward {
    address public immutable tokenAddress;
    uint256 public rewardRatePerSecond = 33;
    uint256 public totalDeposits;

    uint256[] public dates = new uint256[](4);

    enum Dates {
        DAY_QUARTER,
        DAY_HALF,
        DAY,
        DAY_TWO
    }

    struct Deposit {
        uint256 id;
        address owner;
        uint256 startDate;
        uint256 endDate;
        uint256 expectedReward;
    }

    Deposit[] public deposits;

    mapping(address => uint256[]) public ownerToDepositId;
    mapping(address => Deposit[]) public ownerToDeposits;

    event DepostiAdded(
        uint256 id,
        address owner,
        uint256 indexed startDate,
        uint256 indexed endDate,
        uint256 indexed expectedReward
    );

    constructor(address _tokenAddress) {
        tokenAddress = _tokenAddress;
        dates[0] = 6 hours;
        dates[1] = 12 hours;
        dates[2] = 1 days;
        dates[3] = 2 days;
    }

    function depostiAssets(uint256 _amount, Dates _date)
        external
        returns (bool)
    {
        totalDeposits += 1;
        uint256 reward = rewardRatePerSecond * dates[uint256(_date)];
        uint256 endDate = block.timestamp + dates[uint256(_date)];

        Deposit memory depo = Deposit(
            totalDeposits,
            msg.sender,
            block.timestamp,
            endDate,
            reward
        );

        ownerToDeposits[msg.sender].push(depo);

        bool success = IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
        require(success, "CustomReward: Token Transfer Failed");
        emit DepostiAdded(
            totalDeposits,
            msg.sender,
            block.timestamp,
            endDate,
            reward
        );
        return true;
    }

    function getDeposits(address _owner)
        public
        view
        returns (Deposit[] memory)
    {
        return ownerToDeposits[_owner];
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
