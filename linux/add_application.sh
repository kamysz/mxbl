#!/usr/bin/env bash

APP_NAME=mendix
APP_DIR=$HOME/$APP_NAME
MENDIX_DIR=$HOME/.mendix
DB_PASSWORD=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')

function createSelfSignedCert() {
  openssl genrsa -out ../certs/self_signed.key 2048
  openssl req -new -out ../certs/self_signed.csr -key ../certs/self_signed.key -config ../certs/openssl.cnf
  openssl x509 -req -days 3650 -in ../certs/self_signed.csr -signkey ../certs/self_signed.key -out ../certs/self_signed.crt
  openssl x509 -inform PEM -in ../certs/self_signed.crt > ../certs/self_signed.pem
}

sed 's#${APP_DIR}#'${APP_DIR}'#g;s#${DB_PASSWORD}#'${DB_PASSWORD}'#g' m2ee_template.yaml > m2ee_$APP_NAME.yaml
mkdir -p $MENDIX_DIR/certs
cp m2ee_$APP_NAME.yaml $HOME/.mendix/m2ee_$APP_NAME.yaml

createSelfSignedCert

cp ../certs/self_signed.crt $MENDIX_DIR/certs/self_signed.crt
cp ../certs/self_signed.key $MENDIX_DIR/certs/self_signed.key

sed 's#${APP_DIR}#'${APP_DIR}'#g;s#${APP_NAME}#'${APP_NAME}'#g;s#${MENDIX_DIR}#'${MENDIX_DIR}'#g' nginx_template > nginx_$APP_NAME
sudo cp nginx_$APP_NAME /etc/nginx/sites-available/nginx_$APP_NAME
sudo rm /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/nginx_$APP_NAME /etc/nginx/sites-enabled/default

sudo service nginx restart

mkdir $APP_DIR
mkdir -p $APP_DIR/runtimes/ $APP_DIR/web/ $APP_DIR/model/ $APP_DIR/data/database $APP_DIR/data/files \
  $APP_DIR/data/model-upload $APP_DIR/data/tmp $APP_DIR/tmp
cp ../applications/FileTest_20200413_0952.mda $APP_DIR/data/model-upload

sudo -u postgres psql -c "create database $APP_NAME;"
sudo -u postgres psql -c "create user mendix with encrypted password '$DB_PASSWORD';"
sudo -u postgres psql -c "grant all privileges on database $APP_NAME to mendix;"

m2ee -c ~/.mendix/m2ee_$APP_NAME.yaml -y unpack FileTest_20200413_0952.mda
m2ee -c ~/.mendix/m2ee_$APP_NAME.yaml -y download_runtime
m2ee -c ~/.mendix/m2ee_$APP_NAME.yaml -y start
m2ee -c ~/.mendix/m2ee_$APP_NAME.yaml create_admin_user
