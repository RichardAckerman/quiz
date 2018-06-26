pragma solidity ^0.4.0;

contract Quiz {
    uint gameType; // 类型：应该为2
    uint id; //
    string homeTeam; //主队
    string visitingTeam; //客队
    uint oddsH; //主胜赔率
    uint oddsD; //平赔率
    uint oddsV; //客胜赔率
    uint deadline; // 截止日期
    address [] hVictory;  // 保存选胜0的地址
    mapping(address => uint) hVictoryMap; // 选主胜用户的下注金额
    address [] vVictory;   // 保存选负1的地址
    mapping(address => uint) vVictoryMap; // 选客胜用户的下注金额
    address [] draw;    // 保存选平2的地址
    mapping(address => uint) drawMap; // 选平局用户的下注金额
    address creator = msg.sender; // 创建者的地址

    event returnBetResult(bool _bool, string _msg); // 返回是否下注成功

    function deposit() public payable {}

    /*
    * @homeTeam 主队
    * @visitingTeam 客队
    * @oddsH 主胜赔率 0
    * @oddsD 平赔率   2
    * @oddsV 客胜赔率 1
    * solidity里面不支持小数计算
    * 传入的赔率扩大了100倍，最后的结果需要除以100
    */
    constructor(uint _type, uint _id, string _homeTeam, string _visitingTeam, uint _oddsH, uint _oddsD, uint _oddsV, uint _deadline) public{
        gameType = _type;
        id = _id;
        homeTeam = _homeTeam;
        visitingTeam = _visitingTeam;
        oddsH = _oddsH;
        oddsD = _oddsD;
        oddsV = _oddsV;
        deadline = _deadline;
    }

    // 返回当前合约账户的余额
    function getCurrentBalance() public constant returns (uint256) {
        return address(this).balance;
    }

    // 返回配置参数
    function getSetting() public constant returns (uint, uint, string, string, uint, uint, uint, uint) {
        return (gameType, id, homeTeam, visitingTeam, oddsH, oddsD, oddsV, deadline);
    }

    // 下注函数
    /*
    * @addr 下注地址
    * @choose 选择胜负平 ------- 0 1 2 , -1 代表没有选
    * @coin 下注金额
    * @num 下注数 ------- 1 2 3
    */
    function betFun(address addr, uint [3] choose, uint coin, uint num) public payable {
        if (block.timestamp * 1000 > deadline) {
            transferCoin(addr, coin);
            emit returnBetResult(false, "已过下注截止时间");
        } else {
            emit returnBetResult(true, "下注成功");
            for (uint i = 0; i < 3; i++) {
                if (choose[i] == 0) {
                    bool flag1 = false;
                    for (uint j = 0; j < hVictory.length; j++) {
                        if (hVictory[j] == addr) {
                            flag1 = true;
                            break;
                        }
                    }
                    if (!flag1) {
                        hVictory.push(addr);
                    }
                    hVictoryMap[addr] = hVictoryMap[addr] + coin / num;
                } else if (choose[i] == 1) {
                    bool flag2 = false;
                    for (uint k = 0; k < vVictory.length; k++) {
                        if (vVictory[k] == addr) {
                            flag2 = true;
                            break;
                        }
                    }
                    if (!flag2) {
                        vVictory.push(addr);
                    }
                    vVictoryMap[addr] = vVictoryMap[addr] + coin / num;
                } else if (choose[i] == 2) {
                    bool flag3 = false;
                    for (uint l = 0; l < draw.length; l++) {
                        if (draw[l] == addr) {
                            flag3 = true;
                            break;
                        }
                    }
                    if (!flag3) {
                        draw.push(addr);
                    }
                    drawMap[addr] = drawMap[addr] + coin / num;
                }
            }
        }
    }

    // 结算函数
    // @_result 传入谁赢 0 1 2 / 主胜 客胜 平
    function getResult(uint _result) public {
        if (_result == 0) {
            for (uint i = 0; i < hVictory.length; i++) {
                transferCoin(hVictory[i], hVictoryMap[hVictory[i]] * oddsH / 100);
            }
        } else if (_result == 1) {
            for (uint j = 0; j < vVictory.length; j++) {
                transferCoin(vVictory[j], vVictoryMap[vVictory[j]] * oddsV / 100);
            }
        } else if (_result == 2) {
            for (uint k = 0; k < draw.length; k++) {
                transferCoin(draw[k], drawMap[draw[k]] * oddsD / 100);
            }
        }
        reset();
        //        if (block.timestamp * 1000 > deadline) {
        //            drawings();
        //            reset();
        //        }
    }

    // 提现函数,只有创建者账户可以提现
    function drawings() public payable {
        if (msg.sender == creator) {
            uint _balance = getCurrentBalance();
            transferCoin(creator, _balance);
        }
    }

    // 重置函数
    function reset() private {
        for (uint i = 0; i < hVictory.length; i++) {
            hVictoryMap[hVictory[i]] = 0;
        }
        hVictory.length = 0;
        for (uint j = 0; j < vVictory.length; j++) {
            vVictoryMap[vVictory[j]] = 0;
        }
        vVictory.length = 0;
        for (uint k = 0; k < draw.length; k++) {
            drawMap[draw[k]] = 0;
        }
        draw.length = 0;
    }

    // 转账函数
    /*
    * @_to 目标地址
    * @_coins 金额
    */
    function transferCoin(address _to, uint _coins) private {
        _to.transfer(_coins);
    }
}
