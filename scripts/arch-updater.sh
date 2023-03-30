#!/bin/bash

paru -Syu

KERNEL="linux-cachyos-bmq"

sudo mkinitcpio -p $KERNEL
sudo grub-mkconfig -o /boot/grub/grub.cfg

