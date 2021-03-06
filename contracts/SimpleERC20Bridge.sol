// SPDX-License-Identifier: MIT

pragma solidity 0.8.11;

import "./IERC20.sol";

contract SimpleERC20Bridge {

  uint chainId;
  uint transaction_fee;
  address public admin;
  IERC20 public erc20;
  mapping(address => mapping(uint => bool)) public processedNonces;
  mapping(address => uint) public nonces;

  enum Step { Deposit, Withdraw }
  
  event Transfer(
    address from,
    address to,
    uint destChainId,
    uint amount,
    uint date,
    uint nonce,
    bytes signature,
    Step indexed step
  );

  function initialize() public  {

    admin = msg.sender;
    uint _chainId;
    assembly {
        _chainId := chainid()
    }
    chainId = _chainId;
  }

//   constructor() {
//     admin = msg.sender;
//     uint _chainId;
//     assembly {
//         _chainId := chainid()
//     }
//     chainId = _chainId;
//   }

  modifier onlyAdmin() {
    require(admin == msg.sender, "Only Admin can perform this operation.");
    _;
  }

  function setToken(address _addr) external onlyAdmin {
    erc20 = IERC20(_addr);
  }

  function deposit(uint amount) external onlyAdmin {
    erc20.transferFrom(admin, address(this), amount);
  }

  function withdraw(uint amount) external onlyAdmin {
    erc20.transfer(admin, amount);
  }

  function deposit(address to, uint destChainId, uint amount, uint nonce, bytes calldata signature) external {
    require(nonces[msg.sender] == nonce, 'transfer already processed');
    nonces[msg.sender] += 1;
    erc20.transferFrom(msg.sender, address(this), amount);
    emit Transfer(
      msg.sender,
      to,
      destChainId,
      amount,
      block.timestamp,
      nonce,
      signature,
      Step.Deposit
    );
  }

  function withdraw(
    address from, 
    address to, 
    uint amount, 
    uint nonce,
    bytes calldata signature
  ) external {
    bytes32 message = prefixed(keccak256(abi.encodePacked(
      from, 
      to, 
      chainId,
      amount,
      nonce
    )));
    require(recoverSigner(message, signature) == from , 'wrong signature');
    require(processedNonces[from][nonce] == false, 'transfer already processed');
    processedNonces[from][nonce] = true;
    require(erc20.balanceOf(address(this)) >= amount, 'insufficient pool');
    erc20.transfer(to, amount);
    emit Transfer(
      from,
      to,
      chainId,
      amount,
      block.timestamp,
      nonce,
      signature,
      Step.Withdraw
    );
  }

  function prefixed(bytes32 hash) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(
      '\x19Ethereum Signed Message:\n32', 
      hash
    ));
  }

  function recoverSigner(bytes32 message, bytes memory sig)
    internal
    pure
    returns (address)
  {
    uint8 v;
    bytes32 r;
    bytes32 s;
  
    (v, r, s) = splitSignature(sig);
  
    return ecrecover(message, v, r, s);
  }

  function splitSignature(bytes memory sig)
    internal
    pure
    returns (uint8, bytes32, bytes32)
  {
    require(sig.length == 65);
  
    bytes32 r;
    bytes32 s;
    uint8 v;
  
    assembly {
        // first 32 bytes, after the length prefix
        r := mload(add(sig, 32))
        // second 32 bytes
        s := mload(add(sig, 64))
        // final byte (first byte of the next 32 bytes)
        v := byte(0, mload(add(sig, 96)))
    }
  
    return (v, r, s);
  }
}
