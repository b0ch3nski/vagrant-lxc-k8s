#!/usr/bin/env bash

proxyon() {
  export http_proxy="{{ ansible_env.http_proxy }}"
  export https_proxy="{{ ansible_env.https_proxy }}"
  export no_proxy="{{ ansible_env.no_proxy }}"
}

proxyoff() {
  unset $(env | awk -F'=' '/_proxy/ { print $1 }')
}

proxyon
