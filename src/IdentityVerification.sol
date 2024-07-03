// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Router} from "./contracts/client/Router.sol";

contract IdentityVerification is Router {
    struct Identity {
        string name;
        string dob; // Date of birth
        bool verified;
    }

    mapping(address => Identity) public identities;

    event IdentitySubmitted(address indexed user, string name, string dob);
    event IdentityVerified(address indexed user);

    function submitIdentity(string memory name, string memory dob) public {
        require(
            bytes(identities[msg.sender].name).length == 0,
            "Identity already submitted"
        );
        identities[msg.sender] = Identity(name, dob, false);
        emit IdentitySubmitted(msg.sender, name, dob);
    }

    function verifyIdentity(address user) public {
        require(
            bytes(identities[user].name).length != 0,
            "Identity not submitted"
        );
        require(!identities[user].verified, "Identity already verified");
        identities[user].verified = true;
        emit IdentityVerified(user);
    }

    function getIdentity(
        address user
    ) public view returns (string memory, string memory, bool) {
        Identity memory identity = identities[user];
        return (identity.name, identity.dob, identity.verified);
    }

    // Hyperlane Warp Router Integration
    function warpSubmitIdentity(
        string memory name,
        string memory dob,
        uint32 destinationDomain
    ) public {
        require(
            bytes(identities[msg.sender].name).length == 0,
            "Identity already submitted"
        );
        bytes memory message = abi.encode(name, dob, msg.sender);
        warpSend(destinationDomain, message);
    }

    function handle(
        uint32 origin,
        bytes32 sender,
        bytes calldata message
    ) external override {
        (string memory name, string memory dob, address user) = abi.decode(
            message,
            (string, string, address)
        );
        identities[user] = Identity(name, dob, false);
        emit IdentitySubmitted(user, name, dob);
    }
}
