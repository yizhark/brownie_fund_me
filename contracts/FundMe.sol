// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";



contract fund {
    
    mapping(address => uint256) public fundMap;
    address public owner;
    address[] public addresses;
    AggregatorV3Interface public priceFeed;
 
    // min $1
    uint256 minUSD = 1 * 10 ** 17;  // Add 17 decimals to $1 to compare with current convertETHToUSD units for Gwei


    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    modifier ownerAuth() {
        require (owner == msg.sender);
        _;
    }

    function fundMe() public payable {

        uint256 gweiValue = msg.value;// Convert wei to gwei:  / 10 ** 9;
        bytes memory err = abi.encodePacked("Give at least 1 buck, you paid ", uint2str(msg.value));
        require(convertETHToUSD(gweiValue) >= minUSD, string(err));
        fundMap[msg.sender] += gweiValue;

        for(uint256 add=0; add<addresses.length; add++) {
            if(msg.sender == addresses[add]) {
                return;
            }
        }
        addresses.push(msg.sender);
    }
    
    function getVersion() public view returns (uint256) {
        return priceFeed.version();     //  Kovan testNet
    }
    
    // USD price * 10 ** 8: if ETH price = $4129.52488772 then output will be: 412952488772.
    function getPrice() public view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer);
    }
    
    // Input in Gwei (= ETH * 10 ** 9). Output USD price * 10 ** 17 (for 1 Gwei: 412952488772 when ETH = $4129.52488772)
    function convertETHToUSD(uint256 gwei) public view returns (uint256) {
        uint256 price = getPrice(); // from price * 10 ** 8 (getPrice in 10 ** 8) to price * 10 ** 17 (Gwei = 10 ** 9) 
        return price * gwei;
    }

    function withdrawMoney() payable ownerAuth public {
        msg.sender.transfer(address(this).balance);

        for(uint256 add=0; add<addresses.length; add++) {
            fundMap[addresses[add]] = 0;
        }

        addresses = new address[](0);
    }

    // Min fee in Gwei
    function getEntranceFee() public view returns (uint256) {
        return minUSD / getPrice();
    }
    

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
         return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
         bstr[k--] = byte(uint8(48 + _i % 10));
         _i /= 10;
        }
        return string(bstr);
    }


}
