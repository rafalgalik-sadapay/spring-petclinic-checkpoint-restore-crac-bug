#!/usr/bin/env bash
set -e

case $(uname -m) in
#    arm64)   url="https://cdn.azul.com/zulu/bin/zulu21.30.23-ca-crac-jdk21.0.1-linux_aarch64.tar.gz" ;;
    arm64)   url="https://cdn.azul.com/zulu/bin/zulu21.32.17-ca-crac-jdk21.0.2-linux_aarch64.tar.gz" ;;

#    arm64)   url="https://cdn.azul.com/zulu/bin/zulu17.46.29-ca-crac-jdk17.0.9-linux_aarch64.tar.gz" ;;
    *)       url="https://cdn.azul.com/zulu/bin/zulu17.44.55-ca-crac-jdk17.0.8.1-linux_x64.tar.gz" ;;
esac

echo "Using CRaC enabled JDK $url"

./mvnw clean package -DskipTests
#./gradlew clean assemble
docker build -t sdeleuze/spring-boot-crac-demo:builder --build-arg CRAC_JDK_URL=$url .
docker run -d --privileged --rm --name=spring-boot-crac-demo --ulimit nofile=1024 -p 8080:8080 -v $(pwd)/build:/opt/mnt -e FLAG=$1 sdeleuze/spring-boot-crac-demo:builder
echo "Please wait during creating the checkpoint..."
sleep 60
docker commit --change='ENTRYPOINT ["/opt/app/entrypoint.sh"]' $(docker ps -qf "name=spring-boot-crac-demo") sdeleuze/spring-boot-crac-demo:checkpoint
docker kill $(docker ps -qf "name=spring-boot-crac-demo")
