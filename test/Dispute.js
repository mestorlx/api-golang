// const promisify = require('js-promisify');
var util = require('util');
const encodeCall = require('zos-lib/lib/helpers/encodeCall').default;
const Dispute = artifacts.require('Dispute');
const DIAToken = artifacts.require('DIAToken');

const waitNBlocks = async n => {
    const sendAsync = util.promisify(web3.currentProvider.sendAsync);
    await Promise.all(
        [...Array(n).keys()].map(i =>
            sendAsync({
                jsonrpc: '2.0',
                method: 'evm_mine',
                id: i
            })
        )
    );
};

async function assertRevert(promise) {
    try {
        await promise;
        assert.fail('Expected revert not received');
    } catch (error) {
        const revertFound = error.message.search('revert') >= 0;
        assert(revertFound, `Expected "revert", got ${error} instead`);
    }
};

contract('Dispute', function (accounts) {
    let owner = accounts[0];
    let holder = accounts[1];
    let notHolder = accounts[1];
    let dispute;

    beforeEach('setup contract before each test', async function () {
        dispute = await Dispute.new({ from: owner });
        dia = await DIAToken.new({ from: owner });

        var callData = encodeCall('initialize', ['address'], [owner]);
        await dia.sendTransaction({ data: callData, from: owner });
        callData = encodeCall('initialize', ['address', 'address'], [owner, dia.address]);
        await dispute.sendTransaction({ data: callData, from: owner });
    });

    // it("First account should be owner", async function () {
    //     let contractOwner = await dispute.owner();

    //     assert.equal(contractOwner, owner, "The owner of the contract is not accounts[0]");
    // });

    // it("DIA token holder should be able to open a dispute", async function () {
    //     await dispute.openDispute(1, { from: holder });
    //     let ongoing = await dispute.ongoingDisputes.call(1);

    //     assert.equal(ongoing.valueOf(), true, "Dispute was not initiated");
    // });

    // it("Users without DIA token should not be able to open a dispute", async function () {
    //     await assertRevert(dispute.openDispute(1, { from: notHolder }));
    // });

    // it("Dispute should not be able to be initiated if already in progress", async function () {
    //     await dispute.openDispute(1);

    //     await assertRevert(dispute.openDispute(1));
    // });

    // it("DIA token holder should be able to vote on a dispute", async function () {
    //     await dispute.openDispute(1);
    //     let initVotes = await dispute.totalVotesPerDispute.call(1)
    //     await dispute.vote(1, { from: holder })
    //     let votes = await dispute.totalVotesPerDispute.call(1)

    //     assert.equal(votes.valueOf() - initVotes.valueOf(), 1, "Dia holder vote not processed");
    // });

    // it("Users without DIA token should not be able to vote on a dispute", async function () {
    //     await dispute.openDispute(1);

    //     await assertRevert(dispute.vote(1, { from: notHolder }))
    // });

    // it("Users without enough DIA token balance should not be able to vote on a dispute", async function () {
    //     await dispute.openDispute(1);

    //     await assertRevert(dispute.vote(1, { from: notHolder }))
    // });

    it("Anyone should be able to trigger decision after deadline", async function () {
        await dispute.openDispute(1);
        waitNBlocks(10);
        await dispute.triggerDecision(1, { from: notHolder })
        let ongoing = await dispute.disputeDeadline_.call(1);

        assert.equal(ongoing.valueOf(), 0, "Dispute was not closed");
    });

    it("Nobody should be able to trigger decision before deadline", async function () {
        await dispute.openDispute(1);
        waitNBlocks(9);
        await assertRevert(dispute.triggerDecision(1));
    });
});
