using Nethereum.Hex.HexTypes;
using System.Configuration;
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

		static ConfigParams() {
			ExeConfigurationFileMap configMap = new ExeConfigurationFileMap();
			configMap.ExeConfigFilename = @"ContractUtils.dll.config";
			Configuration config = ConfigurationManager.OpenMappedExeConfiguration(configMap, ConfigurationUserLevel.None);
			if (config == null) {
				configMap.ExeConfigFilename = "scriptcs_bin" + Path.DirectorySeparatorChar + configMap.ExeConfigFilename;
				config = ConfigurationManager.OpenMappedExeConfiguration(configMap, ConfigurationUserLevel.None);
			}
			KeyValueConfigurationCollection collection = config.AppSettings.Settings;
			DefaultGas = new HexBigInteger(collection["default-gas"].Value.Trim());
			DefaultGasPrice = new HexBigInteger(collection["default-gas-price"].Value.Trim());
			DefaultValue = new HexBigInteger(collection["default-value"].Value.Trim());
			NodeUrl = collection["node-url"].Value.Trim();
		}
	}
}