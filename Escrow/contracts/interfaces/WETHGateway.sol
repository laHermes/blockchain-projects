// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.7.5;

interface WETHGateway {
  function depositETH(    address lendingPool,
address onBehalfOf, uint16 referralCode) external payable;


  function withdrawETH(
    address lendingPool,
    uint256 amount,
    address to
  ) external;

  function repayETH(
    uint256 amount,
    uint256 rateMode,
    address onBehalfOf
  ) external payable;

  function borrowETH(
    uint256 amount,
    uint256 interesRateMode,
    uint16 referralCode
  ) external;
}