const { ethers } = require("hardhat")
const fs = require("fs")
const hre = require("hardhat");

async function main() {
    const accounts = await hre.ethers.getSigners();
    const signer = accounts[0];

    const MaskContract = await hre.ethers.getContractFactory("Treasury");
    const keyspace_addr = "0xd7681B69C80d125dB1214884B667464675AC21e5";
    const treasury_addr = "0xB5fbCCADaE04DA1f580f0430708A0D56693Cb015";
    const mask = new hre.ethers.Contract(treasury_addr, MaskContract.interface, signer)

    let transactionResponse = await mask.addMinter(keyspace_addr);
    let receipt = await transactionResponse.wait(1);
    console.log("enable keyspace mint token ability successed.");
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
