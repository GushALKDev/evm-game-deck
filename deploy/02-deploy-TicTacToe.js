const { loadFixture } = require("ethereum-waffle")
const { network, ethers } = require("hardhat")
const { developmentChains, networkConfig } = require("../helper-hardhat-config")
const { verify } = require("../utils/verify")

module.exports = async function ({ getNamedAccounts, deployments }) {
    const { deploy, log } = deployments
    const { deployer } = await getNamedAccounts()
    const chainId = network.config.chainId

    const managerContractAddress = "0x0000000000000000000000000000000000000000"

    const arguments = []
    const tictactoe = await deploy("TicTacToe", {
        from: deployer,
        args: arguments,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    })

    if (!developmentChains.includes(network.name)) {
        log("Verifying")
        await verify(highcard.address, arguments)
    }

    log("---------------------------------------")
}

module.exports.tags = ["all", "highcard"]
