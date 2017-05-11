cocos compile -s ../.. -p android -m release --lua-encrypt --lua-encrypt-key xxxxxx --lua-encrypt-sign xxxxxx

set ymd=%date:~5,2%%date:~8,2%
set hms=%NOW:~0,2%%NOW:~3,2%
copy .\publish\android\xxxxx-release-signed.apk xxxxx-release-signed[%ymd%%hms%].apk