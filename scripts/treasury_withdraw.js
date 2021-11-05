// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
const hre = require("hardhat");

async function main() {
    // Hardhat always runs the compile task when running scripts with its command
    // line interface.
    //
    // If this script is run directly using `node` you may want to call compile
    // manually to make sure everything is compiled
    // await hre.run('compile');

    // We get the contract to deploy

    const Treasury = await hre.ethers.getContractFactory("Treasury");
    const treasury_addr = "0x10F26B6EcBF96774Ef8d584B3d852a80a603D36e";
    const accounts = await hre.ethers.getSigners();
    const signer = accounts[0];
    const treasury = new hre.ethers.Contract(treasury_addr, Treasury.interface, signer)
    let amount  = 10000000;
    let transactionResponse = await treasury.withdraw(signer.address, amount);
    let receipt = await transactionResponse.wait(1)
    console.log("withdraw amount:"+amount+" to address:"+signer.address);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch(error => {
        console.error(error);
        process.exit(1);
    });
