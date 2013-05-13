/*
 * Copyright (C) 2013 Lucien XU <sfietkonstantin@free.fr>
 *
 * You may use this file under the terms of the BSD license as follows:
 *
 * "Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are
 * met:
 * * Redistributions of source code must retain the above copyright
 * notice, this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright
 * notice, this list of conditions and the following disclaimer in
 * the documentation and/or other materials provided with the
 * distribution.
 * * The names of its contributors may not be used to endorse or promote
 * products derived from this software without specific prior written
 * permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
 */

import QtQuick 1.1
import QtMobility.systeminfo 1.2
import com.nokia.meego 1.0

PageStackWindow {
    id: window
    Component.onCompleted: {
        theme.inverted = true
        checkTimerToRun()
        Twitter.load()
    }

    function checkTimerToRun() {
        if (platformWindow.active && platformWindow.visible) {
            alignedTimer.stop()
            timer.start()
            mainPage.fastUpdate = true
        } else {
            alignedTimer.start()
            timer.stop()
            mainPage.fastUpdate = false
        }
        events.updateRequested()
    }


    initialPage: Page {
        id: mainPage
        property bool fastUpdate: true
        clip: true
        tools: ToolBarLayout {
            Item {}
            ToolIcon {
                iconId: "toolbar-view-menu"
                onClicked: menu.open()
            }
        }

        Menu {
            id: menu
            MenuLayout {
                MenuItem {
                    id: backgroundItem
                    property bool useJollaBackground: true
                    text: useJollaBackground ? qsTr("Use JollaFr background")
                                             : qsTr("Use Jolla background")
                    onClicked: {
                        useJollaBackground = !useJollaBackground
                        menu.close()
                    }
                }
                MenuItem {
                    text: qsTr("About")
                    onClicked: {
                        window.pageStack.push(aboutPage)
                        menu.close()
                    }
                }
            }
        }

        Image {
            anchors.centerIn: parent
            source: backgroundItem.useJollaBackground ? "sailfish.jpg" : "jollafr.jpg"
        }

        TwitterView {
            anchors.top: parent.top; anchors.left: parent.left
            width: window.inPortrait ? mainPage.width : mainPage.width / 2
            height: window.inPortrait ? mainPage.height / 2 : mainPage.height
        }

        Events {
            id: events
            anchors.bottom: parent.bottom; anchors.right: parent.right
            width: window.inPortrait ? mainPage.width : mainPage.width / 2
            height: window.inPortrait ? mainPage.height / 2 : mainPage.height
        }
    }

    AlignedTimer {
        id: alignedTimer
        minimumInterval: 1
        maximumInterval: 60
        singleShot: false
        onTimeout: events.updateRequested()
    }

    Timer {
        id: timer
        interval: 16
        repeat: true
        onTriggered: events.updateRequested()
    }

    Connections {
        target: platformWindow
        onActiveChanged: window.checkTimerToRun()
        onVisibleChanged: window.checkTimerToRun()
    }

    Page {
        id: aboutPage
        tools: ToolBarLayout {
            ToolIcon {
                iconId: "toolbar-back"
                onClicked: window.pageStack.pop()
            }
        }

        Flickable {
            anchors.fill: parent
            contentWidth: width
            contentHeight: aboutColumn.height + 12 * 2

            Column {
                id: aboutColumn
                anchors.left: parent.left; anchors.right: parent.right
                anchors.leftMargin: 12; anchors.rightMargin: 12
                anchors.top: parent.top; anchors.topMargin: 12
                spacing: 12

                Label {
                    font.pixelSize: 42
                    text: qsTr("Jolla Countdown 2")
                    width: parent.width
                }

                Label {
                    text: qsTr("By Sfiet_Konstantin from JollaFr")
                    width: parent.width
                }

                Label {
                    text: qsTr("Jolla countdown 2 counts the time left before the 20th of May, \
where Jolla is supposed to announce their smartphone. The countdown currently ends at 8 pm, UTC, \
since we don't know when is the announcement time.")
                    width: parent.width
                }

                ButtonColumn {
                    exclusive: false
                    anchors.horizontalCenter: parent.horizontalCenter
                    Button {
                        iconSource: "image://theme/icon-l-twitter-main-view"
                        text: qsTr("@SfietKonstantin")
                        onClicked: Qt.openUrlExternally("https://twitter.com/SfietKonstantin/")
                    }

                    Button {
                        iconSource: "image://theme/icon-l-browser-main-view"
                        text: qsTr("Visit JollaFr")
                        onClicked: Qt.openUrlExternally("http://jollafr.org/")
                    }
                }

                Label {
                    text: qsTr("JollaFr loves Jolla <3")
                }
            }
        }


    }
}
