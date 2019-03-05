using Nethereum.Hex.HexTypes;
using System.Threading.Tasks;

namespace ContractUtils {
	/// <summary>
	/// Represents a wallet
	/// </summary>
	public class Wallet {
		/// <summary>
		/// Gets the address of the wallet
		/// </summary>
		public string Address {
			get;
			private set;
		}

		/// <summary>
		/// Initializes a new wallet
		/// </summary>
		/// <param name="address">The address of the wallet</param>
		public Wallet(string address) {
			if (address == null)
				address = "0x0";
			Address = address;
		}

		/// <summary>
		/// Gets the balance of the current wallet
		/// </summary>
		public Task<HexBigInteger> GetBalance() {
			return ContractUtil.GetBalance(Address);
		}

		/// <summary>
		/// Gets the address of a wallet
		/// </summary>
		/// <param name="wallet">The wallet whose address to obtain</param>
		public static implicit operator string(Wallet wallet) {
			return wallet.Address;
		}

		/// <summary>
		/// Initializes a new wallet from the specified address
		/// </summary>
		/// <param name="address">The address of the wallet</param>
		public static implicit operator Wallet(string address) {
			return new Wallet(address);
		}
	}
}