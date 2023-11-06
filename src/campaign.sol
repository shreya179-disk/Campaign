// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Campaign {
    struct Request {
        string description;
        uint value;
        address payable recipient;
        bool complete;
        uint approvalCount;
    }

    Request[] public requests;
    address public manager;
    uint public minimumContribution;
    mapping(address => bool) public approvers;
    mapping(uint => mapping(address => bool)) public approvals;
    uint public approversCount;

    modifier restricted() {
        require(msg.sender == manager, "Not allowed to initiate this");
        _;
    }

    constructor(uint minimum) {
        manager = msg.sender;
        minimumContribution = minimum;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution, "Not enough contributed");
        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string memory description, uint value, address payable recipient) public restricted {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });
        
        requests.push(newRequest);
    }

    function approveRequest(uint index) public {
        require(approvers[msg.sender], "Sender is not an approved contributor");
        require(!approvals[index][msg.sender], "Sender has already approved this request");

        approvals[index][msg.sender] = true;
        requests[index].approvalCount++;
    }

    function finaliseRequest(uint index)public restricted{
        require(requests[index].approvalCount > approversCount * 7/10);
        require(!requests[index].complete,"request has not been approved");
        requests[index].recipient.transfer(requests[index].value);
        requests[index].complete = true;
        
    }
}