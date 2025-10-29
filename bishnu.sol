// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ProofOfPurchase {
    struct PurchaseRecord {
        address buyer;
        uint256 eventId;
        uint256 ticketId;
        uint256 timestamp;
        bytes32 txHash;
    }

    mapping(uint256 => PurchaseRecord) public records;
    uint256 public nextRecordId;

    event PurchaseRecorded(uint256 recordId, address buyer, uint256 eventId, uint256 ticketId);

    function recordPurchase(uint256 eventId, uint256 ticketId) external {
        uint256 recordId = nextRecordId++;
        records[recordId] = PurchaseRecord({
            buyer: msg.sender,
            eventId: eventId,
            ticketId: ticketId,
            timestamp: block.timestamp,
            txHash: keccak256(abi.encodePacked(msg.sender, eventId, ticketId, block.timestamp))
        });

        emit PurchaseRecorded(recordId, msg.sender, eventId, ticketId);
    }

    function verifyPurchase(uint256 recordId, address buyer)
        external
        view
        returns (bool)
    {
        return records[recordId].buyer == buyer;
    }
}
