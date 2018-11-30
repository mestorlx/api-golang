pragma solidity ^0.4.24;
import "zos-lib/contracts/Initializable.sol";
import "openzeppelin-eth/contracts/token/ERC20/ERC20.sol";
// import "../node_modules/openzeppelin-eth/contracts/token/ERC20/ERC20Mintable.sol";
// import "../node_modules/openzeppelin-eth/contracts/token/ERC20/ERC20Detailed.sol";
// import "../node_modules/openzeppelin-eth/contracts/token/ERC20/ERC20Capped.sol";
import "openzeppelin-eth/contracts/ownership/Ownable.sol";

// contract DiaToken is Initializable, ERC20, ERC20Detailed, ERC20Mintable, ERC20Capped, Ownable {
// 	function initialize(ERC20Detailed _legacyToken, ERC20Migrator _migrator) initializer public {
// 		ERC20Mintable.initialize(this.Owner);
// 		ERC20Detailed.initialize("DIA Token", "DIA", 10);
// 		_migrator.beginMigration(this);
// 	}
// }
contract DIAToken is Initializable, ERC20, Ownable {
	function initialize(address _owner) public initializer()  {
		Ownable.initialize(_owner);
	}
// 	// function initialize(ERC20Detailed _legacyToken, ERC20Migrator _migrator) initializer public {
// 	// 	ERC20Mintable.initialize(this.Owner);
// 	// 	ERC20Detailed.initialize("DIA Token", "DIA", 10);
// 	// 	_migrator.beginMigration(this);
// 	// }
}
// contract DiaToken {

// }