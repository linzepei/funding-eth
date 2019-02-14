pragma solidity ^0.4.24;

import './FundingFactory.sol';
//1.项目发起人
//2.项目名称
//3.目标筹集金额
//4.人均支持金额
//5.项目持续天数
contract Funding {
    address public manager;
    string public projectName;
    uint256 public targetMoney;
    uint256 public supportMoney;
    //    uint256 public duration;//持续时间--秒为单位
    uint256 public endTime;
    address[] investors;

    SupportorFundingContract supportorFundings;

    constructor(string _projectName, uint256 _targetMoney, uint256 _supportMoney, uint256 _duration, address _creator, SupportorFundingContract _supportorFundings) public{
        manager = _creator;
        projectName = _projectName;
        targetMoney = _targetMoney;
        supportMoney = _supportMoney * 10 ** 18;
        //        duration = _duration;
        endTime = block.timestamp + _duration;
        supportorFundings = _supportorFundings;
    }

    //使用一个mapping来判断一个地址是否是投资人
    mapping(address => bool) isInvestorMap;

    function invest() payable public {
        require(msg.value == supportMoney);
        investors.push(msg.sender);
        isInvestorMap[msg.sender] = true;
        supportorFundings.setFunding(msg.sender, this);
    }

    function refund() onlyManager public {
        for (uint256 i = 0; i < investors.length; i++) {
            investors[i].transfer(supportMoney);
        }
        delete investors;
    }

    //产品选举状态：0:进行中 1：已批准 2：已完成
    enum RequestStatus{
        Voting, Approved, Completed
    }

    struct Request {
        string purpose;
        uint256 cost;
        address seller;
        uint256 approveCount;
        RequestStatus status;
        mapping(address => bool) isVotedMap;//记录投资人的投票状态，只能投票一次
    }

    Request[] public allRequests;//项目方的所有花费请求
    function createRequest(string _purpose, uint256 _cost, address _seller) onlyManager public {
        Request memory req = Request({
            purpose : _purpose,
            cost : _cost,
            seller : _seller,
            approveCount : 0,
            status : RequestStatus.Voting
            });
        allRequests.push(req);
    }

    //批准支付申请:
    //1.检验投资人是否投过票
    //2.approveCount++
    //3.修改map
    function approveRequest(uint256 i) public {
        require(isInvestorMap[msg.sender]);
        Request storage req = allRequests[i];
        require(req.isVotedMap[msg.sender] == false);
        req.approveCount++;
        req.isVotedMap[msg.sender] = true;
    }

    //1.金额足够
    //2.票数过半则可以花费
    //3.更新request状态
    function finalizeRequest(uint256 i) onlyManager public {
        Request storage req = allRequests[i];
        require(address(this).balance >= req.cost);
        require(req.approveCount * 2 > investors.length);
        req.seller.transfer(req.cost);
        req.status = RequestStatus.Completed;
    }

    modifier onlyManager{
        require(msg.sender == manager);
        _;
    }

    function getLeftTime() public view returns (uint256){
        return (endTime - block.timestamp) / 60 / 60 / 24;
    }

    function getInvestorsCount() public view returns (uint256){
        return investors.length;
    }

    function getRequestsCount() public view returns (uint256){
        return allRequests.length;
    }

    function getRequestByIndex(uint256 i) public view returns (string, uint256, address, uint256, RequestStatus){
        Request memory req = allRequests[i];
        return (req.purpose, req.cost, req.seller, req.approveCount, req.status);
    }

    function getBalance() public view returns (uint256){
        return address(this).balance;
    }

    function getInvestors() public view returns (address[]){
        return investors;
    }


}
