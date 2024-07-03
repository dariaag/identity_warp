// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMailbox {
    function dispatch(
        uint32 _destinationDomain,
        bytes32 _recipientAddress,
        bytes calldata _messageBody
    ) external returns (bytes32);

    function process(
        bytes calldata _metadata,
        bytes calldata _message
    ) external;
}

contract WarpIdentity {
    IMailbox mailbox;
    struct Identity {
        string name;
        address addr;
        bool verified;
    }

    mapping(address => Identity) public identities;

    event IdentitySubmitted(address indexed user, string name, address addr);
    event IdentityVerified(address indexed user);
    event IdentityDispatched(
        address indexed user,
        uint32 destinationDomain,
        bytes32 recipient
    );

    constructor(address _mailbox) {
        mailbox = IMailbox(_mailbox);
    }

    function submitIdentity(string memory name) public {
        require(
            bytes(identities[msg.sender].name).length == 0,
            "Identity already submitted"
        );
        identities[msg.sender] = Identity(name, msg.sender, false);
        emit IdentitySubmitted(msg.sender, name, msg.sender);
    }

    function verifyIdentity(bytes memory proof) public {
        require(proof.length != 0, "Proof not provided");

        require(
            bytes(identities[msg.sender].name).length != 0,
            "Identity not submitted"
        );
        require(!identities[msg.sender].verified, "Identity already verified");
        identities[msg.sender].verified = true;
        emit IdentityVerified(msg.sender);
    }

    function getIdentity(
        address user
    ) public view returns (string memory, address, bool) {
        Identity memory identity = identities[user];
        return (identity.name, identity.addr, identity.verified);
    }

    //dispatch message to the Hyperlane mailbox
    function warpSubmitIdentity(
        string memory name,
        uint32 destinationDomain,
        bytes32 recipient
    ) public {
        require(
            bytes(identities[msg.sender].name).length == 0,
            "Identity already submitted"
        );
        bytes memory message = abi.encode(name, msg.sender);
        //warpSend(destinationDomain, message);
        dispatch(destinationDomain, message, recipient);
    }

    function dispatch(
        uint32 destinationDomain,
        bytes memory message,
        bytes32 recipient
    ) internal {
        IMailbox(msg.sender).dispatch(destinationDomain, recipient, message);
        emit IdentityDispatched(msg.sender, destinationDomain, recipient);
    }

    //handle incoming message from the Hyperlane Router
    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata message
    ) external {
        (string memory name, address addr, address user) = abi.decode(
            message,
            (string, address, address)
        );
        identities[user] = Identity(name, addr, false);
        emit IdentitySubmitted(user, name, addr);
    }
}
