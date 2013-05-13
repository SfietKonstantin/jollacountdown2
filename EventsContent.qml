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
import Qt.labs.shaders 1.0
import com.nokia.meego 1.0


Item {
    id: container
    property int remainingDays: 0
    property variant remainingTime

    signal updateRequested()

    onUpdateRequested: {
        var remainingMsecs = TimeComputer.remainingMsec(2013, 5, 20, 20, 0, 0)
        container.remainingDays = TimeComputer.remainingDays(remainingMsecs)
        container.remainingTime = TimeComputer.remainingTime(remainingMsecs)
    }

    height: label.paintedHeight + 50
    anchors.left: parent.left; anchors.right: parent.right
    anchors.leftMargin: 20; anchors.rightMargin: 20
    anchors.verticalCenter: parent.verticalCenter

    Label {
        id: label
        anchors.fill: parent
        text: mainPage.fastUpdate ? qsTr("%n days", "", container.remainingDays) + "\n"
                                    + Qt.formatTime(container.remainingTime, "HH:mm:ss:zzz")
                                  : qsTr("%n days", "", container.remainingDays)
        font.family: "Courier"
        color: "white"
        font.pixelSize: 50
        font.bold: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }
    ShaderEffectItem {
        property variant source: ShaderEffectSource { sourceItem: label; hideSource: true }
        anchors.fill: label
        fragmentShader: "
        varying highp vec2 qt_TexCoord0;
        uniform sampler2D source;
        void main(void)
        {
            lowp vec4 textureColor = texture2D(source, qt_TexCoord0.st);
            lowp float hasData = step(0.5, (textureColor.x + textureColor.y + textureColor.z) / 3.);
            lowp float color = 0.3 * (1. - hasData);
            gl_FragColor = vec4(color, color, color, 0.);
        }
        "
     }
}
