#!/usr/bin/env bash

EXIT_PROMPT="This script will now exit"

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

function getMachineType() {
  unameOut="$(uname -s)"
  case "${unameOut}" in
  Linux*) machine=Linux ;;
  Darwin*)
    echo "Detected Mac OSX"
    machine=Mac
    ;;
  CYGWIN*) machine=Windows ;;
  MINGW*) machine=Windows ;;
  *) machine="UNKNOWN:${unameOut}" ;;
  esac
}

function installPackageManager() {
  case "${machine}" in
  Linux)
    if which apt-get >/dev/null; then
      echo "apt-get is already installed"
    else
      echo "apt-get is not installed. Installing now..."
      wget http://security.ubuntu.com/ubuntu/pool/main/a/apt/apt_1.0.1ubuntu2.17_amd64.deb -O apt.deb
      sudo dpkg -i apt.deb
      if ! which apt-get >/dev/null; then
        echo "Unable to install apt-get"
        echo "Please manually install apt-get and try again"
        echo $EXIT_PROMPT
        exit
      fi
    fi
    ;;
  Mac)
    echo "Checking if Homebrew is already installed"
    if which brew >/dev/null; then
      echo "Homebrew is already installed"
    else
      echo "Homebrew is not installed. Installing now..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
      if ! which brew >/dev/null; then
        echo "Unable to install Homebrew"
        echo "Please manually install Homebrew and try again"
        echo $EXIT_PROMPT
        exit
      fi
    fi
    ;;
  Windows) ;;
  esac
}

function installMiniKube() {
  case "${machine}" in
  Linux)
    if which minikube >/dev/null; then
      echo "Minikube is already installed"
    else
      echo "Minikube is not installed. Installing now..."
      wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
      chmod +x minikube-linux-amd64
      sudo mv minikube-linux-amd64 /usr/local/bin/minikube
      if ! which minikube >/dev/null; then
        echo "Unable to install Minikube"
        echo "Please manually install Minikube and try again"
        echo $EXIT_PROMPT
        exit
      fi
      curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
      chmod +x ./kubectl
      sudo mv ./kubectl /usr/local/bin/kubectl
      if ! which kubectl >/dev/null; then
        echo "Unable to install kubectl"
        echo "Please manually install kubectl and try again"
        echo $EXIT_PROMPT
        exit
      fi
    fi
    ;;
  Mac)
    if which minikube >/dev/null; then
      echo "Minikube is already installed"
    else
      echo "Minikube is not installed. Installing now..."
      brew install minikube
      if ! which minikube >/dev/null; then
        echo "Unable to install Minikube"
        echo "Please manually install Minikube and try again"
        echo $EXIT_PROMPT
        exit
      fi
    fi
    ;;
  Windows) ;;
  esac
}

function startMinikube() {

  case "${machine}" in
  Linux)
    minikube start --driver docker
    ;;
  Mac)
    minikube start --driver=hyperkit
    ;;
  Windows) ;;
  esac
  minikube addons enable registry
  minikube addons enable ingress
}

getMachineType
installPackageManager
installMiniKube
startMinikube

echo "SUCCESS"
