#!/usr/bin/env bash

set -eo pipefail

hatch --verbose -e docs shell

pip list
