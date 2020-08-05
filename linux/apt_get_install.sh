#!/usr/bin/env bash

function wait_for_apt_get() {
  i=0
  tput sc
  while sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1; do
    case $(($i % 4)) in
    0) j="-" ;;
    1) j="\\" ;;
    2) j="|" ;;
    3) j="/" ;;
    esac
    tput rc
    echo -en "\r[$j] Waiting for other apt-get processes to finish..."
    sleep 0.5
    ((i = i + 1))
  done
  tput rc
}

wait_for_apt_get
sudo apt-get -y install software-properties-common >/dev/null

sudo add-apt-repository 'deb http://packages.mendix.com/platform/debian/ stretch main contrib non-free'
sudo wget -q -O - https://packages.mendix.com/mendix-debian-archive-key.asc | sudo apt-key add -
sudo apt-get update

wait_for_apt_get
sudo apt-get install -y debian-mendix-archive-keyring m2ee-tools

if ! which python >/dev/null; then
  wait_for_apt_get
  sudo apt-get -y install python >/dev/null
fi

if ! which java >/dev/null; then
  wait_for_apt_get
  sudo apt-get install -y openjdk-11-jre-headless >/dev/null
fi

if ! which psql >/dev/null; then
  wait_for_apt_get
  sudo apt-get install -y postgresql postgresql-contrib >/dev/null
  sudo update-rc.d postgresql enable
  sudo -u postgres psql -c "create database mendix;"
  sudo -u postgres psql -c "create user mendix with encrypted password 'mendix';"
  sudo -u postgres psql -c "grant all privileges on database mendix to mendix;"
fi