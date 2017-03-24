# aci-proxy

[![Docker Automated build](https://img.shields.io/docker/automated/nailgun/aci-proxy.svg?style=flat-square)](https://hub.docker.com/r/nailgun/aci-proxy/)

*WARNING! Beta software! Don't use in production. But it can significantly speed up deployment of test clusters.*


[Squid](http://www.squid-cache.org/) based http caching proxy for Docker and rkt ACI (Application Container Images). It's useful to speed up image fetching and reduce bandwidth usage of your cluster. Unfortunately it's not tested very well so I don't recommend to use it in production.

Squid in this image configured to cache several ACI CDNs that are not well suited for caching and default squid configuration won't work.

Second endpoint provides caching of CoreOS images for iPXE boot.


## Basic usage

Start the container first:

`docker run --name=aci-proxy -d -v ~/aci-cache:/var/cache/squid -p 3128:3128 -p 3131:3131 nailgun/aci-proxy`

Pull CA certificate from the container (it's required because all ACIs are fetched via HTTPS):

`docker cp aci-proxy:/etc/squid/ca.pem .`

Check the proxy is working:

`curl -x http://localhost:3128 --cacert ca.pem https://httpbin.org/headers`

Now follow your OS destribution docs for instructions on how to install a CA certificate. For example [CoreOS](https://coreos.com/os/docs/latest/adding-certificate-authorities.html).


## Own CA certificate

You can generate your own CA certificate using this simple [script](https://github.com/nailgun/aci-proxy/blob/master/gen_ca.sh). `./gen_ca.sh` will generate `ca-bundle.pem` and `ca.pem`. Add `ca-bundle.pem` as volume to aci-proxy: `-v $PWD/ca-bundle.pem:/etc/squid/ca-bundle.pem` and install `ca.pem` as described in previous section.


## CoreOS boot images cache

If you are using CoreOS and PXE boot this is also may be useful for you to cache boot images. [Stable](https://coreos.com/releases/) images will be available at port 3131 of the container. For example:
 
* http://localhost:3131/amd64-usr/current/coreos_production_pxe.vmlinuz
* http://localhost:3131/amd64-usr/current/coreos_production_pxe_image.cpio.gz


## Logs

Access log:

`docker exec -it aci-proxy tail -f /var/log/squid/access.log`

Proxy log:

`docker exec -it aci-proxy tail -f /var/log/squid/cache.log`


## Command-line options

Entrypoint supports some options. Run container with `-h` option to see them all.


## Squid internal info page

[This endpoint](http://localhost:3128/squid-internal-mgr/info) will output some Squid internal state like used storage. It will be available if container is started with `-d` option.


## Supported ACI registries

* Docker Hub
* quay.io
* gcr.io
* registries that use GitHub to store images

Other will work too, but caching is not guaranteed. If you are going to use another registry there is possibility it will be cached out of the box if their CDN is configured to be cache friendly, but most CDNs will require you to modify [rewrite.db](https://github.com/nailgun/aci-proxy/blob/master/rewrite.db) and possibly [expire.conf](https://github.com/nailgun/aci-proxy/blob/master/expire.conf).

Warning! If you will modify `rewrite.db` ensure that column delimeter is TAB character (spaces won't work).


## Extending

If you want to extend this image, add your `custom.conf` file to `/etc/squid`. It's included by [squid.conf](squid.conf).
