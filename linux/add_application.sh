#!/usr/bin/env bash

APP_NAME=mendix
APP_DIR=~/$APP_NAME
DB_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')

sed 's#${APP_DIR}#'${APP_DIR}'#g;s#${DB_PASSWORD}#'${DB_PASSWORD}'#g' m2ee.yaml > m2ee-$APP_NAME.yaml
mkdir ~/.mendix
cp m2ee-$APP_NAME.yaml ~/.mendix/m2ee-$APP_NAME.yaml

mkdir $APP_DIR
mkdir -p $APP_DIR/runtimes/ $APP_DIR/web/ $APP_DIR/model/ $APP_DIR/data/database $APP_DIR/data/files \
  $APP_DIR/data/model-upload $APP_DIR/data/tmp $APP_DIR/tmp
cp ../applications/FileTest_20200413_0952.mda $APP_DIR/data/model-upload

sudo -u postgres psql -c "create database $APP_NAME;"
sudo -u postgres psql -c "create user mendix with encrypted password '$DB_PASSWORD';"
sudo -u postgres psql -c "grant all privileges on database $APP_NAME to mendix;"

m2ee -c ~/.mendix/m2ee-$APP_NAME.yaml -y unpack FileTest_20200413_0952.mda
m2ee -c ~/.mendix/m2ee-$APP_NAME.yaml -y download_runtime
m2ee -c ~/.mendix/m2ee-$APP_NAME.yaml -y start
m2ee -c ~/.mendix/m2ee-$APP_NAME.yaml create_admin_user
