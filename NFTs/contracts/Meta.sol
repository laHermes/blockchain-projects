// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

// https://github.com/0xProject/0x-monorepo/blob/development/contracts/exchange/contracts/src/MixinTransactions.sol

contract Meta {
    address public currentContextAddress;

    struct Transaction {
        uint256 salt;
        uint256 expirationSeconds;
        uint256 gasPrice;
        address signerAddress;
        bytes data;
    }

    bytes32 EIP712_TRANSACTION_SCHEMA_HASH =
        keccak256(
            abi.encodePacked(
                "Transaction(uint256 salt,uint256 expirationSeconds,uint256 gasPrice,address signerAddress,bytes data)"
            )
        );

    function _getTransactionTypedHash(Transaction memory _transaction)
        private
        view
        returns (bytes32)
    {
        return
            keccak256(
                abi.encodePacked(
                    EIP712_TRANSACTION_SCHEMA_HASH,
                    _transaction.salt,
                    _transaction.expirationSeconds,
                    _transaction.gasPrice,
                    uint256(uint160(_transaction.signerAddress)),
                    keccak256(_transaction.data)
                )
            );
    }

    // set correct msg.sender
    function _setCurrentContextAddress(address _contextAddress) private {
        currentContextAddress = _contextAddress;
    }

    function _getCurrentContextAddress() private view returns (address) {
        return
            currentContextAddress == address(0)
                ? msg.sender
                : currentContextAddress;
    }

    // transaction only on this contract & chain id
    function _getFullTransactionTypedHash(Transaction memory _transaction)
        private
        view
        returns (bytes32)
    {
        bytes32 transactionHash = _getTransactionTypedHash(_transaction);
        uint256 chainId;

        assembly {
            chainId := chainId
        }

        bytes32 EIP191_HEADER = 0x1901000000000000000000000000000000000000000000000000000000000000;
        bytes32 schemaHash = keccak256(
            abi.encodePacked(
                "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
            )
        );

        address verifyingContract = address(this);

        bytes32 domainHash = keccak256(
            abi.encodePacked(
                schemaHash,
                keccak256(bytes("Meta Faucet")),
                keccak256(bytes("1.0.0")),
                chainId,
                verifyingContract
            )
        );

        return
            keccak256(
                abi.encodePacked(EIP191_HEADER, domainHash, transactionHash)
            );
    }

    function _isTransactionHashSignatureValid(
        Transaction memory _transaction,
        bytes32 _txHash,
        bytes memory _signature
    ) private pure returns (bool) {
        require(_signature.length == 66, "MetaFaucet: Signature invalid");

        uint8 v = uint8(_signature[0]);
        bytes32 r = _readBytes32(_signature, 1);
        bytes32 s = _readBytes32(_signature, 33);
        address recovered = ecrecover(_txHash, v, r, s);

        return _transaction.signerAddress == recovered;
    }

    function _readBytes32(bytes memory b, uint256 index)
        private
        pure
        returns (bytes32 result)
    {
        require(b.length >= 32, "MetaFaucet: Invalid bytes length");
        index += 32;
        assembly {
            result := mload(add(b, index))
        }

        return result;
    }
}
