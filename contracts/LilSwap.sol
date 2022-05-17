// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity =0.7.6;
pragma abicoder v2;

import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

/**
  * @author kenneth gabriel
  * @notice swapping tokens via Uniswap V3
*/
contract TestUinswap {
    IUniswapRouter public uniswapRouter;

    /// Available tokens to swap to
    mapping(string  => address) public tokens;

    constructor () {
        uniswapRouter = IUniswapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        tokens["DAI"]  = 0x4F96Fe3b7A6Cf9725f59d353F723c1bDb64CA6Aa;
        tokens["WETH"] = 0xd0A1E359811322d97991E03f863a0C30C2cF029C;
        tokens["USDC"] = 0xb7a4F3E9097C08dA09517b5aB877F7a917224ede;
    }

    /**
      * @notice checks if token `tokenName` exists in token mappings
      * @param tokenName is the name of the token
     */
    modifier tokenExists(string memory tokenName) {
        require(tokens[tokenName] != address(0), string(abi.encodePacked("token '", tokenName, "' does not exists")));
        _;
    }

    /**
      * @notice swaps WETH token to token `_tokenOut`. User calls function by sending
      * ETH (maximum) amount of ETH to be converted to `_tokenOut` 
      * @param _tokenOut is the name of token you want your sent eth to be converted to
      * @param _amountOut is the amount of `_tokenOut` sender would recieve
     */
    function swapToken(
        string memory _tokenOut, 
        uint _amountOut
    ) external payable tokenExists(_tokenOut)
    
    {
        require(_amountOut > 0, "invalid amountOut");
        require(msg.value > 0, "eth sent must be > 0");

        ISwapRouter.ExactOutputSingleParams memory params = ISwapRouter.ExactOutputSingleParams({
            tokenIn  : tokens["WETH"],
            tokenOut : tokens[_tokenOut],
            fee: 3000,
            recipient: msg.sender,
            deadline : block.timestamp + 15,
            amountOut: _amountOut,
            amountInMaximum  : msg.value,
            sqrtPriceLimitX96: 0
        });
        
        uint amountIn = uniswapRouter.exactOutputSingle{ value: msg.value }(params);

        // Refund remaining ETH to sender
        if (amountIn < msg.value) {
            (bool success,) = msg.sender.call{ value: address(this).balance }("");
            require(success, "refund failed");
        }
    }
}