pragma solidity ^0.4.0;

contract PlayGame {
    int uNumTest = 0; // test
    uint xor = 0; // 保存异或的值
    uint [] randomNum; // 保存传入的随机数
    address [] dragon;  // 保存选龙的地址
    mapping(address => uint) dragonMap; // 选龙用户的下注金额 需要清空
    address [] tiger;   // 保存选虎的地址
    mapping(address => uint) tigerMap; // 选虎用户的下注金额
    address [] draw;    // 保存选合的地址
    mapping(address => uint) drawMap; // 选合用户的下注金额
    uint time = 0; // 保存上一次结算时出块时间戳
    uint totalCoins = 0; // 当前局下注总币
    uint historyTotalCoins = 0; // 历史下注总币
    uint dragonCoins = 0; // 下注龙总币
    uint tigerCoins = 0; // 下注虎总币
    uint drawCoins = 0; // 下注合总币
    uint [] resultHistory; // 保存历史结果
    uint [] currentResult = [0, 0]; // 保存当前局结算后的龙虎值
    // 在全局获取的msg.sender为创建者的地址
    // 在函数中获取的msg.sender为当前调用者的地址
    // 函数中返回的this指当前合约地址
    address creator = msg.sender;
    uint [] price;
    // 返回是否下注成功
    event returnBetResult(bool _bool);
    // 返回最终结果

    function deposit() payable {

    }

    function PlayGame(uint price1, uint price2, uint price3, uint _type){
        price = [price1, price2, price3, _type];
    }
    // 获取自己设置的下注金额列表
    function getPrice() constant returns (uint []){
        return price;
    }

    function getBlockTime() constant returns (uint, uint, uint, address, uint [], int){
        return (time, block.timestamp, xor, creator, currentResult, uNumTest);
    }
    // 获取最后五局的结果
    function getResultHistory() constant returns (uint []){
        return resultHistory;
    }

    // 下注传入信息
    // 如果下注金额大于当前奖池金额，返回false，下注失败
    function sendBetInfo(address addr, uint cho, uint ran, uint coin) payable {
        totalCoins += coin;
        deposit();
        if (getCurrentBalance() / 10 < totalCoins) {
            totalCoins -= coin;
            transferCoin(addr, coin);
            returnBetResult(false);
        } else {
            historyTotalCoins += coin;
            if (cho == 0) {
                bool flag0 = false;
                for (uint i = 0; i < dragon.length; i++) {
                    if (dragon[i] == addr) {
                        flag0 = true;
                        break;
                    }
                }
                if (!flag0) {
                    dragon.push(addr);
                }
                // dragonMap[addr] = dragonMap[addr] == 0 ? (dragonMap[addr] + coin) : coin;
                dragonMap[addr] = dragonMap[addr] + coin;
                dragonCoins += coin;
            } else if (cho == 1) {
                bool flag1 = false;
                for (uint j = 0; j < tiger.length; j++) {
                    if (tiger[j] == addr) {
                        flag1 = true;
                        break;
                    }
                }
                if (!flag1) {
                    tiger.push(addr);
                }
//                tigerMap[addr] = tigerMap[addr] == 0 ? (tigerMap[addr] + coin) : coin;
                tigerMap[addr] = tigerMap[addr] + coin;
                tigerCoins += coin;
            } else if (cho == 2) {
                bool flag2 = false;
                for (uint k = 0; k < draw.length; k++) {
                    if (draw[i] == addr) {
                        flag2 = true;
                        break;
                    }
                }
                if (!flag2) {
                    draw.push(addr);
                }
//                drawMap[addr] = drawMap[addr] == 0 ? (drawMap[addr] + coin) : coin;
                drawMap[addr] = drawMap[addr] + coin;
                drawCoins += coin;
            }
            randomNum.push(ran);
            returnBetResult(true);
        }
    }

    // 异或函数,得到结果随机数
    function xorFun() public {
        for (uint i = 0; i < randomNum.length; i++) {
            xor = xor ^ randomNum[i];
        }
        xor = xor ^ (uint256(keccak256(block.difficulty, now)) % 1000000000000);
    }

    // 获取当前出块时间戳 (单位是秒)
    function getTimestamp() constant returns (uint) {
        return block.timestamp;
    }

    // 处理这个随机数,得到2个值
    function getXorPerson(uint number, uint start, uint long) private returns (uint) {
        uint num = (number % (10 ** (13 - start))) / (10 ** (13 - start - long));
        return num;
    }

    // num1 => 龙
    // num2 => 虎
    function processXor() payable {
        uint num1 = getXorPerson(xor, 2, 4) % 52;
        uint num2 = getXorPerson(xor, 8, 4) % 52;
        uint dNum = num1 % 13;
        uint tNum = num2 % 13;
        uint nSize = 50;
        if (dNum > tNum) {
            for (uint i = 0; i < dragon.length; i++) {
                transferCoin(dragon[i], dragonMap[dragon[i]] * 2);
            }
            if (resultHistory.length < nSize) {
                resultHistory.push(0);
            } else {
                for (uint o = 0; o < resultHistory.length - 1; o++) {
                    resultHistory[o] = resultHistory[o + 1];
                }
                resultHistory[resultHistory.length - 1] = 0;
            }
        } else if (dNum < tNum) {
            for (uint j = 0; j < tiger.length; j++) {
                transferCoin(tiger[j], tigerMap[tiger[j]] * 2);
            }
            if (resultHistory.length < nSize) {
                resultHistory.push(1);
            } else {
                for (uint p = 0; p < resultHistory.length - 1; p++) {
                    resultHistory[p] = resultHistory[p + 1];
                }
                resultHistory[resultHistory.length - 1] = 1;
            }
        } else {
            for (uint k = 0; k < draw.length; k++) {
                transferCoin(draw[k], drawMap[draw[k]] * 8);
            }
            if (resultHistory.length < nSize) {
                resultHistory.push(2);
            } else {
                for (uint q = 0; q < resultHistory.length - 1; q++) {
                    resultHistory[q] = resultHistory[q + 1];
                }
                resultHistory[resultHistory.length - 1] = 2;
            }
        }
        currentResult[0] = num1;
        currentResult[1] = num2;
    }

    // 转账函数
    function transferCoin(address _to, uint _coins) {
        _to.transfer(_coins);
    }
    // 提现函数,只有创建者账户可以提现
    function drawings(uint _coin) payable {
        if (msg.sender == creator) {
            uint _balance = getCurrentBalance();
            if ((_balance - _coin) / 10 > totalCoins) {
                transferCoin(creator, _coin);
            }
        }
    }
    // 结算函数
    function getResult() {
        uint _times = getTimestamp();
        if (_times - time > 10) {
            uNumTest++;
            //异或后得到了12位的随机数
            xorFun();
            processXor();
            reset();
        }

    }
    // 重置函数
    function reset(){
        xor = 0;
        time = getTimestamp();
        randomNum.length = 0;
        dragon.length = 0;
        tiger.length = 0;
        draw.length = 0;
        totalCoins = 0;
        dragonCoins = 0;
        tigerCoins = 0;
        drawCoins = 0;
    }
    // 返回当前合约账户的余额
    function getCurrentBalance() constant returns (uint256) {
        return this.balance;
    }

    // 返回下注金额
    function getTotalCoins() constant returns (uint, uint, uint, uint) {
        return (historyTotalCoins, dragonCoins, tigerCoins, drawCoins);
    }

    function getMsgValue() constant returns (uint) {
        return msg.value;
    }

    function registerInterval(address rContractAddr){
        Interval(rContractAddr).getAddress(this);
    }
}

contract Interval {
    address [] intervalAddr;
    uint nNumTest = 0;
    uint nNumTestTotal = 0;
    bool flagSign = false;

    function getAddress(address _getAddr) {
        intervalAddr.push(_getAddr);
    }

    // 后台定时器触发这个函数就可以了
    function trigger(){
        flagSign = false;
        nNumTestTotal++;
        for (uint i = 0; i < intervalAddr.length; i++) {
            nNumTest++;
            callFeed(intervalAddr[i]);
        }
    }

    function getAddrLen() constant returns (address []){
        return (intervalAddr);
    }

    function getTestNum() constant returns (uint, uint){
        return (nNumTest, nNumTestTotal);
    }

    function getFlag() constant returns (bool){
        return flagSign;
    }

    function chargeExist(address _addr) returns (bool){
        bool flag = false;
        for (uint i = 0; i < intervalAddr.length; i++) {
            if (intervalAddr[i] == _addr) {
                flag = true;
            }
        }
        return flag;
    }

    // 传入合约地址
    function callFeed(address contractAddr) {
        flagSign = true;
        PlayGame(contractAddr).getResult();
    }
}