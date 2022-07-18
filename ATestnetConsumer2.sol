// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@chainlink/contracts/src/v0.8/ChainlinkClient.sol';
import '@chainlink/contracts/src/v0.8/ConfirmedOwner.sol';

contract ATestnetConsumer2 is ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    // uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY; // 1 * 10**18
    uint256 private constant ORACLE_PAYMENT = 1 * LINK_DIVISIBILITY / 10; // 1 * 10**18 / 10
    string public thatAddress;
    event RequestEthereumPriceFulfilled(bytes32 indexed requestId, string indexed thatAddress);
    event RequestEthereumPriceFulfilledPre();

    /**
     *  Rinkeby
     *@dev LINK address in Rinkeby network: 0x01BE23585060835E02B77ef475b0Cc51aA1e0709
     * @dev Check https://docs.chain.link/docs/link-token-contracts/ for LINK address for the right network
     */
    constructor() ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
    }

    function requestMyFunction2(address _oracle, 
        string memory _jobId, 
        string memory _nftAddress,
        string memory _tokenId,
        string memory _chain ) public onlyOwner {
        Chainlink.Request memory req = buildChainlinkRequest(
            stringToBytes32(_jobId),
            address(this),
            this.fulfill.selector
        );
        req.add('adddress', _nftAddress);
        req.add('tokenId', _tokenId);
        req.add('chain', _chain);
        sendChainlinkRequestTo(_oracle, req, ORACLE_PAYMENT);
    }

    function fulfill(bytes32 _requestId, string calldata _value) public recordChainlinkFulfillment(_requestId) {
        emit RequestEthereumPriceFulfilledPre();
        thatAddress = _value;
        emit RequestEthereumPriceFulfilled(_requestId, thatAddress);
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), 'Unable to transfer');
    }

    function cancelRequest(
        bytes32 _requestId,
        uint256 _payment,
        bytes4 _callbackFunctionId,
        uint256 _expiration
    ) public onlyOwner {
        cancelChainlinkRequest(_requestId, _payment, _callbackFunctionId, _expiration);
    }

    function stringToBytes32(string memory source) private pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            // solhint-disable-line no-inline-assembly
            result := mload(add(source, 32))
        }
    }
}
