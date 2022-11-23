FROM openjdk:11
LABEL author 'hari'
ENV SPC_VERSION=$VERSION
EXPOSE 8080
RUN useradd -m appuser
USER appserver
WORKDIR /home/appserver/remote_root
ADD --chown=appserver  /home/appuser/spring-petclinic-$SPC_VERSION.jar
CMD ["java", "-jar", "/home/appuser/spring-petclinic-$SPC_VERSION.jar"]