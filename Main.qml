import QtQuick 2.15
import QtQuick.Controls 2.15
// import QtGraphicalEffects 1.15
import SddmComponents 2.0

// ═══════════════════════════════════════════════════════════════════════════
// Bee-Hive SDDM — Login Theme v0.2.1 (Safe Mode)
// ═══════════════════════════════════════════════════════════════════════════

Item {
    id: root

    // ── Palette HoneyDark ──────────────────────────────────────────────────
    readonly property color accent:      "#FFB81C"
    readonly property color bgColor:     "#0D0D0D"
    readonly property color secondary:   "#1A1A1A"
    readonly property color textPrimary: "#FFFFFF"
    readonly property color textMuted:   "#888888"
    readonly property color glassBg:     Qt.rgba(0.07, 0.07, 0.08, 0.72)
    readonly property color glassBorder: Qt.rgba(1, 0.72, 0.11, 0.28)

    // ── Config from theme.conf ──────────────────────────────────────────
    property string bgSource:   (typeof config !== "undefined" && config.background)
                                ? config.background
                                : "assets/hexa_neon_honey.png"
    property string bgType:     (typeof config !== "undefined" && config.background_type)
                                ? config.background_type
                                : "image"
    property real   blurRadius: (typeof config !== "undefined" && config.blur_radius)
                                ? parseFloat(config.blur_radius)
                                : 0.45

    // ── Auth state ─────────────────────────────────────────────────────────
    property string loginError: ""
    property bool   isLogging:  false

    Connections {
        target: sddm
        function onLoginSucceeded() { root.isLogging = false }
        function onLoginFailed() {
            root.isLogging = false
            root.loginError = "Incorrect credentials — try again."
            errorShake.start()
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // LAYER 1 — Background
    // ══════════════════════════════════════════════════════════════════════
    Item {
        id: backgroundLayer
        anchors.fill: parent

        AnimatedImage {
            id: bgAnimated
            anchors.fill: parent
            source: (bgType === "image" || bgType === "gif") ? bgSource : ""
            fillMode: Image.PreserveAspectCrop
            visible: true
            playing: bgType === "gif"
            cache: false
            smooth: true

            SequentialAnimation on scale {
                running: bgType === "image"
                loops: Animation.Infinite
                NumberAnimation { to: 1.05; duration: 16000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.00; duration: 16000; easing.type: Easing.InOutSine }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.05, 0.04, 0.0, 0.50) }
            GradientStop { position: 0.45; color: Qt.rgba(0.05, 0.04, 0.0, 0.28) }
            GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.04, 0.0, 0.70) }
        }
    }

    Canvas {
        id: hexCanvas
        anchors.fill: parent
        opacity: 0.07
        renderStrategy: Canvas.Cooperative
        property real phase: 0.0
        Timer {
            interval: 180
            running: true
            repeat: true
            onTriggered: {
                hexCanvas.phase += 0.14
                if (hexCanvas.phase > 6.2832) hexCanvas.phase -= 6.2832
                hexCanvas.requestPaint()
            }
        }
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var hexR = 38
            var hexW = hexR * 2
            var hexH = Math.sqrt(3) * hexR
            var cols = Math.ceil(width  / (hexW * 0.75)) + 2
            var rows = Math.ceil(height / hexH) + 2
            ctx.strokeStyle = "#FFB81C"
            ctx.lineWidth   = 0.7
            for (var col = -1; col < cols; col++) {
                for (var row = -1; row < rows; row++) {
                    var cx = col * hexW * 0.75
                    var cy = row * hexH + (col % 2 === 0 ? 0 : hexH * 0.5)
                    var pulse = 0.25 + 0.75 * Math.abs(Math.sin(phase + col * 0.28 + row * 0.47))
                    ctx.globalAlpha = pulse
                    ctx.beginPath()
                    for (var i = 0; i < 6; i++) {
                        var ang = (Math.PI / 3) * i - Math.PI / 6
                        var px  = cx + hexR * 0.88 * Math.cos(ang)
                        var py  = cy + hexR * 0.88 * Math.sin(ang)
                        if (i === 0) ctx.moveTo(px, py)
                        else         ctx.lineTo(px, py)
                    }
                    ctx.closePath()
                    ctx.stroke()
                }
            }
        }
    }

    Canvas {
        id: auraGlow
        width: 600
        height: 600
        x: -180
        y: parent.height - 420
        renderStrategy: Canvas.Cooperative
        property real gAlpha: 0.10
        SequentialAnimation on gAlpha {
            loops: Animation.Infinite
            NumberAnimation { to: 0.18; duration: 3800; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0.05; duration: 3800; easing.type: Easing.InOutSine }
        }
        onGAlphaChanged: requestPaint()
        onPaint: {
            var ctx  = getContext("2d")
            ctx.clearRect(0, 0, width, height)
            var grad = ctx.createRadialGradient(width * 0.5, height * 0.5, 0,
                                                width * 0.5, height * 0.5, width * 0.5)
            grad.addColorStop(0.0, Qt.rgba(1, 0.72, 0.11, gAlpha))
            grad.addColorStop(1.0, Qt.rgba(1, 0.72, 0.11, 0))
            ctx.fillStyle = grad
            ctx.fillRect(0, 0, width, height)
        }
    }

    Rectangle {
        id: loginPanel
        width: 310
        height: loginContent.implicitHeight + 46
        anchors {
            left: parent.left
            leftMargin: 60
            verticalCenter: parent.verticalCenter
        }
        radius: 22
        color: root.glassBg
        border.width: 1
        SequentialAnimation on border.color {
            loops: Animation.Infinite
            ColorAnimation { to: Qt.rgba(1, 0.72, 0.11, 0.48); duration: 2800; easing.type: Easing.InOutSine }
            ColorAnimation { to: Qt.rgba(1, 0.72, 0.11, 0.18); duration: 2800; easing.type: Easing.InOutSine }
        }
        
        transform: Translate { id: shakeTranslate; x: 0 }
        SequentialAnimation {
            id: errorShake
            NumberAnimation { target: shakeTranslate; property: "x"; to: -14; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:  14; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:  -9; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:   9; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:   0; duration: 55 }
        }
        opacity: 0
        scale: 0.93
        Component.onCompleted: appearAnim.start()
        ParallelAnimation {
            id: appearAnim
            NumberAnimation { target: loginPanel; property: "opacity"; to: 1; duration: 750; easing.type: Easing.OutCubic }
            NumberAnimation { target: loginPanel; property: "scale";   to: 1; duration: 750; easing.type: Easing.OutCubic }
        }

        Column {
            id: loginContent
            anchors {
                top: parent.top
                topMargin: 24
                left: parent.left
                leftMargin: 24
                right: parent.right
                rightMargin: 24
            }
            spacing: 14

            Column {
                width: parent.width
                spacing: 8
                Text {
                    id: beeLogo
                    text: "🐝"
                    font.pixelSize: 34
                    anchors.horizontalCenter: parent.horizontalCenter
                    SequentialAnimation on scale {
                        loops: Animation.Infinite
                        NumberAnimation { to: 1.10; duration: 950; easing.type: Easing.InOutSine }
                        NumberAnimation { to: 1.00; duration: 950; easing.type: Easing.InOutSine }
                    }
                }
                Text {
                    text: "Bee-Hive OS"
                    color: root.accent
                    font {
                        bold: true
                        pixelSize: 22
                        family: "monospace"
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: (typeof sddm !== "undefined") ? sddm.hostName : "Bee-Hive"
                    color: root.textMuted
                    font {
                        pixelSize: 11
                        family: "monospace"
                    }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            Rectangle {
                width: parent.width
                height: 1
                color: Qt.rgba(1, 0.72, 0.11, 0.22)
            }

            Column {
                width: parent.width
                spacing: 6
                Text {
                    text: "USERNAME"
                    color: root.accent
                    font {
                        pixelSize: 10
                        letterSpacing: 2
                        family: "monospace"
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 8
                    color: Qt.rgba(0, 0, 0, 0.38)
                    border.color: userField.activeFocus ? root.accent : root.glassBorder
                    border.width: 1
                    TextInput {
                        id: userField
                        // topMargin intentionally omitted — verticalAlignment handles centering.
                        // Adding topMargin without a matching bottomMargin shifts the baseline low.
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                        }
                        color: root.textPrimary
                        font {
                            pixelSize: 14
                            family: "monospace"
                        }
                        text: (typeof userModel !== "undefined" && userModel.lastUser) ? userModel.lastUser : ""
                        verticalAlignment: TextInput.AlignVCenter
                        Keys.onTabPressed: passwordField.forceActiveFocus()
                        Keys.onReturnPressed: root.doLogin()
                    }
                }
            }

            Column {
                width: parent.width
                spacing: 6
                Text {
                    text: "PASSWORD"
                    color: root.accent
                    font {
                        pixelSize: 10
                        letterSpacing: 2
                        family: "monospace"
                    }
                }
                Rectangle {
                    width: parent.width
                    height: 38
                    radius: 8
                    color: Qt.rgba(0, 0, 0, 0.38)
                    border.color: passwordField.activeFocus ? root.accent : root.glassBorder
                    border.width: 1
                    TextInput {
                        id: passwordField
                        anchors {
                            fill: parent
                            leftMargin: 12
                            rightMargin: 12
                        }
                        color: root.textPrimary
                        font {
                            pixelSize: 14
                            family: "monospace"
                        }
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        verticalAlignment: TextInput.AlignVCenter
                        Keys.onReturnPressed: root.doLogin()
                        Component.onCompleted: forceActiveFocus()
                    }
                }
            }

            Text {
                width: parent.width
                text: root.loginError
                color: "#FF5555"
                font {
                    pixelSize: 12
                    family: "monospace"
                }
                visible: root.loginError !== ""
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Rectangle {
                id: loginButton
                width: parent.width
                height: 40
                radius: 9
                color: loginMouse.pressed ? Qt.darker(root.accent, 1.35) : (loginMouse.containsMouse ? Qt.lighter(root.accent, 1.1) : root.accent)
                Text {
                    anchors.centerIn: parent
                    text: root.isLogging ? "Signing in…" : "SIGN IN"
                    color: "#0D0D0D"
                    font {
                        bold: true
                        pixelSize: 13
                        letterSpacing: 1.6
                        family: "monospace"
                    }
                }
                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doLogin()
                }
            }

            // ── Session selector (native SddmComponents ComboBox) ────
            Row {
                id: sessionPickerRow
                width: parent.width
                spacing: 8
                property int sessionIdx: sessionComboNative.index

                Text {
                    text: "Session:"
                    color: root.textPrimary
                    font { pixelSize: 11; family: "monospace" }
                    anchors.verticalCenter: parent.verticalCenter
                }

                ComboBox {
                    id: sessionComboNative
                    width: parent.width - 80
                    height: 28
                    model: sessionModel
                    index: sessionModel.lastIndex
                    color:       Qt.rgba(0, 0, 0, 0.4)
                    textColor:   root.textPrimary
                    borderColor: root.glassBorder
                    hoverColor:  Qt.rgba(1, 0.72, 0.11, 0.20)
                    focusColor:  Qt.rgba(1, 0.72, 0.11, 0.35)
                    menuColor:   Qt.rgba(0.07, 0.07, 0.08, 0.97)
                    arrowColor:  root.accent
                }
            }


            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                topPadding: 4
                bottomPadding: 6
                Repeater {
                    model: [
                        { icon: "⏻",  label: "Power Off",    action: "powerOff" },
                        { icon: "↺",  label: "Restart",     action: "reboot"    },
                        { icon: "☾",  label: "Suspend",     action: "suspend"  }
                    ]
                    delegate: Column {
                        spacing: 5
                        Rectangle {
                            width: 40
                            height: 40
                            radius: 9
                            color: sysMouse.pressed ? Qt.rgba(1, 0.72, 0.11, 0.28) : (sysMouse.containsMouse ? Qt.rgba(1, 0.72, 0.11, 0.14) : Qt.rgba(0,0,0,0.32))
                            border.color: sysMouse.containsMouse ? root.glassBorder : "transparent"
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                color: root.accent
                                font { pixelSize: 18; bold: true }
                                style: Text.Normal
                            }
                            MouseArea {
                                id: sysMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if (typeof sddm !== "undefined") {
                                        if      (modelData.action === "powerOff") sddm.powerOff()
                                        else if (modelData.action === "reboot")   sddm.reboot()
                                        else if (modelData.action === "suspend")  sddm.suspend()
                                    }
                                }
                            }
                        }
                        Text {
                            text: modelData.label
                            color: root.textPrimary
                            font {
                                pixelSize: 9
                                family: "monospace"
                            }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }

    // ── Clock — bottom-right to avoid overlap with left-aligned login panel ──
    Column {
        anchors {
            bottom: parent.bottom
            bottomMargin: 44
            right: parent.right
            rightMargin: 60
        }
        spacing: 4
        Text {
            id: clockText
            color: root.textPrimary
            font {
                pixelSize: 54
                bold: true
                family: "monospace"
            }
            opacity: 0.92
            anchors.right: parent.right
        }
        Text {
            id: dateText
            color: root.accent
            font {
                pixelSize: 14
                family: "monospace"
                letterSpacing: 2
            }
            opacity: 0.85
            anchors.right: parent.right
        }
        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                var now = new Date()
                clockText.text = now.getHours().toString().padStart(2, "0") + ":" + now.getMinutes().toString().padStart(2, "0")
                var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]
                var months = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"]
                dateText.text = days[now.getDay()] + " " + now.getDate() + " " + months[now.getMonth()] + " " + now.getFullYear()
            }
        }
    }

    Text {
        anchors {
            bottom: parent.bottom
            bottomMargin: 22
            right: parent.right
            rightMargin: 30
        }
        text: "Bee-Hive SDDM v0.2.1 🍯"
        color: root.textMuted
        font {
            pixelSize: 11
            family: "monospace"
        }
        opacity: 0.45
    }

    function doLogin() {
        if (root.isLogging) return
        root.loginError = ""
        root.isLogging  = true
        if (typeof sddm !== "undefined") {
            sddm.login(userField.text, passwordField.text, sessionPickerRow.sessionIdx)
        }
    }
}
