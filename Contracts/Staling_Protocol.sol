pragma solidity ^0.4.21;


/*
BASIC ERC20 Crowdsale ICO ERC20 Token
Create this Token contract AFTER you already have the Sale contract created.
   Token(address sale_address)   // creates token and links the Sale contract
@author Hunter Long
@repo https://github.com/hunterlong/ethereum-ico-contract
*/


contract BasicToken {
    uint256 public totalSupply;
    uint256 public maxMintable;

    function _balanceOf(address _owner) constant returns (uint256 balance);
    function _transfer(address _to, uint256 _value) returns (bool success);
    function _transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function _approve(address _spender, uint256 _value) returns (bool success);
    function _allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract StandardToken is BasicToken {

    function _transfer(address _to, uint256 _value) returns (bool success) {
        require(_balances[msg.sender] >= _value);
        _balances[msg.sender] -= _value;
        _balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function _transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        require(_balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        _balances[_to] += _value;
        _balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function _balanceOf(address _owner) constant returns (uint256 balance) {
        return _balances[_owner];
    }

    function _approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function _allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) _balances;
    mapping (address => mapping (address => uint256)) allowed;
}


contract Token is StandardToken {

    string public name = "FAN Farm";
    uint8 public decimals = 18;
    string public symbol = "FFP";
    address public mintableAddress;

    function Token(address sale_address) {
        _balances[msg.sender] = 0;
        totalSupply = 0;
        maxMintable = 2000000000000000000000000000;
        name = name;
        decimals = decimals;
        symbol = symbol;
        mintableAddress = sale_address;
    }



   

    function mintToken(address to, uint256 amount) external returns (bool success) {
        require(msg.sender == mintableAddress);
        require(maxMintable >= totalSupply + amount);
        totalSupply += amount;
        _balances[to] += amount;
        emit Transfer(address(0), to, amount);
        return true;
    }

   

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        require(_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData));
        return true;
    }
}
