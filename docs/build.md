# Building the Kimai Docker

The same docker file is used to build all the tagged images and is configured by combination of build arguments and targets.

## Targets

The docker file has many staging targets but two functional builds are `prod` and `dev` which correspond to the prod and development environments as outlined in the Kimai documentation.  The default is `prod`

    docker build --target=prod .
    docker build --target=dev .

## Build Arguments

### BASE

  * `BASE=apache`
  * `BASE=fpm`

Selects which PHP wrapper to use.  The Apache Debian version bundles an Apache server, and the mod-php wrapper based on a debian buster image.  The fpm-alpine version provides the fast CGI version of PHP based on an alpine image.

The Apache/Debian image is bigger (~940mb) but does not require a second container to provide http services.  Use this image for development, tests or evaluation.

The FPM image is smaller (~640mb) but requires a web server to provide the http services.  Use this image in production and see the [docker-compose](docker-compose.md) page for setting up a http server.

### KIMAI

This allows over releases of Kimai to be built.  You can specify anything that would be passed to a git clone command.

  * A tag or release, e.g. `KIMAI=10.0.2`
  * A branch name, e.g. `KIMAI=master`

### TZ

The PHP timezone for the php build.  Defaults to Europe/Berlin.

  * `TZ=Europe/London`

## Examples

Build a dev image of Kimai 1.10.1 that uses the apache bundled web server:

    docker build --target=dev --build-arg KIMAI=10.0.1 --build-arg BASE=apache .

Build a prod, FPM image of Kimai 1.10.2, localised for the UK

    docker build --target=prod --build-arg KIMAI=10.0.2 --build-arg BASE=fpm --build-arg TZ=Europe/London .

## Extending the image

If the base image(s) that are here do not contain an extension you need then you can base you own image from the ones built here.

To keep the final image size down we recommend building the php extension in an intermediate image and then copying that extension into the new image.

e.g. to add xml/xls support to the apache/debian production image

```dockerfile
FROM php:7.4.15-apache-buster AS php-base
RUN apt-get update
RUN apt-get install -y libxslt-dev libxml2-dev libssl-dev
RUN docker-php-ext-install -j$(nproc) xsl xml xmlrpc xmlwriter simplexml

FROM kimai/kimai2:apache-1.12-prod
COPY --from=php-base /usr/local/etc/php/conf.d/docker-php-ext-xsl.ini /usr/local/etc/php/conf.d/docker-php-ext-xsl.ini
COPY --from=php-base /usr/local/lib/php/extensions/no-debug-non-zts-20190902/xsl.so /usr/local/lib/php/extensions/no-debug-non-zts-20190902/xsl.so

```
