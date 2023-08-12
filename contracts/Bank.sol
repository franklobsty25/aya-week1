// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract Bank {
    struct Saving {
        address owner;
        uint value;
        uint timestamp;
        uint withdrawTimestamp;
    }

    mapping(address => uint[]) private addressByTimestamps;
    mapping(address => Saving) private timestampBySavings;

    error UnauthorizedAmount(uint amount, address sender);
    error UnauthorizedWithdrawTime(uint withdrawTimestamp, address sender);
    error NoSavingsFound(address sender);
    error withdrawalFailed(uint timestamp, uint withdrawalTimestamp);

    modifier isValidSaving(uint withdrawTimestamp) {
        if (msg.value < 1) {
            revert UnauthorizedAmount(msg.value, msg.sender);
        }
        if (withdrawTimestamp > block.timestamp) {
            revert UnauthorizedWithdrawTime(withdrawTimestamp, msg.sender);
        }
        _;
    }

    modifier hasSavings() {
        if (addressByTimestamps[msg.sender].length < 1) {
            revert NoSavingsFound(msg.sender);
        }
        _;
    }

    modifier isWithdrawTime(uint timestamp) {
        Saving memory saving = timestampBySavings[msg.sender];

        if (
            saving.owner == msg.sender &&
            saving.withdrawTimestamp <= block.timestamp
        ) {
            _;
        } else {
            revert UnauthorizedWithdrawTime(
                saving.withdrawTimestamp,
                msg.sender
            );
        }
    }

    function save(
        uint withdrawTimestamp
    )
        public
        payable
        isValidSaving(withdrawTimestamp)
        returns (uint value, address timestamp, uint withdrwaTimestamp)
    {
        Saving memory saving = Saving({
            owner: msg.sender,
            value: msg.value,
            timestamp: block.timestamp,
            withdrawTimestamp: withdrawTimestamp
        });

        addressByTimestamps[msg.sender].push(value);
        timestampBySavings[timestamp] = saving;

        return (msg.value, timestamp, withdrawTimestamp);
    }

    function withdraw(
        uint savingTimestamp
    )
        public
        hasSavings
        isWithdrawTime(savingTimestamp)
        returns (uint value, uint savingsCount, uint savingsTimestamps)
    {
        Saving memory saving = timestampBySavings[msg.sender];
        delete timestampBySavings[msg.sender];

        for (uint i = 0; i < addressByTimestamps[msg.sender].length; i++) {
            if (addressByTimestamps[msg.sender][i] == savingTimestamp) {
                delete addressByTimestamps[msg.sender][i];
                break;
            }
        }

        (bool sent, ) = payable(msg.sender).call{value: saving.value}("");
        if (!sent) {
            revert withdrawalFailed(block.timestamp, saving.withdrawTimestamp);
        }

        return (
            saving.value,
            addressByTimestamps[msg.sender].length,
            savingsTimestamps
        );
    }

    function getSavings() public view returns (Saving[] memory savings) {
        Saving[] memory ownerSavings = new Saving[](
            addressByTimestamps[msg.sender].length
        );

        for (uint i = 0; i < addressByTimestamps[msg.sender].length; i++) {
            // uint timestamp = addressByTimestamps[msg.sender][i];
            Saving memory saving = timestampBySavings[ownerSavings[i].owner];
            ownerSavings[i] = (saving);
        }

        return ownerSavings;
    }
}
