// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TDDynamic is ERC721URIStorage, ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;

    uint256 constant TOKEN_ID = 1818;
    string constant RED_URI =
        "https://ipfs.io/ipfs/QmcarJ8yKwzEvTbqUmmHrQ7CRqkVsTxrwUTJTEhU5tgSfv";
    string constant WHITE_URI =
        "https://ipfs.io/ipfs/Qmcfnf546UR9LBVSzdBD2GcSKw893WwM3Nf5jWDwZdgERq";
    string constant GREEN_URI =
        "https://ipfs.io/ipfs/QmV9Bw6Q47LB2Wu4cLnqgQmyUKb6v2dPCjRiqNpqcq5Toi";

    // chainlink API
    bytes32 private immutable jobId;
    uint256 private immutable fee;

    // chainlink keepers
    uint256 public immutable interval;
    uint256 public lastTimeStamp = 0;

    // Rinkeby Testnet details
    constructor() ERC721("TDDynamic", "TDD") ConfirmedOwner(msg.sender) {
        setChainlinkToken(0x01BE23585060835E02B77ef475b0Cc51aA1e0709);
        setChainlinkOracle(0xf3FBB7f3391F62C8fe53f89B41dFC8159EE9653f);
        jobId = "ca98366cc7314957b8c012c72f05aeeb";
        fee = (1 * LINK_DIVISIBILITY) / 10; // 0.1 * 10**18

        interval = 1 hours;

        _safeMint(msg.sender, TOKEN_ID);
    }

    // receive the response
    function fulfill(bytes32 _requestId, int256 _changeHour)
        external
        recordChainlinkFulfillment(_requestId)
    {
        _setUri(_changeHour);
    }

    function update() external {
        if ((block.timestamp - lastTimeStamp) > interval) {
            lastTimeStamp = block.timestamp;
            requestData();
        }
    }

    function withdrawLink() external onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(
            link.transfer(msg.sender, link.balanceOf(address(this))),
            "Unable to transfer!"
        );
    }

    function requestData() private returns (bytes32 requestId) {
        Chainlink.Request memory req = buildChainlinkRequest(
            jobId,
            address(this),
            this.fulfill.selector
        );

        req.add(
            "get",
            "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=ETH&tsyms=USD"
        );

        req.add("path", "RAW,ETH,USD,VOLUME24HOUR");

        // multiply the result by 10**18 to remove decimals
        int256 timesAmount = 10**18;
        req.addInt("times", timesAmount);

        // sends the request
        return sendChainlinkRequest(req, fee);
    }

    function _setUri(int256 changeHour) private {
        if (changeHour > 0) _setTokenURI(TOKEN_ID, GREEN_URI);
        else if (changeHour < 0) _setTokenURI(TOKEN_ID, RED_URI);
        else _setTokenURI(TOKEN_ID, WHITE_URI);
    }
}
