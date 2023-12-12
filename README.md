# Dockerized Bitcoind
## Run your bitcoin node from source on multiple architectures with a few commands

* Tested on aarch64 and x86_64
* Mainnet, Regtest and Testnet
* Support for Tor Onion proxying

## Usage

### copy .env.example to .env and check/change the configurations

### Build the image
```
./control.sh build
```

### Start
```
./control.sh up
```

### Run bitcoin-cli commands
```
./control.sh bitcoin-cli '--getinfo'
```

### Stop
```
./control.sh down
```

### Clean data (be careful!)
```
./control.sh clean
```
