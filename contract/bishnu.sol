// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/*
 * 🪩 Simple Decentralized Event Ticketing System
 * Features:
 *  - Organizer creates event
 *  - Users buy tickets
 *  - Contract records proof of purchase (who bought which ticket)
 */

contract Ticketing {
    // Event structure
    struct Event {
        string name;
        uint256 date;
        uint256 price;
        uint256 ticketsAvailable;
        address organizer;
        bool isActive;
    }

    // Each event gets an ID (starting from 0)
    uint256 public nextEventId;

    // Maps event ID to its Event struct
    mapping(uint256 => Event) public events;

    // Maps buyer address => event ID => number of tickets bought
    mapping(address => mapping(uint256 => uint256)) public ticketsBought;

    // Log when tickets are purchased
    event TicketPurchased(address indexed buyer, uint256 eventId, uint256 quantity, uint256 totalPaid);

    // Log when an event is created
    event EventCreated(uint256 eventId, string name, uint256 price, uint256 ticketsAvailable);

    // Organizer creates an event
    function createEvent(
        string memory _name,
        uint256 _date,
        uint256 _price,
        uint256 _ticketsAvailable
    ) external {
        require(_date > block.timestamp, "Date must be in the future");
        require(_ticketsAvailable > 0, "Must have at least one ticket");

        events[nextEventId] = Event({
            name: _name,
            date: _date,
            price: _price,
            ticketsAvailable: _ticketsAvailable,
            organizer: msg.sender,
            isActive: true
        });

        emit EventCreated(nextEventId, _name, _price, _ticketsAvailable);
        nextEventId++;
    }

    // Buy tickets for a specific event
    function buyTicket(uint256 _eventId, uint256 _quantity) external payable {
        Event storage myEvent = events[_eventId];

        require(myEvent.isActive, "Event not active");
        require(block.timestamp < myEvent.date, "Event already happened");
        require(_quantity > 0, "Need at least 1 ticket");
        require(_quantity <= myEvent.ticketsAvailable, "Not enough tickets left");
        require(msg.value == myEvent.price * _quantity, "Incorrect Ether sent");

        myEvent.ticketsAvailable -= _quantity;
        ticketsBought[msg.sender][_eventId] += _quantity;

        // Send payment to organizer
        payable(myEvent.organizer).transfer(msg.value);

        emit TicketPurchased(msg.sender, _eventId, _quantity, msg.value);
    }

    // Verify proof of purchase (on-chain check)
    function hasPurchased(address _buyer, uint256 _eventId) external view returns (bool) {
        return ticketsBought[_buyer][_eventId] > 0;
    }
}
