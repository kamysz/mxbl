#!/usr/bin/env bash

EXIT_PROMPT="This script will now exit"

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
  Linux);;
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
