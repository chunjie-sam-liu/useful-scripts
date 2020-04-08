#!/usr/bin/env bash

# thanks to wulabing original repo.


# one key
wget -N --no-check-certificate -q -O install.sh "https://raw.githubusercontent.com/chunjie-sam-liu/V2Ray-onekey/master/install.sh"
chmod +x install.sh
bash install.sh

## 11 bbr accelerating scripts
### 2 bbr plus core with <No> and restart vps

#-----------------------------------
# run install.sh again.
bash install.sh

## 11 bbr accelerating scripts
### 7 bbr plus accelerating

#-----------------------------------
# run install.sh again.
bash install.sh

## 1 install v2ray (Nginx+ws+tls)
### input domain (subdomain.domain.xxx)
### connecting port: default 443
### alterID: 55