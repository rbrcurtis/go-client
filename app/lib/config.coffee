config = 

	server: "https://go.mut8ed.com:4000/"
	web: "https://go.mut8ed.com/"
	walletPackage: 'production_config'
	debounceWait: 10
	version: "1.3.2"

try
	config = _.extend config, require './local'
catch ex

module.exports = config
