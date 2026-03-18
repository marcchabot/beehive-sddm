import QtQuick 2.11
import QtQuick.Controls 2.4
import QtGraphicalEffects 1.0
import QtMultimedia 5.0
import SddmComponents 2.0

// ═══════════════════════════════════════════════════════════════════════════
// Bee-Hive SDDM — Thème de connexion v0.1
// Forké de SilentSDDM — Adapté pour Bee-Hive OS (CachyOS)
// Palette HoneyDark : accent #FFB81C | bg #0D0D0D
// Fonctionnalités : Image/GIF/Vidéo, grille hex animée, glassmorphisme
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

    // ── Config depuis theme.conf (avec fallbacks) ─────────────────────────
    // background_type : "image" | "gif" | "video"
    // background      : chemin relatif vers le fichier fond
    // blur_radius      : 0.0 à 1.0
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
        function onLoginSucceeded() {
            root.isLogging = false
        }
        function onLoginFailed() {
            root.isLogging = false
            root.loginError = "Identifiants incorrects — réessayez."
            errorShake.start()
            passwordField.text = ""
            passwordField.forceActiveFocus()
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // COUCHE 1 — Fond d'écran avec couche de rendu isolée
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

        // ── Image statique ou GIF (AnimatedImage supporte les deux) ───────
        AnimatedImage {
            id: bgAnimated
            anchors.fill: parent
            source: (bgType === "image" || bgType === "gif") ? bgSource : ""
            fillMode: Image.PreserveAspectCrop
            visible: bgType !== "video"
            playing: bgType === "gif"
            cache: false
            smooth: true

            // Respiration lente pour images statiques (donne vie sans animation)
            SequentialAnimation on scale {
                running: bgType === "image"
                loops: Animation.Infinite
                NumberAnimation { to: 1.05; duration: 16000; easing.type: Easing.InOutSine }
                NumberAnimation { to: 1.00; duration: 16000; easing.type: Easing.InOutSine }
            }
        }

        // ── Vidéo ──────────────────────────────────────────────────────────
        MediaPlayer {
            id: bgMediaPlayer
            source: bgType === "video" ? bgSource : ""
            loops: MediaPlayer.Infinite
            autoPlay: bgType === "video"
        }
        VideoOutput {
            anchors.fill: parent
            visible: bgType === "video"
            videoSink: bgMediaPlayer.videoSink
            fillMode: VideoOutput.PreserveAspectCrop
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // COUCHE 2 — Gradient sombre (vignette + profondeur)
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(0.05, 0.04, 0.0, 0.50) }
            GradientStop { position: 0.45; color: Qt.rgba(0.05, 0.04, 0.0, 0.28) }
            GradientStop { position: 1.0; color: Qt.rgba(0.05, 0.04, 0.0, 0.70) }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // COUCHE 3 — Grille hexagonale animée (overlay décoratif BeeAura)
    // Tourne à ~8fps pour rester légère sur le GPU de login
    // ══════════════════════════════════════════════════════════════════════
    Canvas {
        id: hexCanvas
        anchors.fill: parent
        opacity: 0.07
        renderStrategy: Canvas.Cooperative

        property real phase: 0.0

        Timer {
            interval: 125   // 8fps — équilibre fluidité / légèreté SDDM
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

    // ══════════════════════════════════════════════════════════════════════
    // COUCHE 4 — AuraGlow (lueur ambrée radiale, coin bas-gauche)
    // ══════════════════════════════════════════════════════════════════════
    Canvas {
        id: auraGlow
        width: 600; height: 600
        x: -180; y: parent.height - 420
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
    // COUCHE 5 — Panneau de connexion (glassmorphique)
    // ══════════════════════════════════════════════════════════════════════
    Rectangle {
        id: loginPanel
        width: 420
        height: loginContent.implicitHeight + 60
        anchors.centerIn: parent
        radius: 22
        color: root.glassBg
        border.width: 1

        // Halo de bordure animé
        SequentialAnimation on border.color {
            loops: Animation.Infinite
            ColorAnimation { to: Qt.rgba(1, 0.72, 0.11, 0.48); duration: 2800; easing.type: Easing.InOutSine }
            ColorAnimation { to: Qt.rgba(1, 0.72, 0.11, 0.18); duration: 2800; easing.type: Easing.InOutSine }
        }

        // Ombre portée
        layer.enabled: true
        layer.effect: DropShadow {
            id: panelShadow
            transparentBorder: true
            radius: 12
            samples: 16
            verticalOffset: 10
            color: Qt.rgba(0, 0, 0, 0.55)
        }

        // Shake sur erreur d'auth
        transform: Translate { id: shakeTranslate; x: 0 }
        SequentialAnimation {
            id: errorShake
            NumberAnimation { target: shakeTranslate; property: "x"; to: -14; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:  14; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:  -9; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:   9; duration: 55 }
            NumberAnimation { target: shakeTranslate; property: "x"; to:   0; duration: 55 }
        }

        // Apparition au démarrage
        opacity: 0
        scale: 0.93
        Component.onCompleted: appearAnim.start()
        ParallelAnimation {
            id: appearAnim
            NumberAnimation { target: loginPanel; property: "opacity"; to: 1; duration: 750; easing.type: Easing.OutCubic }
            NumberAnimation { target: loginPanel; property: "scale";   to: 1; duration: 750; easing.type: Easing.OutCubic }
        }

        // ── Contenu ───────────────────────────────────────────────────────
        Column {
            id: loginContent
            anchors {
                top: parent.top;   topMargin: 36
                left: parent.left; leftMargin: 36
                right: parent.right; rightMargin: 36
            }
            spacing: 18

            // ── Logo + Titre ───────────────────────────────────────────────
            Column {
                width: parent.width
                spacing: 8

                Text {
                    id: beeLogo
                    text: "🐝"
                    font.pixelSize: 44
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
                    font { bold: true; pixelSize: 27; family: "monospace" }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
                Text {
                    text: sddm.hostName
                    color: root.textMuted
                    font { pixelSize: 12; family: "monospace" }
                    anchors.horizontalCenter: parent.horizontalCenter
                }
            }

            // ── Séparateur ─────────────────────────────────────────────────
            Rectangle {
                width: parent.width; height: 1
                color: Qt.rgba(1, 0.72, 0.11, 0.22)
            }

            // ── Champ Utilisateur ──────────────────────────────────────────
            Column {
                width: parent.width
                spacing: 6
                Text {
                    text: "UTILISATEUR"
                    color: root.accent
                    font { pixelSize: 10; letterSpacing: 2; family: "monospace" }
                }
                Rectangle {
                    width: parent.width; height: 42
                    radius: 9
                    color: Qt.rgba(0, 0, 0, 0.38)
                    border.color: userField.activeFocus ? root.accent : root.glassBorder
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    TextInput {
                        id: userField
                        anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 12 }
                        color: root.textPrimary
                        font { pixelSize: 14; family: "monospace" }
                        text: userModel.lastUser || ""
                        verticalAlignment: TextInput.AlignVCenter
                        Keys.onTabPressed: passwordField.forceActiveFocus()
                        Keys.onReturnPressed: root.doLogin()
                    }
                }
            }

            // ── Champ Mot de passe ─────────────────────────────────────────
            Column {
                width: parent.width
                spacing: 6
                Text {
                    text: "MOT DE PASSE"
                    color: root.accent
                    font { pixelSize: 10; letterSpacing: 2; family: "monospace" }
                }
                Rectangle {
                    width: parent.width; height: 42
                    radius: 9
                    color: Qt.rgba(0, 0, 0, 0.38)
                    border.color: passwordField.activeFocus ? root.accent : root.glassBorder
                    border.width: 1
                    Behavior on border.color { ColorAnimation { duration: 200 } }

                    TextInput {
                        id: passwordField
                        anchors { fill: parent; leftMargin: 14; rightMargin: 14; topMargin: 12 }
                        color: root.textPrimary
                        font { pixelSize: 14; family: "monospace" }
                        echoMode: TextInput.Password
                        passwordCharacter: "●"
                        verticalAlignment: TextInput.AlignVCenter
                        Keys.onReturnPressed: root.doLogin()
                        Component.onCompleted: forceActiveFocus()
                    }
                }
            }

            // ── Message d'erreur ───────────────────────────────────────────
            Text {
                width: parent.width
                text: root.loginError
                color: "#FF5555"
                font { pixelSize: 12; family: "monospace" }
                visible: root.loginError !== ""
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            // ── Bouton Connexion ───────────────────────────────────────────
            Rectangle {
                id: loginButton
                width: parent.width; height: 46
                radius: 11
                color: loginMouse.pressed        ? Qt.darker(root.accent, 1.35)
                     : loginMouse.containsMouse  ? Qt.lighter(root.accent, 1.10)
                     : root.accent
                Behavior on color { ColorAnimation { duration: 140 } }

                Text {
                    anchors.centerIn: parent
                    text: root.isLogging ? "Connexion en cours…" : "SE CONNECTER"
                    color: "#0D0D0D"
                    font { bold: true; pixelSize: 13; letterSpacing: 1.6; family: "monospace" }
                }
                MouseArea {
                    id: loginMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.doLogin()
                }
            }

            // ── Sélecteur de session ───────────────────────────────────────
            Row {
                width: parent.width
                spacing: 10

                Text {
                    text: "Session :"
                    color: root.textMuted
                    font { pixelSize: 11; family: "monospace" }
                    anchors.verticalCenter: parent.verticalCenter
                }
                ComboBox {
                    id: sessionCombo
                    width: parent.width - 80
                    model: sessionModel
                    textRole: "name"
                    currentIndex: sessionModel.lastIndex

                    background: Rectangle {
                        radius: 7
                        color: Qt.rgba(0, 0, 0, 0.38)
                        border.color: root.glassBorder
                        border.width: 1
                    }
                    contentItem: Text {
                        leftPadding: 10
                        text: sessionCombo.displayText
                        color: root.textMuted
                        font { pixelSize: 11; family: "monospace" }
                        verticalAlignment: Text.AlignVCenter
                    }
                    popup: Popup {
                        y: sessionCombo.height + 2
                        width: sessionCombo.width
                        padding: 1
                        background: Rectangle {
                            radius: 7
                            color: Qt.rgba(0.07, 0.07, 0.08, 0.96)
                            border.color: root.glassBorder
                            border.width: 1
                        }
                        contentItem: ListView {
                            implicitHeight: contentHeight
                            model: sessionCombo.popup.visible ? sessionCombo.delegateModel : null
                            clip: true
                        }
                    }
                    delegate: ItemDelegate {
                        width: sessionCombo.width
                        background: Rectangle {
                            color: highlighted ? Qt.rgba(1, 0.72, 0.11, 0.16) : "transparent"
                        }
                        contentItem: Text {
                            leftPadding: 10
                            text: name
                            color: highlighted ? root.accent : root.textMuted
                            font { pixelSize: 11; family: "monospace" }
                            verticalAlignment: Text.AlignVCenter
                        }
                        highlighted: sessionCombo.highlightedIndex === index
                    }
                }
            }

            // ── Boutons système ────────────────────────────────────────────
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 20
                topPadding: 4
                bottomPadding: 6

                Repeater {
                    model: [
                        { icon: "⏻",  label: "Éteindre",    action: "powerOff" },
                        { icon: "↺",  label: "Redémarrer",  action: "reboot"   },
                        { icon: "⏸", label: "Veille",      action: "suspend"  }
                    ]
                    delegate: Column {
                        spacing: 5
                        Rectangle {
                            width: 46; height: 46
                            radius: 11
                            color: sysMouse.pressed       ? Qt.rgba(1, 0.72, 0.11, 0.28)
                                 : sysMouse.containsMouse ? Qt.rgba(1, 0.72, 0.11, 0.14)
                                 : Qt.rgba(0, 0, 0, 0.32)
                            border.color: sysMouse.containsMouse ? root.glassBorder : "transparent"
                            border.width: 1
                            anchors.horizontalCenter: parent.horizontalCenter
                            Behavior on color { ColorAnimation { duration: 140 } }

                            Text {
                                anchors.centerIn: parent
                                text: modelData.icon
                                font.pixelSize: 18
                            }
                            MouseArea {
                                id: sysMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    if      (modelData.action === "powerOff") sddm.powerOff()
                                    else if (modelData.action === "reboot")   sddm.reboot()
                                    else if (modelData.action === "suspend")  sddm.suspend()
                                }
                            }
                        }
                        Text {
                            text: modelData.label
                            color: root.textMuted
                            font { pixelSize: 9; family: "monospace" }
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // COUCHE 6 — Horloge (bas-gauche)
    // ══════════════════════════════════════════════════════════════════════
    Column {
        anchors {
            bottom: parent.bottom; bottomMargin: 44
            left: parent.left;     leftMargin:   52
        }
        spacing: 4

        Text {
            id: clockText
            color: root.textPrimary
            font { pixelSize: 54; bold: true; family: "monospace" }
            opacity: 0.92
        }
        Text {
            id: dateText
            color: root.accent
            font { pixelSize: 14; family: "monospace"; letterSpacing: 2 }
            opacity: 0.85
        }

        Timer {
            interval: 1000
            running: true
            repeat: true
            triggeredOnStart: true
            onTriggered: {
                var now = new Date()
                var h   = now.getHours().toString().padStart(2, "0")
                var m   = now.getMinutes().toString().padStart(2, "0")
                clockText.text = h + ":" + m

                var days   = ["Dimanche","Lundi","Mardi","Mercredi","Jeudi","Vendredi","Samedi"]
                var months = ["Jan","Fév","Mar","Avr","Mai","Jun","Jul","Aoû","Sep","Oct","Nov","Déc"]
                dateText.text = days[now.getDay()] + " " + now.getDate()
                              + " " + months[now.getMonth()] + " " + now.getFullYear()
            }
        }
    }

    // ══════════════════════════════════════════════════════════════════════
    // COUCHE 7 — Indicateur version (bas-droit)
    // ══════════════════════════════════════════════════════════════════════
    Text {
        anchors {
            bottom: parent.bottom; bottomMargin: 22
            right:  parent.right;  rightMargin:  30
        }
        text: "Bee-Hive SDDM v0.1 🍯"
        color: root.textMuted
        font { pixelSize: 11; family: "monospace" }
        opacity: 0.45
    }

    // ══════════════════════════════════════════════════════════════════════
    // FONCTION — Lancement de la connexion SDDM
    // ══════════════════════════════════════════════════════════════════════
    function doLogin() {
        if (root.isLogging) return
        root.loginError = ""
        root.isLogging  = true
        sddm.login(userField.text, passwordField.text, sessionCombo.currentIndex)
    }
}
