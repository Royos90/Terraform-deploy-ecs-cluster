
FROM centos:latest
WORKDIR /etc/yum.repos.d/
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
RUN sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
RUN yum update -y
RUN  yum install httpd -y
RUN mkdir -p /var/www/html
WORKDIR /var/www/html
RUN chown -R apache:apache /var/www/html/
RUN touch $PWD/index.html
EXPOSE 80
CMD ["/usr/sbin/httpd","-D","FOREGROUND"]
