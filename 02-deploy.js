let {byteCode, interface} = require('./01-compile')
let Web3 = require('web3')
let HDWalletProvider = require('truffle-hdwallet-provider')
let terms = 'neglect close attract rally audit about blush source wish rhythm kiss fresh'
// let terms = 'draw drum hamster glide mystery seek venture twist gown primary drill lonely'
let ropstenNet = 'https://ropsten.infura.io/v3/629b073b8a984a5d873dcf92149beb7a'
// let ropstenNet = 'http://googlecloud:7545'
let provider = new HDWalletProvider(terms, ropstenNet)
let web3 = new Web3(provider)

let contract = new web3.eth.Contract(JSON.parse(interface))
let deploy = async () => {
    let accounts = await web3.eth.getAccounts()
    console.log(accounts)
    let instance = await contract.deploy({
        data: byteCode,
        arguments: [],
    }).send({
        from: accounts[0],
        gas: '3000000',
    })
    console.log('address: ', instance.options.address)
}

deploy()