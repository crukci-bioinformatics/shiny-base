Base Docker image for Shiny applications
========================================

Dockerfile used to create an image for deploying R/Shiny applications using Shiny Server. Intended as a base image on which Shiny applications can be built. Includes shiny and tidyverse R packages.

The image is available on [Docker Hub](https://hub.docker.com/r/crukcibioinformatics/shiny-base/).


## Usage

To run a Shiny Server instance with no applications installed within a temporary container:

```sh
docker run -p 3838:3838 crukcibioinformatics/shiny-base
```

The Shiny Server test web page should be accessible at http://localhost:3838. Substitute localhost with the actual host name if not running locally.

Shiny server runs on port 3838 by default and the -p option must be used to publish the port used within the container to the host.


## Logging

Log files are written within the container to /var/log/shiny-server; separate files are used for Shiny Server logs and any installed Shiny applications. To write log files to a directory on the host file system, the host directory can be mounted within the container as follows:

```sh
mkdir -p logs
chmod ugo+rwx logs
docker run -p 3838:3838 -v ${PWD}/logs:/var/log/shiny-server crukcibioinformatics/shiny-base
```

This allows the log files to be accessible from outside the container.


## Configuring Shiny Server

Shiny Server can be configured by creating a configuration file and using this in place of the default one installed in the Docker container in /etc/shiny-server/shiny-server.conf.

For example, in the following configuration file some network protocols that may cause problems with deployment behind a proxy server have been disabled.

```
# Instruct Shiny Server to run applications as the user "shiny"
run_as shiny;

# Define a server that listens on port 3838
server {
  listen 3838;

  # Define a location at the base URL
  location / {

    # Host the directory of Shiny Apps stored in this directory
    site_dir /srv/shiny-server;

    # Log all Shiny output to files in this directory
    log_dir /var/log/shiny-server;

    # When a user visits the base URL rather than a particular application,
    # an index of the applications available in this directory will be shown.
    directory_index on;

    # disable some network protocols that seem to be causing issues with deployment behind a proxy server
    disable_protocols xdr-streaming xhr-streaming iframe-eventsource iframe-htmlfile;
  }
}
```

Assuming the configuration file is named shiny-server.conf, the following will deploy the Shiny Server using this configuration:

```sh
docker run -p 8080:8080 -v ${PWD}/shiny-server.conf:/etc/shiny-server/shiny-server.conf -v ${PWD}/logs:/var/log/shiny-server crukcibioinformatics/shiny-base
```


## Deploying Shiny applications

For simple Shiny applications that do not require installation of additional R packages, it is possible to deploy those applications within a Shiny Server using this image by mounting the host directory containing the application R code within the container.

```sh
docker run -p 3838:3838 -v ${PWD}/myapp:/srv/shiny-server/myapp -v ${PWD}/logs:/var/log/shiny-server crukcibioinformatics/shiny-base
```

The application should be available at http://localhost:3838/myapp.


## Building Docker images for Shiny applications

Most Shiny applications will require additional R packages, data files and images. The main purpose of this image is to act as a base from which those Shiny applications can be built.

The following shows an example Dockerfile that installs an R package needed by the application, creates directories for the Shiny application within the image and copies the application R code and some images into it.

```
FROM crukcibioinformatics/shiny-base

RUN R -e 'install.packages("DT", repos = "https://cloud.r-project.org")'

RUN mkdir /srv/shiny-server/myapp
RUN mkdir /srv/shiny-server/myapp/www

COPY app.R /srv/shiny-server/myapp/
COPY www/* /srv/shiny-server/myapp/www/
```

This can be built using `docker build` in the usual way:

```sh
docker build --tag=myapp .
```

To deploy the application in detached mode (`-d`), listening on the host's port 80 (`-p 80:3838`) and running more securely within the container as the shiny user instead of root:

```sh
docker run -u shiny -d -p 80:3838 -v ${PWD}/logs:/var/log/shiny-server myapp
```

The application should be available at http://localhost/myapp.


