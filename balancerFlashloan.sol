// SPDX-License-Identifier: MIT
pragma solidity ^0.7.0;

import "@balancer-labs/v2-vault/contracts/interfaces/IVault.sol";
import "@balancer-labs/v2-vault/contracts/interfaces/IFlashLoanRecipient.sol";
import "https://github.com/Uniswap/v2-periphery/blob/master/contracts/interfaces/IUniswapV2Router02.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Factory.sol";
import "https://github.com/Uniswap/v2-core/blob/master/contracts/interfaces/IUniswapV2Pair.sol";


contract FlashLoanRecipient is IFlashLoanRecipient {
    address public owner;
    address _vault = 0xBA12222222228d8Ba445958a75a0704d566BF2C8;
    IVault vault = IVault(_vault);
    IUniswapV2Router02 uniRouter = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    IUniswapV2Router02 sushiRouter = IUniswapV2Router02(0x1b02dA8Cb0d097eB8D57A175b88c7D8b47997506);
    IUniswapV2Factory factory = IUniswapV2Factory(0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f);

    constructor (){
        owner = msg.sender;
    }


    function makeFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external {
      vault.flashLoan(this, tokens, amounts, userData);
    }


    event get_bal(address, uint256);
    
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        require(msg.sender == _vault);
        
        for (uint256 i = 0; i < tokens.length; ++i) {
            IERC20 token = tokens[i];
            uint256 amount = amounts[i];
            uint256 feeAmount = feeAmounts[i];

            emit get_bal(address(token), IERC20(token).balanceOf(address(this)));

            startArbitrage(address(token), amount);

            // Return loan
            token.transfer(_vault, amount+feeAmount);
        }
        
    }
    

    function startArbitrage(address fund, uint256 fromamount) internal{
        address fromtoken = fund;
        address totoken = 0x11fE4B6AE13d2a6055C8D9cF65c55bac32B5d844;   //DAI

        
        uint256 _beforeBalance = IERC20(totoken).balanceOf(address(this));
        
        //Uniswap
        IERC20(fund).approve(address(uniRouter), fromamount);
        address[] memory pathuni = new address[](2);
        pathuni[0] = fromtoken;
        pathuni[1] = totoken;
        uint256 received = uniRouter.swapExactTokensForTokens(
            fromamount,
            0,
            pathuni,
            address(this),
            block.timestamp + 1 hours
        )[1];
        IERC20(fund).approve(address(uniRouter), 0);

        uint256 _afterBalance = IERC20(totoken).balanceOf(address(this));
        uint256 toamount = _afterBalance - _beforeBalance;

        require(received>0, "dont get from uniswap");

        IERC20(totoken).approve(address(sushiRouter), toamount);
        address[] memory path = new address[](2);
        path[0] = totoken;
        path[1] = fromtoken;
        uint256 amountreceived = sushiRouter.swapExactTokensForTokens(
            toamount,
            fromamount,
            path,
            address(this),
            block.timestamp + 1 hours
        )[1];
    }

    function getbal(address token) public view returns(uint256){
        return IERC20(token).balanceOf(address(this));
    }

    function withdraw(address token) public OnlyOwner{
        IERC20(token).transfer(msg.sender, IERC20(token).balanceOf(address(this)));
    }
    modifier OnlyOwner{
        require(msg.sender == owner);
        _;
    }
}
            <ScrollPane fx:id="listframe" layoutX="21.0" layoutY="39.0" prefHeight="434.0" prefWidth="468.0" style="-fx-background-color: #303030; -fx-border-color: #303030;" stylesheets="@ScrollPane.css">
               <content>
                  <ListView fx:id="traders" editable="true" fixedCellSize="60.0" prefHeight="480.0" prefWidth="449.0" style="-fx-background-color: #303030; -fx-border-color: #303030;" stylesheets="@MenuListview.css">
                     <opaqueInsets>
                        <Insets bottom="5.0" />
                     </opaqueInsets></ListView>
               </content>
            </ScrollPane>