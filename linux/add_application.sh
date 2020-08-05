#!/usr/bin/env bash

APP_DIR=~/mendix

mkdir ~/.m2ee
cp m2ee.yaml ~/.m2ee/m2ee.yaml
mkdir $APP_DIR
mkdir -p $APP_DIR/runtimes/ $APP_DIR/web/ $APP_DIR/model/ $APP_DIR/data/database $APP_DIR/data/files \
  $APP_DIR/data/model-upload $APP_DIR/data/tmp $APP_DIR/tmp
cp FileTest_20200413_0952.mda data/model-upload

m2ee -y unpack FileTest_20200413_0952.mda
m2ee -y download_runtime
m2ee -y start
m2ee create_admin_user
