// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "./DateTime.sol";

contract Price is ERC20, Ownable, Pausable{

    address private admin;

    mapping(uint256 => mapping(uint256 => mapping(uint256 => uint256))) dateToPrice;

    constructor() ERC20("Theia", "THEIA"){
        
        admin = msg.sender;
    }

    //Get the price of certain day
    function getDayPrice(uint256 year, uint256 month, uint256 day) public view returns (uint256){
        require (year >= 1970, "Not Valid");
        uint256 y1;
        uint256 m1;
        uint256 d1;
        uint256 day_price;

        (y1, m1, d1) = DateTime._daysToDate(DateTime._daysFromDate(year, month, day) - 1);
        day_price = dateToPrice[year][month][day] - dateToPrice[y1][m1][d1];

        return day_price;
    }

    //Set the price of certain day
    function setPriceDaily(uint256 price) external whenNotPaused onlyAdmin{
        uint256 year;
        uint256 month;
        uint256 day;

        (year, month, day) = DateTime.timestampToDate(block.timestamp);

        require(getDayPrice(year, month, day) == 0, "Already Set");

        dateToPrice[year][month][day] += price;
    }

    //Get the average price of certain period
    function getAvPrice(uint256 y1, uint256 m1, uint256 d1, uint256 y2, uint256 m2, uint256 d2) external view returns (uint256){

        uint256 delay;
        delay = DateTime._daysFromDate(y2, m2, d2) - DateTime._daysFromDate(y1, m1, d1);
        
        require (delay > 0, "NE");

        return (dateToPrice[y2][m2][d2] - dateToPrice[y1][m1][d1])/ delay;
    }


    modifier onlyAdmin {
        require(msg.sender == admin, "Not Admin");
        _;
    }

    //Set new admin address and only Contract Deployer can set it.
    function setNewAdmin(address addr) external onlyOwner{
        admin = addr;
    }
}