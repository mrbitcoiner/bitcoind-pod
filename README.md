# Dockerized Bitcoind
## Run your bitcoin node from source on multiple architectures with a few commands

* OBS: Tested on an MBP 13 M1 (aarch64) but should also work with x86_64 processors.
* Keeping only the last 10GB of timechain in the default config. You can override this as described below.


### Copy the .example config file
```
./control.sh bitcoinconfigcp
```

### Check (or change) the configurations
```
vi containers/bitcoind/volume/config/bitcoinConfig
```

### Start:
```
./control.sh up
```

### Stop:
```
./control.sh down
```

### Clean data:
```
./control.sh clean
```