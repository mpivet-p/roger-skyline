#!/bin/bash
sudo apt-get update &>> /var/log/update_script.log
sudo apt-get upgrade &>> /var/log/update_script.log

