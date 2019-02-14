import React, {Component} from 'react';
import {approveRequest, getFundingDetails, showRequests} from '../../eth/interaction'
import CardList from "../common/CardList";
import RequestTable from "../common/RequestTable";
import {Button} from "semantic-ui-react";

class SupportorFundingTab extends Component {

    state = {
        supportorFundingDetails: [],
        seletedFundingDetail: '',
        requests: [], //所有的花费请求
    }

    async componentWillMount() {
        let supportorFundingDetails = await getFundingDetails(3)
        console.table(supportorFundingDetails)
        this.setState({
            supportorFundingDetails
        })
    }

    //传递一个回调函数给CardList，将所选择的Card的详细信息返回来
    onCardClick = (seletedFundingDetail) => {
        console.log("bbbb :", seletedFundingDetail)

        this.setState({
            seletedFundingDetail
        })
    }

    handleShowRequests = async () => {
        let fundingAddress = this.state.seletedFundingDetail.fundingAddress
        try {
            let requests = await showRequests(fundingAddress)
            console.log('requests:', requests)
            this.setState({requests})

        } catch (e) {
            console.log(e)
        }
    }

    handleApprove = async (index) => {
        console.log('批准按钮点击！')
        //1.指定合约地址
        //2.指定选择请求的index
        try {
            let res = await approveRequest(this.state.seletedFundingDetail.fundingAddress, index)
        } catch (e) {
            console.log(e)
        }
    }

    render() {
        let {supportorFundingDetails, seletedFundingDetail, requests} = this.state
        return (
            <div>
                <CardList details={supportorFundingDetails}
                          onCardClick={this.onCardClick}/>
                {
                    seletedFundingDetail && (<div>
                        <Button onClick={this.handleShowRequests}>申请详情</Button>
                        <RequestTable requests={requests}
                                      handleApprove={this.handleApprove}
                                      pageKey={3}
                                      investorCount={seletedFundingDetail.investorCount}
                        />
                    </div>)
                }
            </div>
        )
    }
}

export default SupportorFundingTab
