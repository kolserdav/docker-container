# Troubleshooting

## Multi platform build not supported
```sh
ERROR: Multi-platform build is not supported for the docker driver.
Switch to a different driver, or turn on the containerd image store, and try again.
```  
Solve:  
```sh
make multiarch-install
```