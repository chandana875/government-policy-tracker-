// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract PolicyTracker {

    address public admin;
    uint public policyCount;

    constructor() {
        admin = msg.sender;
    }

    struct Policy {
        string policyHash;      // digital fingerprint
        string policyData;      // policy content / summary
        uint timestamp;         // when updated
        uint version;           // version number
        string previousHash;    // link to old version
        address approvedBy;     // who approved
    }

    mapping(uint => Policy) public policies;

    event PolicyAdded(
        uint id,
        string hash,
        address approvedBy
    );

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin allowed");
        _;
    }

    function addPolicy(string memory _data) public onlyAdmin {
        require(bytes(_data).length > 0, "Empty policy");

        policyCount++;

        string memory newHash = uintToString(
            uint(
                keccak256(
                    abi.encodePacked(
                        _data,
                        block.timestamp,
                        msg.sender,
                        policyCount
                    )
                )
            )
        );

        string memory prevHash = "";

        if (policyCount > 1) {
            prevHash = policies[policyCount - 1].policyHash;
        }

        policies[policyCount] = Policy({
            policyHash: newHash,
            policyData: _data,
            timestamp: block.timestamp,
            version: policyCount,
            previousHash: prevHash,
            approvedBy: msg.sender
        });

        emit PolicyAdded(policyCount, newHash, msg.sender);
    }

    function getPolicy(uint id)
        public
        view
        returns (Policy memory)
    {
        require(id > 0 && id <= policyCount, "Invalid ID");
        return policies[id];
    }

    function changeAdmin(address newAdmin) public onlyAdmin {
        require(newAdmin != address(0), "Invalid address");
        admin = newAdmin;
    }

    function uintToString(uint value)
        internal
        pure
        returns (string memory)
    {
        if (value == 0) {
            return "0";
        }

        uint temp = value;
        uint digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(
                uint8(48 + uint(value % 10))
            );
            value /= 10;
        }

        return string(buffer);
    }
}