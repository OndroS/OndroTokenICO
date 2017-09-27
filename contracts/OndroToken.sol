pragma solidity ^0.4.15;

import 'zeppelin-solidity/contracts/token/ERC20Basic.sol';
import 'zeppelin-solidity/contracts/token/StandardToken.sol';


contract OndroTokenIco is StandardToken {
    using SafeMath for uint256;

    string public name = "Nazov Tokeny";
    string public symbol = "SYMBOL";
    uint256 public decimals = 18;

    uint256 public totalSupply = 1000000 * (uint256(10) ** decimals);
    uint256 public totalRaised; // celková raisovaná suma vyjadrená vo wei

    uint256 public startTimestamp = 1506420013; // timestamp kód po ktorom ICO bude spustené
    uint256 public durationSeconds = 4 * 7 * 24 * 60 * 60; // 4 týždne

    uint256 public minCap = 1; // minimálna cieľová suma (wei)
    uint256 public maxCap = 1;// maximálna cieľová suma (wei)

    /**
     * Adresa ktorá získa všetky vyzbierané prostriedky
     * a zároveň vlastní všetky tokeny
     */
    address public fundsWallet = 0xb4F3422761CF46b868A48e269114784876d67966;/*Tu daj svoju vlastnú adresu*/

    function OndroTokenIco(
        /*address _fundsWallet,*/
        /*uint256 _startTimestamp,
        uint256 _minCap,
        uint256 _maxCap) {
        fundsWallet = _fundsWallet;
        startTimestamp = _startTimestamp;
        minCap = _minCap;
        maxCap = _maxCap;*/

        // prideľ všetky tokeny do uvedenej adresy
        balances[fundsWallet] = totalSupply;
        Transfer(0x0, fundsWallet, totalSupply);
    }

    function() isIcoOpen payable {
        totalRaised = totalRaised.add(msg.value);

        uint256 tokenAmount = calculateTokenAmount(msg.value);
        balances[fundsWallet] = balances[fundsWallet].sub(tokenAmount);
        balances[msg.sender] = balances[msg.sender].add(tokenAmount);
        Transfer(fundsWallet, msg.sender, tokenAmount);

        // okamžite preveď do uvedenej adresy
        fundsWallet.transfer(msg.value);
    }

    function calculateTokenAmount(uint256 weiAmount) constant returns(uint256) {
        // štandardný konverzný pomer: 1 ETH : 50 DRB
        uint256 tokenAmount = weiAmount.mul(50);
        if (now <= startTimestamp + 7 days) {
            // +50% bonus počas prvého týždňa
            return tokenAmount.mul(150).div(100);
        } else {
            return tokenAmount;
        }
    }

    function transfer(address _to, uint _value) isIcoFinished returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) isIcoFinished returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    modifier isIcoOpen() {
        require(now >= startTimestamp);
        require(now <= (startTimestamp + durationSeconds) || totalRaised < minCap);
        require(totalRaised <= maxCap);
        _;
    }

    modifier isIcoFinished() {
        require(now >= startTimestamp);
        require(totalRaised >= maxCap || (now >= (startTimestamp + durationSeconds) && totalRaised >= minCap));
        _;
    }
}
