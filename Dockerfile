FROM httpd:latest

RUN apt-get update && apt-get install -y libapache2-mod-auth-openidc ca-certificates
COPY my-httpd.conf /usr/local/apache2/conf/httpd.conf
COPY run.sh /usr/local/bin/run-httpd.sh

ENTRYPOINT [ "/usr/local/bin/run-httpd.sh" ]