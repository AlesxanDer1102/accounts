// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

import {IAccount} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/IAccount.sol";
import {Transaction} from
    "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/MemoryTransactionHelper.sol";
import {SystemContractsCaller} from
    "lib/foundry-era-contracts/src/system-contracts/contracts/libraries/SystemContractsCaller.sol";
import {NONCE_HOLDER_SYSTEM_CONTRACT} from "lib/foundry-era-contracts/src/system-contracts/contracts/Constants.sol";
import {INonceHolder} from "lib/foundry-era-contracts/src/system-contracts/contracts/interfaces/INonceHolder.sol";
/**
 * Lifecyvle of a type 113 (0x71) transaction
 * msg.sender is the bootloader system contract
 *
 * Phase 1 Validation
 * 1. The user sends the transaction to the ZkSync API client (like a light node)
 * 2. The ZkSync API client checks to see the nonce is unique by querying the NonceHolder system contract
 * 3. The ZkSync API client call validateTransaction, which MUST update the nonce
 * 4. The ZkSync API client checks the nonce is updated
 * 5. The ZkSync API client calls payForTransaction, or prepareForPaymaster & validateAndPayForTransaction
 * 6. The ZkSync API client verifies that the bootloader gets paid
 *
 * Phase 2 Execution
 * 7. The ZkSync API client passes the validated transaction to the main node / sequencer (as of today,they are the same)
 * 8. The main node calls executeTransaction
 * 9. If a paymaster was used, the postTransaction is called
 */

contract ZkMinimalAccount is IAccount {
    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    /**
     * @notice must increase the nonce
     * @notice must validate the transaction (check the owner signed the transaction)
     * @notice also check if we ave enough money in our account
     */
    function validateTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
        returns (bytes4 magic)
    {
        // Call nonce holder and increment nonce
        // Call(x,y,z) -> system contract call
        SystemContractsCaller.systemCallWithPropagatedRevert(
            uint32(gasleft()), address(NONCE_HOLDER_SYSTEM_CONTRACT), 0, abi.encodeCall(INonceHolder.incrementMinNonceIfEquals,(_transaction.nonce))
        );
        
    }

    function executeTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    // There is no point in providing possible signed hash in the `executeTransactionFromOutside` method,
    // since it typically should not be trusted.
    function executeTransactionFromOutside(Transaction memory _transaction) external payable {}

    function payForTransaction(bytes32 _txHash, bytes32 _suggestedSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    function prepareForPaymaster(bytes32 _txHash, bytes32 _possibleSignedHash, Transaction memory _transaction)
        external
        payable
    {}

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
}
