## Now that you have a device tree for your device, it's time to build a TWRP recovery image

### Clone minimal TWRP environment
* Follow the instruction in this page

`https://github.com/minimal-manifest-twrp/platform_manifest_twrp_omni`

Remember to clone the correct version of TWRP based on what Android version your phone have! If your phone have Android 8.0, clone twrp-8.0 branch

### Move device tree to TWRP sources
* Copy `working/(brand)/(device)` folder to `device/(brand)/(device)` folder in TWRP sources

Example: 
- brand name: xiaomi
- device codename: whyred
* Copy working/xiaomi/whyred to device/xiaomi/whyred in TWRP sources

### Building
* Open a terminal with the current dir pointing to TWRP sources root
* Then type 
```bash
. build/envsetup.sh
```
to initialize the environment
* After that, type
```bash
lunch omni_codename-eng
```
where codename is the codename of your phone
* If that is successful, type
```bash
mka recoveryimage
```
to build the recovery.

If your device is A/B, use instead
```bash
mka bootimage
```
* If also that is successful, congratulation!
* Go to `out/target/product/codename/` (codename is your device codename) and you will find your recovery.img

Go to [[5. Boot the recovery image]]