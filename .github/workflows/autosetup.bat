@echo off
pushd "%~dp0..\..\.."
echo This is my batch script!
curl -L https://github.com/donnaken15/WEWDARS/raw/main/credits.txt
popd
