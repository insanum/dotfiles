@echo off

C:
chdir C:\cygwin\bin

set HOME=C:\edavis

rxvt -g 120x50 -fn "Courier-16" -e bash --login -i

