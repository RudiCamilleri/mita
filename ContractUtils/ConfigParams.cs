using Nethereum.Hex.HexTypes;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.IO;

namespace ContractUtils {
	/// <summary>
	/// Contains the assembly-wide configuration parameters specified in the accompanying config file
	/// </summary>
	public static class ConfigParams {
		/// <summary>
		/// The default gas value (0x6691b7)
		/// </summary>
		public static HexBigInteger DefaultGas;
		/// <summary>
		/// The default gas price (0x77359400)
		/// </summary>
		public static HexBigInteger DefaultGasPrice;
		/// <summary>
		/// The default transaction value (zero)
		/// </summary>
		public static HexBigInteger DefaultValue;
		/// <summary>
		/// The default Ethereum node url
		/// </summary>
		public static string NodeUrl;

		/// <summary>
		/// Initializes the class configuration
		/// </summary>
		static ConfigParams() {
			LoadConfigFromFile();
		}

		/// <summary>
		/// Loads the default configuration from contract_defaults.json
		/// </summary>
		public static void LoadConfigFromFile() {
			LoadConfigFromFile("contract_defaults.json");
		}

		/// <summary>
		/// Loads the default configuration from the specified JSON file
		/// </summary>
		/// <param name="path">The path to the JSON file</param>
		public static void LoadConfigFromFile(string path) {
			string json = null;
			try {
				using (FileStream stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
					using (StreamReader reader = new StreamReader(stream))
						json = reader.ReadToEnd();
				}
			} catch {
			}
			if (json == null) {
				path = "scriptcs_bin" + Path.DirectorySeparatorChar + path;
				using (FileStream stream = new FileStream(path, FileMode.Open, FileAccess.Read, FileShare.ReadWrite)) {
					using (StreamReader reader = new StreamReader(stream))
						json = reader.ReadToEnd();
				}
			}
			LoadConfig(json);
		}

		/// <summary>
		/// Loads the configuration from the specified JSON object
		/// </summary>
		/// <param name="json">The JSON object string</param>
		private static void LoadConfig(string json) {
			JObject config = (JObject) JsonConvert.DeserializeObject(json);
			DefaultGas = new HexBigInteger(config["default_gas"].ToString().Trim());
			DefaultGasPrice = new HexBigInteger(config["default_gas_price"].ToString().Trim());
			DefaultValue = new HexBigInteger(config["default_value"].ToString().Trim());
			NodeUrl = config["node_url"].ToString().Trim();
		}
	}
}