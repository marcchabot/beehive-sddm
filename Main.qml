import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtMultimedia 5.15

// ═══════════════════════════════════════════════════════════════════════════
// Bee-Hive SDDM — Thème de connexion v0.1.6 (Compact Layout & Clock Fix)
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

    // ── Config depuis theme.conf ──────────────────────────────────────────
    property string bgSource:   (typeof config !== "undefined" && config.background)
                                ? config.background
                                : "assets/hexa_neon_honey.png"
    property string bgType:     (typeof config !== "undefined" && config.background_type)
                                ? config.background_type
                                : "image"
    property real   blurRadius: (typeof config !== "undefined" && config.blur_radius)
                                ? parseFloat(config.blur_radius)
                                : 0.45

    // ── État auth ─────────────────────────────────────────────────────────
    property string loginError: ""
    property bool   isLogging:  false

    Connections {
        target: sddm
        onLoginSucceeded: root.isLogging = false
        onLoginFailed: {
            root.isLogging = false
            root.loginError = "Identifiants incorrects — réessayez."
            errorShake.start()
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // COUCHE 1 — Fond d'écran
    // ══════════════════════════════════════════════════════════════════════
    Item {
        id: backgroundLayer
        anchors.fill: parent
        layer.enabled: true
        layer.effect: GaussianBlur {
            id: blurEffect
            radius: root.blurRadius * 64
            samples: 16
        }

        AnimatedImage {
            id: bgAnimated
            anchors.fill: parent
            source: (bgType === "image" || bgType === "gif") ? bgSource : ""
            fillMode: Image.PreserveAspectCrop
            visible: bgType !== "video"
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

        MediaPlayer {
            id: bgMediaPlayer
            source: bgType === "video" ? bgSource : ""
            autoPlay: bgType === "video"
            loops: MediaPlayer.Infinite
        }
        VideoOutput {
            anchors.fill: parent
            visible: bgType === "video"
            source: bgMediaPlayer
            fillMode: VideoOutput.PreserveAspectCrop
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
            interval: 125
            running: true
            repeat: true
            onTriggered: {
                hexCanvas.phase += 0.10
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

    // ══════════════════════════════════════════════════════════════════════
    // RESEARCH: "Breathing / Wind" effect on a static PNG background
    // ══════════════════════════════════════════════════════════════════════
    //
    // OPTION A — Scale-pulse (already in use, tweak for more life):
    //   SequentialAnimation on scale {
    //       NumberAnimation { to: 1.06; duration: 9000; easing.type: Easing.InOutSine }
    //       NumberAnimation { to: 1.00; duration: 9000; easing.type: Easing.InOutSine }
    //   }
    //   Combine with a very slow x/y Translate nudge (±8 px) on a different
    //   period (13 s) for an organic parallax feel.
    //
    // OPTION B — ShaderEffect ripple (QML built-in, no C++):
    //   Replace the AnimatedImage with a ShaderEffect that samples the image
    //   as a texture and applies a sine-wave UV distortion:
    //
    //   ShaderEffect {
    //       property variant src: bgTexture    // ShaderEffectSource wrapping the Image
    //       property real    t:   0.0
    //       NumberAnimation on t { from: 0; to: 6.2832; duration: 12000; loops: -1 }
    //       fragmentShader: "
    //           uniform sampler2D src;
    //           uniform float     t;
    //           varying vec2      qt_TexCoord0;
    //           void main() {
    //               vec2 uv = qt_TexCoord0;
    //               uv.x += sin(uv.y * 4.0 + t) * 0.004;  // horizontal ripple
    //               uv.y += cos(uv.x * 3.5 + t) * 0.003;  // vertical ripple
    //               gl_FragColor = texture2D(src, uv);
    //           }
    //       "
    //   }
    //   Amplitude 0.003–0.006 gives a subtle "heat shimmer / silk cloth" look.
    //   Increase the amplitude and frequency for a stronger wind effect.
    //
    // OPTION C — OpacityAnimator on a duplicate blurred layer (zero-cost):
    //   Stack two copies of the background (one slightly blurred, one sharp).
    //   Animate the blurred copy's opacity 0.0 ↔ 0.25 over 8 s.
    //   The slow cross-fade mimics atmospheric depth / bokeh breathing.
    //
    // OPTION D — sddm-silent style (video loop):
    //   Use background_type=video with a seamless MP4 encode of the PNG
    //   processed through ffmpeg with a subtle zoom/pan filter:
    //   ffmpeg -loop 1 -i bg.png -vf "zoompan=z='1+0.05*sin(2*PI*t/20)':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=1920x1080,fps=30" -t 20 bg_wind.mp4
    //
    // ══════════════════════════════════════════════════════════════════════

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
        layer.enabled: true
        layer.effect: DropShadow {
            id: panelShadow
            transparentBorder: true
            radius: 12
            samples: 16
            verticalOffset: 10
            color: Qt.rgba(0, 0, 0, 0.55)
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
                    text: "UTILISATEUR"
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
                    text: "MOT DE PASSE"
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
                    text: root.isLogging ? "Connexion en cours…" : "SE CONNECTER"
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

            // ── Sélecteur de session ──────────────────────────────
            // sessionModel.get(i) retourne un objet JS {name, file, exec, ...}
            // C'est la méthode native QAbstractListModel en QML — pas de delegate nécessaire
            Item {
                id: sessionPickerRow
                width: parent.width
                height: 28
                property int sessionIdx: 0

                function getSessionName(idx) {
                    if (typeof sessionModel === "undefined") return "Hyprland"
                    var row = sessionModel.get(idx)
                    if (row && row.name) return row.name
                    return "Hyprland"
                }

                Component.onCompleted: {
                    sessionIdx = (typeof sessionModel !== "undefined") ? sessionModel.lastIndex : 0
                    sessionDisplayText.text = getSessionName(sessionIdx)
                }

                Text {
                    id: sessionLabel
                    text: "Session :"
                    color: root.textPrimary
                    font { pixelSize: 11; family: "monospace" }
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                }

                Rectangle {
                    anchors {
                        left: sessionLabel.right
                        leftMargin: 8
                        right: parent.right
                        verticalCenter: parent.verticalCenter
                    }
                    height: 28
                    radius: 6
                    color: Qt.rgba(0, 0, 0, 0.4)
                    border.color: root.glassBorder
                    border.width: 1

                    Text {
                        id: sessionDisplayText
                        anchors {
                            left: parent.left
                            right: arrowIndicator.left
                            leftMargin: 10
                            rightMargin: 4
                            verticalCenter: parent.verticalCenter
                        }
                        text: "—"
                        color: root.textPrimary
                        font { pixelSize: 12; family: "monospace" }
                        elide: Text.ElideRight
                    }

                    Text {
                        id: arrowIndicator
                        anchors { right: parent.right; rightMargin: 8; verticalCenter: parent.verticalCenter }
                        text: "▾"
                        color: root.accent
                        font.pixelSize: 12
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (typeof sessionModel === "undefined") return
                            var count = sessionModel.rowCount()
                            if (count > 1) {
                                sessionPickerRow.sessionIdx = (sessionPickerRow.sessionIdx + 1) % count
                                sessionDisplayText.text = sessionPickerRow.getSessionName(sessionPickerRow.sessionIdx)
                            }
                        }
                    }
                }
            }

            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                topPadding: 4
                bottomPadding: 6
                Repeater {
                    model: [
                        { icon: "⏻",  label: "Éteindre",    action: "powerOff" },
                        { icon: "↺",  label: "Redémarrer",  action: "reboot"    },
                        { icon: "⏸", label: "Veille",      action: "suspend"  }
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
                                font.pixelSize: 18
                                font.bold: true
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
                var days = ["Dimanche","Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"]
                var months = ["Jan","Fév","Mar","Avr","Mai","Jun","Jul","Aoû","Sep","Oct","Nov","Déc"]
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
        text: "Bee-Hive SDDM v0.1.6 🍯"
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
