#!/bin/sh
export PORTAL_HOME=$(cd "$(dirname "$0")"; pwd)
cd $PORTAL_HOME
revel run portal
