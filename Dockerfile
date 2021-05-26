FROM centos:8.3.2011

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

# install R
ARG R_VERSION=4.1.0
RUN dnf -y install https://cdn.rstudio.com/r/centos-8/pkgs/R-${R_VERSION}-1-1.x86_64.rpm
RUN ln -s /opt/R/${R_VERSION}/bin/R /usr/local/bin/R
RUN ln -s /opt/R/${R_VERSION}/bin/Rscript /usr/local/bin/Rscript

# install Shiny package
RUN R -e 'install.packages("shiny", repos = "https://cran.rstudio.com")'

# install Shiny server
RUN dnf -y install https://download3.rstudio.org/centos7/x86_64/shiny-server-1.5.17.960-x86_64.rpm

# install additional R packages
RUN R -e 'install.packages(c("shinyjs", "rmarkdown", "colourpicker"), repos = "https://cloud.r-project.org")'
RUN R -e 'install.packages("tidyverse", repos = "https://cloud.r-project.org")'
RUN R -e 'install.packages("plotly", repos = "https://cloud.r-project.org")'
RUN R -e 'install.packages("DT", repos = "https://cloud.r-project.org")'

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh
RUN chmod ugo+rx /usr/bin/shiny-server.sh

# ensure the user account that is running the shiny server process has write privilege for /var/lib/shiny-server
RUN chmod ugo+rwx /var/lib/shiny-server

CMD ["/usr/bin/shiny-server.sh"]

