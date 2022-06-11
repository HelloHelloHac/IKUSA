const hre = require("hardhat");

async function main() {
  const IKUSA = await hre.ethers.getContractFactory("IKUSA");
  const deployedIKUSA = await IKUSA.deploy("0xc7ad21913901d5f91883cf373afc9975283b37bf6f22f8b397bb75f9bde89ea4");

  await deployedIKUSA.deployed();

  console.log("Deployed IKUSA Address:", deployedIKUSA.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
