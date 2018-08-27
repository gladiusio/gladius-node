## What these files are

### Wallet
 - A wallet with the address `0x6531a634bbb040b00f32718fa8d9fa197274f1d0`
 that serves as the pool manager address


### Configs
#### controld
- Sets up the wallet from above as the pool manager address, so we can use
that to update the pool data fields
- Turns on debugging

### networkd
- Disables IP detection so we don't update with our public IP (and use the
  testing one instead)
- Disables the heartbeat so that we don't have a heartbeat potentially creating
  state inconsistencies and making our tests non-deterministic
- Turns on debugging
