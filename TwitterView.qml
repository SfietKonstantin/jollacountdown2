import QtQuick 1.1
import com.nokia.meego 1.0

Item {
    id: container
    property bool showTweet: false

    Component.onCompleted: {
        loadRandomImage()
        Twitter.load()
        timer.start()
    }

    function loadRandomImage() {
        // Pick a random number
        var number = -1
        while (number == logo.currentImage || number == -1) {
            number = Math.floor(Math.random() * 10)
        }
        logo.currentImage = number
        logo.source = "jolla-logo_0" + number + ".png"
    }

    Item {
        id: content
        anchors.fill: parent

        property string name: Twitter.currentTweet != null ? Twitter.currentTweet.name : ""
        property string nick: Twitter.currentTweet != null ? Twitter.currentTweet.nickname : ""

        Image {
            id: logo
            visible: !container.showTweet || !mainPage.fastUpdate
            property int currentImage: -1
            anchors.centerIn: parent
            asynchronous: true
        }

        Item {
            id: tweet
            visible: container.showTweet && mainPage.fastUpdate
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left; anchors.right: parent.right
            anchors.margins: 20
            height: column.height + 40

            Rectangle {
                anchors.fill: parent
                opacity: 0.3
            }

            Column {
                id: column
                anchors.left: parent.left; anchors.right: parent.right
                anchors.margins: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12

                Item {
                    anchors.left: parent.left; anchors.right: parent.right
                    height: Math.max(avatar.height, nameLabel.height)

                    Image {
                        id: avatar
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        asynchronous: true
                        source: Twitter.currentTweet != null ? Twitter.currentTweet.avatar : ""
                    }
                    Label {
                        id: nameLabel
                        anchors.left: avatar.right; anchors.leftMargin: 12
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: content.name + " (@" + content.nick + ")"
                        elide: Text.ElideRight
                        font.bold: true
                    }
                }

                Label {
                    anchors.left: parent.left; anchors.right: parent.right
                    text: Twitter.currentTweet != null ? Twitter.currentTweet.message : ""
                }
            }
        }

        states: [
            State {
                name: "hidden"
                PropertyChanges {
                    target: content
                    opacity: 0
                }
            }
        ]

        transitions: [
            Transition {
                from: ""
                to: "hidden"
                SequentialAnimation {
                    NumberAnimation { target: content; properties: "opacity"; duration: 200 }
                    ScriptAction {
                        script: {
                            // If there are no tweets
                            if (Twitter.error || !Twitter.hasNext()) {
                                container.loadRandomImage()
                                container.showTweet = false
                                if (!Twitter.hasNext()) {
                                    Twitter.load()
                                }
                            } else {
                                if (!container.showTweet) {
                                    container.showTweet = true
                                } else {
                                    Twitter.next()
                                }
                            }
                            content.state = ""
                        }
                    }
                }
            }, Transition {
                from: "hidden"
                to: ""
                SequentialAnimation {
                    NumberAnimation { target: content; properties: "opacity"; duration: 200 }
                    ScriptAction {
                        script: timer.start()
                    }
                }
            }
        ]
    }

    Timer {
        id: timer
        interval: 3000
        repeat: false
        onTriggered: content.state = "hidden"
    }
    Connections {
        target: Twitter
        onErrorChanged: {
            if (Twitter.error) {
                timer.stop()
            }
        }
    }

    Connections {
        target: mainPage
        onFastUpdateChanged: {
            if (Twitter.error) {
                timer.stop()
                return
            }

            if (mainPage.fastUpdate) {
                timer.start()
            } else {
                timer.stop()
            }
        }
    }
}
