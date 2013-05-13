contains(MEEGO_EDITION,harmattan): {
    PREFIX = /opt/jollacountdown
}

QML_FOLDER = $${PREFIX}/qml
APP_FOLDER = $${PREFIX}/bin

DEFINES += 'MAIN_QML_PATH=\'\"$${QML_FOLDER}/main.qml\"\''

TEMPLATE = app
TARGET = jollacountdown2

QT = core gui declarative opengl network

HEADERS +=      timecomputer.h \
                viewlauncher.h \
                twitterparser.h \
                tweet.h

SOURCES +=      main.cpp \
                timecomputer.cpp \
                viewlauncher.cpp \
                twitterparser.cpp \
                tweet.cpp

include(qjson.pri)

QML_FILES +=    main.qml \
                TwitterView.qml \
                Events.qml \
                EventsContent.qml \
                sailfish.jpg \
                jollafr.jpg \
                jolla-logo_00.png \
                jolla-logo_01.png \
                jolla-logo_02.png \
                jolla-logo_03.png \
                jolla-logo_04.png \
                jolla-logo_05.png \
                jolla-logo_06.png \
                jolla-logo_07.png \
                jolla-logo_08.png \
                jolla-logo_09.png


contains(MEEGO_EDITION, harmattan):{
    OTHER_FILES +=  qtc_packaging/debian_harmattan/rules \
                    qtc_packaging/debian_harmattan/README \
                    qtc_packaging/debian_harmattan/manifest.aegis \
                    qtc_packaging/debian_harmattan/copyright \
                    qtc_packaging/debian_harmattan/control \
                    qtc_packaging/debian_harmattan/compat \
                    qtc_packaging/debian_harmattan/changelog \
}

include(deployment.pri)
