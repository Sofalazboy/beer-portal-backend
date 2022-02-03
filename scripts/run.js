  const main = async () => {
    const [owner, randomPerson1, randomPerson2] = await hre.ethers.getSigners();
    const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
    const waveContract = await waveContractFactory.attach(
        //"0x5fbdb2315678afecb367f032d93f642f64180aa3" // The deployed contract address
     "0x3Aa5ebB10DC797CAC828524e59A333d0A371443c" //localhost
        );
      console.log("Contract deployed to:", waveContract.address);
      console.log("Contract deployed by:", owner.address);
      
   /*
   * Get Contract balance
   */
  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );


  let waveCount;
    waveCount = await waveContract.getTotalVotes();
  
    let waveTxn = await waveContract.vote(getTime(),1,'dummy message');
    await waveTxn.wait();

    contractBalance = await hre.ethers.provider.getBalance(
        waveContract.address
      );
      console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
      );
    
    waveCount = await waveContract.getTotalVotes();
    //Simulate wave by random person
    waveTxn = await waveContract.connect(randomPerson1).vote(getTime(),1,'dummy');
    await waveTxn.wait();
    contractBalance = await hre.ethers.provider.getBalance(
        waveContract.address
      );
      console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
      );
    waveTxn = await waveContract.connect(randomPerson1).vote(getTime(),4,'dummy');
    await waveTxn.wait();
    contractBalance = await hre.ethers.provider.getBalance(
        waveContract.address
      );
      console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
      );
    //A different random person
    waveTxn = await waveContract.connect(randomPerson2).vote(getTime(),3,'dummy');
    await waveTxn.wait();
    contractBalance = await hre.ethers.provider.getBalance(
        waveContract.address
      );
      console.log(
        "Contract balance:",
        hre.ethers.utils.formatEther(contractBalance)
      );
    
    waveCount = await waveContract.getTotalVotes();
    //Get my stats
    console.log('STATISTICS - each address can request its stats');
    let voter = await waveContract.getVoter();
    console.log('Invoking as myself');
    console.log(voter);
    console.log('Invoking as randomPerson1');
    voter = await waveContract.connect(randomPerson1).getVoter();
    console.log(voter);
    console.log('Invoking as randomPerson2');
    voter = await waveContract.connect(randomPerson2).getVoter();
    console.log(voter);
  };
  
  const getTime = () => {
    let date = (new Date()).getTime();
    return date;
  }

  const runMain = async () => {
    try {
      await main();
      process.exit(0);
    } catch (error) {
      console.log(error);
      process.exit(1);
    }
  };
  
  runMain();

  /*

In Solidity you will store date as uint type

pragma solidity ^0.5.11;

contract BirthDate {
    uint256 public birthdate;

    function set(uint256 _birthdate) public {
        birthdate = _birthdate;
    }

    function get() public view returns (uint _birthdate) {
        return birthdate;
    }
}
To set date in smart-contract with web3.js:

let date = (new Date()).getTime();
let birthDateInUnixTimestamp = date / 1000;
await BirthDate.methods.set(birthDateInUnixTimestamp).send(opts);
To get date from smart-contract with web3.js:

let birthDateInUnixTimestamp = await BirthDate.methods.get().call();
let date = new Date(birthDateInUnixTimestamp * 1000);

*/