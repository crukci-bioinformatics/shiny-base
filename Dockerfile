FROM centos:8

MAINTAINER Matt Eldridge "matthew.eldridge@cruk.cam.ac.uk"

# install English language pack to prevent language/locale issues
RUN dnf -y install glibc-langpack-en

# additional packages from EPEL
RUN dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm

# enable PowerTools as recommended in EPEL wiki
RUN dnf -y install dnf-plugins-core
RUN dnf config-manager --set-enabled powertools

# install development tools and various development libraries
RUN dnf -y groupinstall 'development tools'
RUN dnf -y install libxml2-devel libcurl-devel openssl-devel
RUN dnf -y install zlib-devel bzip2-devel xz-devel
RUN dnf -y install libpng-devel

# install Shiny server
RUN dnf -y install https://download3.rstudio.org/centos6.3/x86_64/shiny-server-1.5.15.953-x86_64.rpm

# install R
RUN dnf -y install https://cdn.rstudio.com/r/centos-8/pkgs/R-4.0.3-1-1.x86_64.rpm
RUN ln -s /opt/R/4.0.3/bin/R /usr/local/bin/R
RUN ln -s /opt/R/4.0.3/bin/Rscript /usr/local/bin/Rscript

# install R packages
RUN R -e 'install.packages(c("shiny", "shinyjs", "rmarkdown", "colourpicker"), repos = "https://cloud.r-project.org")'
RUN R -e 'install.packages("tidyverse", repos = "https://cloud.r-project.org")'
RUN R -e 'install.packages("DT", repos = "https://cloud.r-project.org")'

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod ugo+rx /usr/bin/shiny-server.sh

# ensure the user account that is running the shiny server process has write privilege for /var/lib/shiny-server
RUN chmod ugo+rwx /var/lib/shiny-server

CMD ["/usr/bin/shiny-server.sh"]

