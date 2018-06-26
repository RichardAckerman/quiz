<template>
    <div id="app">
        <div style="border-bottom: 1px solid #555">
            <h3>
                类型
                <input type="text" disabled v-model="type1">
            </h3>
            <h3>
                主队
                <select v-model="homeTeam1">
                    <option value="皇家马德里">皇家马德里</option>
                </select>
                &nbsp;
                &nbsp;
                &nbsp;
                客队
                <select v-model="visitTeam1">
                    <option value="阿尔梅里亚">阿尔梅里亚</option>
                </select>
            </h3>
            <h3>
                主胜赔率
                <input type="text" v-model="hVOdds1">
            </h3>
            <h3>
                平赔率
                <input type="text" v-model="dOdds1">
            </h3>
            <h3>
                客胜赔率
                <input type="text" v-model="vVOdds1">
            </h3>
            <h3>
                截止日期
                <input type="text" v-model="deadline1">
            </h3>
            <h3>
                充值金额
                <input type="text" v-model="chargeVal">
            </h3>
            <h3>
                <button @click="deploy">部署</button>
            </h3>
        </div>
        <div>
            <h3>
                <span>合约余额：{{balance}}</span>
                &nbsp;
                &nbsp;
                &nbsp;
                &nbsp;
                <span>我的资金：{{amount}}</span>
            </h3>
            <h5>
                <span>下注截止时间：{{deadline2}}</span>
            </h5>
            <h1>
                <span>{{homeTeam}}</span> VS <span>{{visitTeam}}</span>
            </h1>
            <h4>
                <button :class="{isSelected:selectId1}" @click="selectId1=!selectId1;getHopeBonus()">主胜{{hVOdds}}
                </button>
                <button :class="{isSelected:selectId2}" @click="selectId2=!selectId2;getHopeBonus()">平{{dOdds}}</button>
                <button :class="{isSelected:selectId3}" @click="selectId3=!selectId3;getHopeBonus()">客胜{{vVOdds}}
                </button>
            </h4>
            <h2>
                <button @click="subtract">-</button>
                <input v-model="multipling" style="text-align: center">
                <button @click="add">+</button>
            </h2>
            <h1>
                <button @click="bottomPour">下注</button>
            </h1>
            <h3>
                <span v-if="showOne">预计奖金{{holpAmount1}}FOF</span>
                <span v-else>预计奖金{{holpAmount1}}FOF - {{holpAmount2}}FOF</span>
            </h3>
        </div>
        <div style="border-top: 1px solid #555">
            <h3>
                比赛结果
                <select v-model="playResult">
                    <option value="0">主胜</option>
                    <option value="1">客胜</option>
                    <option value="2">平局</option>
                </select>
            </h3>
            <h1>
                <button @click="settlement">结算</button>
            </h1>
        </div>
    </div>
</template>

