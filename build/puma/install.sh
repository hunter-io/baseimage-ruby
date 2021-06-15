#!/bin/bash
set -e

# Install puma runit service
mkdir /etc/service/puma
cp build/runit/puma /etc/service/puma/run
chmod +x /etc/service/puma/run
