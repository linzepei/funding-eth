let solc = require('solc')
let fs = require('fs')

let sourceCode = fs.readFileSync('./contracts/FundingFactory.sol', 'utf-8')
let output = solc.compile(sourceCode, 1)
console.log('output: ', output['contracts'][':FundingFactory']['interface'])
module.exports = output['contracts'][':FundingFactory']