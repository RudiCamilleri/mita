pragma solidity ^0.5.0;

//Version 0.01
//This interface serves to expose and document main contract functionality
//This is meant to be set in stone as much as possible after completion
interface TenderInterface {
	//Increments value
	function incrementValue() external returns (uint8);
}