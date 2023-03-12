# Update-CloudKey-Gen1
Update CloudKey Gen 1 (UC-CK) inspired from [jmewing](https://github.com/jmewing/uckp-gen2)

## Steps to do

1. [Recover](https://help.ui.com/hc/en-us/articles/220334168-UniFi-Cloud-Key-Emergency-Recovery-UI) the [default firmware](https://www.ubnt.com/download/unifi/unifi-cloud-key) by Keep the reset button pressed for about 30 seconds, or until you see the recovery LED pattern in a loop (blue - off - white)
  1.1. Load Firmware
  1.2. Restart
2. SSH into the Cloudkey (credentials ubnt/ubnt)
```bash
ssh ubnt@192.168.1.30
```
3. load the update script
```bash
cd
wget https://raw.githubusercontent.com/DasULTRAS/Update-CloudKey-Gen1/main/cloudkey_update.sh
chmod +x ~/cloudkey_update.sh
bash ~/cloudkey_update.sh

```
4. Start the Script until *Latest tested version installed...*
(5. Start with logs)
```bash
./cloudkey_update.sh | tee output.txt
```
