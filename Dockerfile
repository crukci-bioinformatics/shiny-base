FROM debian:12.12-slim
 
LABEL authors="Matt Eldridge" \
      version="1.3-snapshot" \
      description="Base Docker image for Shiny applications"

RUN apt-get update && \
    apt-get install -y curl gdebi-core && \
    apt-get clean

# install Shiny server (https://posit.co/download/shiny-server)
ARG SHINY_SERVER_VERSION=1.5.23.1030-amd64
RUN curl -O https://download3.rstudio.org/ubuntu-20.04/x86_64/shiny-server-${SHINY_SERVER_VERSION}.deb
RUN gdebi -n shiny-server-${SHINY_SERVER_VERSION}.deb
RUN rm shiny-server-${SHINY_SERVER_VERSION}.deb

# ensure the user account that is running the shiny server process has write privilege for /var/lib/shiny-server
RUN chmod ugo+rwx /var/lib/shiny-server

ARG MINIFORGE3_VERSION=25.3.1-0

RUN curl -LO https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE3_VERSION}/Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh && \
    curl -LO https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE3_VERSION}/Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh.sha256 && \
    sha256sum -c Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh.sha256 && \
    rm Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh.sha256 && \
    mkdir -p /opt && \
    sh Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh -b -p /opt/miniforge3 && \
    rm Miniforge3-${MINIFORGE3_VERSION}-Linux-x86_64.sh

COPY conda.yml .

RUN /opt/miniforge3/bin/mamba env create -f conda.yml && \
    /opt/miniforge3/bin/mamba clean -a

ENV PATH /opt/miniforge3/envs/shiny_base/bin:$PATH

# expose port that Shiny server listens on (can be mapped to another port on the host)
EXPOSE 3838

# command to run when starting the container using 'docker run'
CMD exec shiny-server >> /var/log/shiny-server/shiny-server.log 2>&1