<script>
    import Web3 from 'web3'
    import $axios from 'axios'
    import quizJson from './assets/contract/Quiz.json'

    const $web3 = new Web3('ws://127.0.0.1:8101')

    export default {
        name: 'App',
        data() {
            return {
                type1: 2,
                homeTeam1: '皇家马德里',
                visitTeam1: '阿尔梅里亚',
                hVOdds1: 1.1,
                dOdds1: 1.2,
                vVOdds1: 1.3,
                deadline1: '2018-06-23 00:00:00',
                chargeVal: '50',

                type: 2,
                homeTeam: '',
                visitTeam: '',
                hVOdds: 0,
                dOdds: 0,
                vVOdds: 0,
                btnActive: 0,
                balance: 0,
                amount: 0,
                deadline2: '',
                selectId1: false,
                selectId2: false,
                selectId3: false,
                selectOdds: [-1, -1, -1],
                multipling: 1,
                holpAmount1: 0,
                holpAmount2: 0,
                myContractInstance: null,
                myAddress: "0x94f6bae984fb2a2bb290e4f5e412013585bfbe5d",
                contractAddr: '0x99B89Ad103Db509a3EaE0f2217434A59Ed6A27b5',
                resultArr: [],
                showOne: false,
                playResult: '0'
                // "0x74a1a4e286e8025d2e760eefb3fe192b3da29949", "0x94f6bae984fb2a2bb290e4f5e412013585bfbe5d"
            }
        },
        methods: {
            timestampToTime(timestamp) {
                let date = new Date(timestamp * 1)//时间戳为10位需*1000，时间戳为13位的话不需乘1000
                let Y = date.getFullYear() + '-'
                let M = (date.getMonth() + 1 < 10 ? '0' + (date.getMonth() + 1) : date.getMonth() + 1) + '-'
                let D = date.getDate() + ' '
                let h = date.getHours() + ':'
                let m = date.getMinutes() + ':'
                let s = date.getSeconds()
                return Y + M + D + h + m + s
            },
            subtract() {
                if (this.multipling > 1) {
                    this.multipling--
                    this.getHopeBonus()
                }
            },
            add() {
                if (this.multipling < 100) {
                    this.multipling++
                    this.getHopeBonus()
                }
            },
            // 结算
            settlement() {
                this.myContractInstance.methods.getResult(Number(this.playResult))
                    .send({
                        from: this.myAddress,
                        gas: 1000000,
                    })
                    .on('error', (err) => {
                        console.log(err)
                    })
                    .on('receipt', (receipt) => {
                        this.getBalance()
                        this.getContractBalance()
                        console.log(receipt)
                    })
            },
            // 下注
            bottomPour() {
                if (Number(this.multipling) > Number(this.amount)) {
                    alert("下注金额大于你的余额")
                    return
                }
                let flag = false
                let count = 0
                for (let i = 0; i < this.selectOdds.length; i++) {
                    if (this.selectOdds[i] !== -1) {
                        flag = true
                        count++
                    }
                }
                if (!flag) {
                    alert("请先选中下注对象")
                    return
                }
                let value = $web3.utils.toWei((this.multipling * count).toString(), 'ether')
                this.myContractInstance.methods.betFun(this.myAddress, this.selectOdds, value, count)
                    .send({
                        from: this.myAddress,
                        gasPrice: 200000000000,
                        value: value,
                        gas: 1000000,
                    })
                    .on('error', (err) => {
                        console.log(err)
                    })
                    .on('receipt', (receipt) => {
                        console.log(receipt)
                    })
            },
            // 部署
            deploy() {
                let params = {
                    type: 2,
                    id: 1,
                    homeTeam: this.homeTeam1,
                    visitingTeam: this.visitTeam1,
                    oddsH: this.hVOdds1 * 100,
                    oddsD: this.dOdds1 * 100,
                    oddsV: this.vVOdds1 * 100,
                    deadline: Date.parse(new Date(this.deadline1))
                }
                $web3.eth.estimateGas({data: quizJson.bytecode}).then((gas) => {
                    // 0xD9AD822113385B65a234020a379234B97209C4B3
                    new $web3.eth.Contract(quizJson.abi)
                        .deploy({
                            data: quizJson.bytecode,
                            arguments: [params.type, params.id, params.homeTeam, params.visitingTeam, params.oddsH, params.oddsD, params.oddsV, params.deadline]
                        })
                        .send({
                            from: this.myAddress,
                            gasPrice: '41000000000',
                            gas: gas * 2,
                        })
                        .on('error', (err) => {
                            console.log('Contract++++++++++')
                            console.log(err)
                        })
                        .on('receipt', (receipt) => {
                            console.log(receipt)
                            $axios.post('/url/api/addQuizContract.php', {
                                "type": "2",
                                "contractAddr": receipt.contractAddress,
                                "liveid": '123',
                                "createAddr": this.myAddress
                            }).then((res) => {
                                if (res.status === 200) {
                                    // console.log(res)
                                }
                            }).catch((error) => {
                                console.log(error)
                            })
                        })
                        .then((instance) => {
                            instance.methods.deposit()
                                .send({
                                    from: this.myAddress,
                                    value: $web3.utils.toWei(this.chargeVal, 'ether'),
                                    gas: 100000
                                })
                                .on('error', (err) => {
                                    console.log('deposit++++++++++')
                                    console.log(err)
                                })
                                .on('receipt', (receipt) => {
                                    console.log(receipt)
                                })
                        })
                })
            },
            /**
             * 监听下注结果
             */
            watchBet() {
                // 监听是否下注失败
                this.myContractInstance.events
                    .returnBetResult()
                    .on('data', (event) => {
                        if (event.returnValues) {
                            // if (event.returnValues._bool) {
                            //     alert(event.returnValues._msg)
                            // } else {
                            //     alert(event.returnValues._msg)
                            // }
                            this.getBalance()
                            this.getContractBalance()
                            alert(event.returnValues._msg)
                        }
                    })
                    .on('error', (err) => {
                        console.log(err)
                    })
            },
            getHopeBonus() {
                this.selectOdds.length = 0
                this.selectOdds[0] = this.selectId1 ? 0 : -1
                this.selectOdds[1] = this.selectId2 ? 2 : -1
                this.selectOdds[2] = this.selectId3 ? 1 : -1
                let arr = [this.hVOdds, this.dOdds, this.vVOdds]
                this.resultArr.length = 0
                for (let i = 0; i < this.selectOdds.length; i++) {
                    if (this.selectOdds[i] === -1) {
                        this.resultArr[i] = 0
                        continue
                    }
                    this.resultArr[i] = arr[i] * this.multipling
                }
                this.resultArr.sort((a, b) => {
                    return a - b
                })
                if (this.resultArr[0] === 0) {
                    if (this.resultArr[1] === 0) {
                        this.showOne = true
                        this.holpAmount1 = this.resultArr[2]
                    } else {
                        this.showOne = false
                        this.holpAmount1 = this.resultArr[1]
                        this.holpAmount2 = this.resultArr[2]
                    }
                } else {
                    this.showOne = false
                    this.holpAmount1 = this.resultArr[0]
                    this.holpAmount2 = this.resultArr[2]
                }
            },
            // 获取账户余额
            getBalance() {
                $web3.eth.getBalance(this.myAddress).then((data) => {
                    this.amount = $web3.utils.fromWei(data, 'ether')
                })
            },
            // 获取合约余额
            getContractBalance() {
                this.myContractInstance.methods.getCurrentBalance().call().then((data) => {
                    this.balance = $web3.utils.fromWei(data, 'ether')   // 合约余额
                })
            },
            unlock() {
                $web3.eth.personal.unlockAccount("0x94f6bae984fb2a2bb290e4f5e412013585bfbe5d", "111111", 1000000000)
            },
            transaction() {
                $web3.eth.sendTransaction({
                    from: "0x74a1a4e286e8025d2e760eefb3fe192b3da29949",
                    gasPrice: "20000000000",
                    gas: "21000",
                    to: '0x94f6bae984fb2a2bb290e4f5e412013585bfbe5d',
                    value: "700000000000000000000",
                })
            },
            // eth.getBalance("0x94f6bae984fb2a2bb290e4f5e412013585bfbe5d")
        },
        mounted() {
            // this.transaction()
            // this.unlock()
            // 余额
            this.getBalance()
            this.myContractInstance = new $web3.eth.Contract(quizJson.abi, this.contractAddr)
            this.getContractBalance()
            this.myContractInstance.methods.getSetting().call().then((data) => {
                this.type = data[0]
                this.homeTeam = data[2]
                this.visitTeam = data[3]
                this.hVOdds = data[4] / 100
                this.dOdds = data[5] / 100
                this.vVOdds = data[6] / 100
                this.deadline2 = this.timestampToTime(data[7])
            })
            this.watchBet()
        }
    }
</script>

<style>
    #app {
        font-family: 'Avenir', Helvetica, Arial, sans-serif;
        -webkit-font-smoothing: antialiased;
        -moz-osx-font-smoothing: grayscale;
        text-align: center;
        color: #2c3e50;
        margin-top: 60px;
    }

    .isSelected {
        background: #43BE88;
    }
</style>
