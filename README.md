FreeTDS-iOS
===========

a script for building FreeTDS for IOS

Update:
To get it compiling I had to do the following:
1. Make sure header files are installed: xcode-select --install 
2. Make sure automake is installed: brew install automake
3. Edit freetds-1.00.15/src/apps/fisql/fisql.c to add #include <sys/stat.h>

<pre>
Reference:
http://stackoverflow.com/questions/11424846/cross-compiling-freetds-to-iphone
https://github.com/aelam/libspeex-iOS

FreeTDS example code in C:
http://lists.ibiblio.org/pipermail/freetds/2007q4/022482.html
</pre>

