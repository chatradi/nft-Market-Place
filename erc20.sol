// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}



/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


/**
 * @title ERC20 Token
 * @dev Implementation of the basic ERC-20 standard token with burn and mint functions.
 */
contract BBT {

    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public totalSupply;

    address public owner;
    bool public paused;

    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowed;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Constructor that gives msg.sender all of existing tokens.
     * @param _name The name of the token.
     * @param _symbol The symbol of the token.
     * @param _decimals The number of decimals of the token.
     * @param _totalSupply The total supply of the token.
     */
    constructor (
        string memory _name, 
        string memory _symbol, 
        uint8 _decimals, 
        uint256 _totalSupply
    ) {
        owner = msg.sender;
        symbol = _symbol;
        name = _name;
        decimals = _decimals;
        totalSupply = _totalSupply;
        _balances[msg.sender] = _totalSupply;
    }

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier whenpaused(){
        require( paused == true, "Contract is not paused");
        _;
    }

    modifier whenNotPaused(){
        require( paused == false, "Contract is paused");
        _;
    }
    
    modifier onlyOwner(){
        require( owner == msg.sender, "only owner can access this function");
        _;
    }

     /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() external onlyOwner {
        owner = address(0);
    }

    function transferOwnership(address newOwner) onlyOwner external {
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Transfer token for a specified address.
     * @param _to The address to transfer to.
     * @param _value The amount to be transferred.
     * @return A boolean that indicates if the operation was successful.
     */
    function transfer(
        address _to, 
        uint256 _value
    ) external  whenNotPaused returns (bool) {
        require(_to != address(0), 'ERC20: to address is not valid');
        require(_value <= _balances[msg.sender], 'ERC20: insufficient balance');

        _balances[msg.sender] = _balances[msg.sender] - _value;
        _balances[_to] = _balances[_to] + _value;
        
        emit Transfer(msg.sender, _to, _value);
        
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the balance of.
    * @return balance An uint256 representing the balance
    */
   function balanceOf(
       address _owner
    ) external  view returns (uint256 balance) {
        return _balances[_owner];
    }

    /**
     * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
     * @param _spender The address which will spend the funds.
     * @param _value The amount of tokens to be spent.
     * @return A boolean that indicates if the operation was successful.
     */
    function approve(
       address _spender, 
       uint256 _value
    ) external  whenNotPaused returns (bool) {
        _allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        
        return true;
   }

      /**
    * @dev Transfer tokens from one address to another.
    * @param _from The address which you want to send tokens from.
    * @param _to The address which you want to transfer to.
    * @param _value The amount of tokens to be transferred.
    * @return A boolean that indicates if the operation was successful
    */
   function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
    ) external  whenNotPaused returns (bool) {
        require(_from != address(0), 'ERC20: from address is not valid');
        require(_to != address(0), 'ERC20: to address is not valid');
        require(_value <= _balances[_from], 'ERC20: insufficient balance');
        require(_value <= _allowed[_from][msg.sender], 'ERC20: transfer from value not allowed');

        _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _value;
        _balances[_from] = _balances[_from] - _value;
        _balances[_to] = _balances[_to] + _value;
        
        emit Transfer(_from, _to, _value);
        
        return true;
   }

    /**
     * @dev Returns the amount of tokens approved by the owner that can be transferred to the spender's account.
     * @param _owner The address of the owner of the tokens.
     * @param _spender The address of the spender.
     * @return The number of tokens approved.
     */
    function allowance(
        address _owner, 
        address _spender
    ) external  view whenNotPaused returns (uint256) {
        return _allowed[_owner][_spender];
    }

    /**
     * @dev Increases the amount of tokens that an owner has allowed to a spender.
     * @param _spender The address of the spender.
     * @param _addedValue The amount of tokens to increase the allowance by.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function increaseApproval(
        address _spender, 
        uint256 _addedValue
    ) external whenNotPaused returns (bool) {
        _allowed[msg.sender][_spender] = _allowed[msg.sender][_spender] + _addedValue;

        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
        
        return true;
    }

    /**
     * @dev Decreases the amount of tokens that an owner has allowed to a spender.
     * @param _spender The address of the spender.
     * @param _subtractedValue The amount of tokens to decrease the allowance by.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function decreaseApproval(
        address _spender, 
        uint256 _subtractedValue
    ) external whenNotPaused returns (bool) {
        uint256 oldValue = _allowed[msg.sender][_spender];
        
        if (_subtractedValue > oldValue) {
            _allowed[msg.sender][_spender] = 0;
        } else {
            _allowed[msg.sender][_spender] = oldValue - _subtractedValue;
        }
        
        emit Approval(msg.sender, _spender, _allowed[msg.sender][_spender]);
        
        return true;
   }

    /**
     * @dev Creates new tokens and assigns them to an address.
     * @param _to The address to which the tokens will be minted.
     * @param _amount The amount of tokens to be minted.
     * @return A boolean value indicating whether the operation succeeded.
     */
    function mintTo(
        address _to,
        uint256 _amount
    ) external whenNotPaused onlyOwner returns (bool) {
        require(_to != address(0), 'ERC20: to address is not valid');

        _balances[_to] = _balances[_to] + _amount;
        totalSupply = totalSupply + _amount;

        emit Transfer(address(0), _to, _amount);

        return true;
    }

    /**
     * @dev Burn tokens from the sender's account.
     * @param _amount The amount of tokens to burn.
     * @return A boolean indicating whether the operation succeeded.
     */
    function burn(
        uint256 _amount
    ) external whenNotPaused returns (bool) {
        require(_balances[msg.sender] >= _amount, 'ERC20: insufficient balance');

        _balances[msg.sender] = _balances[msg.sender] - _amount;
        totalSupply = totalSupply - _amount;

        emit Transfer(msg.sender, address(0), _amount);

        return true;
    }

    /**
     * @dev Burn tokens from a specified account, subject to allowance.
     * @param _from The address whose tokens will be burned.
     * @param _amount The amount of tokens to burn.
     * @return A boolean indicating whether the operation succeeded.
     */
    function burnFrom(
        address _from,
        uint256 _amount
    ) external whenNotPaused returns (bool) {
        require(_from != address(0), 'ERC20: from address is not valid');
        require(_balances[_from] >= _amount, 'ERC20: insufficient balance');
        require(_amount <= _allowed[_from][msg.sender], 'ERC20: burn from value not allowed');
        
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender] - _amount;
        _balances[_from] = _balances[_from] - _amount;
        totalSupply = totalSupply - _amount;

        emit Transfer(_from, address(0), _amount);

        return true;
    }

}