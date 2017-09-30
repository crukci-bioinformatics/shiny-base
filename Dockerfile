FROM centos:7

MAINTAINER Matt Eldridge "matthew.eldridge@cruk.cam.ac.uk"

RUN yum groupinstall -y 'development tools'
RUN yum install -y wget libxml2-devel libcurl-devel openssl-devel

RUN wget https://download3.rstudio.org/centos6.3/x86_64/shiny-server-1.5.5.872-rh6-x86_64.rpm
RUN yum install -y --nogpgcheck shiny-server-1.5.5.872-rh6-x86_64.rpm

RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
RUN yum install -y R

RUN R -e 'install.packages(c("shiny", "rmarkdown"), repos = "https://cran.rstudio.com")'
RUN R -e 'install.packages(c("tidyverse"), repos = "https://cran.rstudio.com")'

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

# running shiny server as shiny user requires write access to /var/lib/shiny-server
RUN chown -R shiny:shiny /var/lib/shiny-server

CMD ["/usr/bin/shiny-server.sh"]

