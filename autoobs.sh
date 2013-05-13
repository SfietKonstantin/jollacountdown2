#!/bin/sh
cp qtc_packaging/debian_harmattan debian -R
cp debian/rules-obs debian/rules -f
/opt/Qt/QtSDK/Madde/bin/mad -t harmattan_10.2011.34-1_rt1.2 dpkg-buildpackage -sa -S -uc -us -Imoc -Iobj -Ircc -Iui -I.svn -I*.deb -I*.changes -Iqtc_packaging -IMakefile -I*.pro.user -Ibuild -Iinstall
rm debian -R
