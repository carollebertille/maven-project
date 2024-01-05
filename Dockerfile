FROM tomcat:8.0-alpine
RUN rm -rf /usr/local/tomcat/webapps/*
COPY webapp/target/webapp.war  /usr/local/tomcat/webapps
EXPOSE 8080
CMD ["catalina.sh", "run"]