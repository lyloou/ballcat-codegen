#!/bin/bash
mvn clean package -Dprofiles.active=test -Dmaven.test.skip=true
rm -rf ./target-jar/
mkdir -p ./target-jar/

cp -f ballcat-codegen-backend/target/ballcat-codegen-backend.jar ./target-jar/ballcat-codegen-backend.jar
scp ./target-jar/ballcat-codegen-backend.jar root@106.75.185.163://root/w/compose-hub/context/ballcat-codegen/app.jar

ssh root@106.75.185.163 "pwd;cd /root/w/compose-hub;sh /root/w/compose-hub/deploy/deploy_ballcat_codegen.sh"
