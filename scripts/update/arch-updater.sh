#!/bin/bash

paru -Syu

#KERNEL=$(paru -Q | grep "^linux" | cut -d' ' -f1 | grep -v firmware | grep -v api | grep -v headers)
#sudo mkinitcpio -p $KERNEL
#sudo grub-mkconfig -o /boot/grub/grub.cfg

