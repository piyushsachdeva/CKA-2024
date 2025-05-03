#!/bin/bash
vagrant destroy -f
vagrant box remove bento/ubuntu-22.04 --all
vagrant box add bento/ubuntu-22.04
