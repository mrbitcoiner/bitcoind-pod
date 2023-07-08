# Dockerized Bitcoind
## Run your bitcoin node from source on multiple architectures with a few commands

* Tested on aarch64 and x86_64
* Mainnet, Regtest and Testnet
* Support for Tor Onion proxying

## Usage

### copy .env.example to .env and check/change the configurations

### Start
```
./control.sh up
```

### Run bitcoin-cli commands
```
./control.sh cli_wrapper '--getinfo'
```

### Stop
```
./control.sh down
```

### Clean data
```
./control.sh clean
```
