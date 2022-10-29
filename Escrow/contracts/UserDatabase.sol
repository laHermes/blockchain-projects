//SPDX-License-Identifier: Unlicense
pragma solidity ^0.7.5;


contract UserDatabase{
    
    event NewEscrow(address Beneficiary, address Depositor, address Arbiter, address EscrowAddress);

    mapping(address => address[]) public associations;
    address[] public escrowAddresses;

    function addEscrow(address _contractAddress, address _arbiter, address _depositor, address _beneficiary) external{
        associations[_arbiter].push(_contractAddress);
        associations[_depositor].push(_contractAddress);
        associations[_beneficiary].push(_contractAddress);
        escrowAddresses.push(_contractAddress);
        
        emit NewEscrow(_beneficiary, _depositor, _arbiter, _contractAddress);
  }

  function getAssociationsArray(address _addr) public view returns (address[] memory) {
      return associations[_addr];
  }

  function getEscrowAddresses() public view returns (address[] memory) {
      return escrowAddresses;
  }

}