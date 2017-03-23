#!/bin/sh

set -e

conf_file=/etc/squid/squid.conf
maximum_object_size="1 GB"
cache_dir_size="10240"

while [[ $# -gt 0 ]]; do
    case "$1" in
        -s|--cache-dir-size)
            cache_dir_size="$2"
            shift
        ;;
        -o|--max-object-size)
            maximum_object_size="$2"
            shift
        ;;
        -d|--debug)
            conf_file=/etc/squid/debug.conf
        ;;
        -h|--help)
            echo "-s|--cache-dir-size: total max cache dir size in MB (default: 10240)"
            echo "-o|--max-object-size: max size of single object (defualt: 1 GB)"
            echo "-d|--debug: enable verbose log output"
            echo "-h|--help: this help"
            exit 0
        ;;
        *)
            echo "unknown option: $1" >&2
            exit 1
        ;;
    esac

    shift
done

eval "echo \"$(cat /etc/squid/cache.conf.tpl)\"" > /etc/squid/cache.conf

if [ -z "$(ls -A /var/cache/squid)" ]; then
    squid -zN -f ${conf_file}
    chown -R squid:squid /var/cache/squid
    rm /var/log/squid/cache.log
fi

exec squid -NYCd1 -f ${conf_file}
