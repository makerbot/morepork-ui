#!/bin/bash

# lrelease and lupdate are linguist tools provided by Qt, the binaries for which
# are in the Qt install directory. They are also in the 'Install' directory in our
# toolchain which is pretty convenient as it allows us to provide a relative path
# and expect it to work consistently across machines assuming that everyone has the
# the default folder structure for our toolchain. Otherwise, edit the path below
# when you run this script.

../../../../Install/bin/lrelease *.ts

