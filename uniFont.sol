// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

/*
                 _  ______               __ 
  __  __ ____   (_)/ ____/____   ____   / /_
 / / / // __ \ / // /_   / __ \ / __ \ / __/
/ /_/ // / / // // __/  / /_/ // / / // /_  
\__,_//_/ /_//_//_/     \____//_/ /_/ \__/ v1

*/


// Open Zeppelin libraries for controlling upgradability and access.
import "@openzeppelin/contracts/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

//@dev uniFont contract
contract uniFont is Initializable, Ownable, UUPSUpgradeable {
    
    //@dev font mappings    
    mapping (uint => mapping(bytes => bytes)) public map;
    mapping (uint => mapping(bytes => bytes)) public key;
   
    //@dev set font 
    function setValue(uint index, string[] memory input, string[] memory output) public onlyOwner {
        for (uint256 i = 0; i < input.length; i++) {
        map[index][bytes(input[i])] = bytes(output[i]);
        key[index][bytes(output[i])] = bytes(input[i]);
        }
    }

    //@dev required by initializer module
    function initialize() public initializer {
        _transferOwnership(_msgSender());
    }

    //@dev required by UUPS module
    function _authorizeUpgrade(address) internal override onlyOwner {}

    //@dev obtain string length
    function strlen(string memory s) internal pure returns (uint) {
        uint len;
        uint i = 0;
        uint bytelength = bytes(s).length;
        for(len = 0; i < bytelength; len++) {
            bytes1 b = bytes(s)[i];
            if(b < 0x80) {
                i += 1;
            } else if (b < 0xE0) {
                i += 2;
            } else if (b < 0xF0) {
                i += 3;
            } else if (b < 0xF8) {
                i += 4;
            } else if (b < 0xFC) {
                i += 5;
            } else {
                i += 6;
            }
        }
        return len;
    }

    //@dev get character bytes
    function getChar(string memory _originString, uint point) internal pure returns (string memory){
        bytes memory CharByte = new bytes(1);
        CharByte[0] = bytes(_originString)[point];
        return string(CharByte);
    }

    //@dev format font
    function format(uint index, string memory arr) public view returns(string memory) {
        bytes[] memory ret = new bytes[](strlen(arr));
        bytes memory output;
        for (uint i = 0; i < strlen(arr); i++) {
            if (map[index][bytes(getChar(arr, i))].length > 0){
            ret[i] = map[index][bytes(getChar(arr, i))];
            output = abi.encodePacked(output, ret[i]);
            } else {
            output = abi.encodePacked(output, getChar(arr, i));
            }
        }
        return string(output);
    }

    //@dev reset font
    function reset(uint index, string memory arr) public view returns(string memory) {
        bytes[] memory ret = new bytes[](strlen(arr));
        bytes memory output;
        for (uint i = 0; i < strlen(arr); i++) {
            if (key[index][bytes(getChar(arr, i))].length > 0){
            ret[i] = key[index][bytes(getChar(arr, i))];
            output = abi.encodePacked(output, ret[i]);
            } else {
            output = abi.encodePacked(output, getChar(arr, i));
            }
        }
        return string(output);
    }
}
