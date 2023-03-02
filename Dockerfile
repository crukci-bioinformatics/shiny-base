FROM debian:11.6-slim
 
LABEL authors="Matt Eldridge" \
      version="1.1" \
      description="Base Docker image for Shiny applications"

RUN apt-get update && \
    apt-get install -y curl gdebi-core && \
    apt-get clean

# install Shiny server (https://www.rstudio.com/products/shiny/download-server/ubuntu)
ARG SHINY_SERVER_VERSION=1.5.18.987-amd64
RUN curl -O https://download3.rstudio.org/ubuntu-18.04/x86_64/shiny-server-${SHINY_SERVER_VERSION}.deb
RUN gdebi -n shiny-server-${SHINY_SERVER_VERSION}.deb
RUN rm shiny-server-${SHINY_SERVER_VERSION}.deb

# ensure the user account that is running the shiny server process has write privilege for /var/lib/shiny-server
RUN chmod ugo+rwx /var/lib/shiny-server

ARG CONDA_VERSION=py310_23.1.0-1
ARG CONDA_SHA256=32d73e1bc33fda089d7cd9ef4c1be542616bd8e437d1f77afeeaf7afdb019787

RUN curl https://repo.anaconda.com/miniconda/Miniconda3-${CONDA_VERSION}-Linux-x86_64.sh -o miniconda3.sh && \
    echo "${CONDA_SHA256}  miniconda3.sh" > miniconda3.sha256 && \
    sha256sum -c miniconda3.sha256 && \
    mkdir -p /opt && \
    sh miniconda3.sh -b -p /opt/conda && \
    rm miniconda3.sh miniconda3.sha256

COPY conda.yml .

RUN /opt/conda/bin/conda env create -f conda.yml && /opt/conda/bin/conda clean -a

ENV PATH /opt/conda/envs/shiny_base/bin:$PATH

# expose port that Shiny server listens on (can be mapped to another port on the host)
EXPOSE 3838

# command to run when starting the container using 'docker run'
CMD exec shiny-server >> /var/log/shiny-server/shiny-server.log 2>&1

