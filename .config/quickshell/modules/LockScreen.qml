import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam

Scope {
    id: root

    // Shared across every screen's surface, so multi-monitor setups have
    // one authentication session and one password buffer, not one per
    // screen - only whichever surface actually has keyboard focus will be
    // the one receiving keystrokes, but all of them reflect the same state.
    QtObject {
        id: authCtx

        property string password: ""
        property string errorText: ""
        property bool authenticating: false
        // Toggled whenever the real TextInput buffer needs to be forcibly
        // wiped (auth failure) - authCtx.password alone only clears the
        // *display*, not passwordInput's own internal text, so without this
        // the next keystrokes would append onto the old (failed) attempt.
        property int clearTrigger: 0
        property bool errorFlash: false

        // One random spin per character in the buffer, so it behaves like
        // an actual mechanical combination dial rather than a fixed angle
        // per keystroke. Backspacing pops the stack, precisely undoing
        // that character's spin rather than jumping somewhere new -
        // dialRotation is what the UI actually binds to; rotationStack is
        // just internal bookkeeping.
        property var rotationStack: []
        property real dialRotation: 0

        function setPassword(newText) {
            while (authCtx.rotationStack.length < newText.length) {
                const magnitude = 120 + Math.random() * 480;
                const direction = Math.random() < 0.5 ? -1 : 1;
                authCtx.rotationStack.push(magnitude * direction);
            }
            while (authCtx.rotationStack.length > newText.length)
                authCtx.rotationStack.pop();

            let total = 0;
            for (const v of authCtx.rotationStack)
                total += v;

            authCtx.dialRotation = total;
            authCtx.password = newText;
        }

        function attemptUnlock() {
            if (authCtx.authenticating || authCtx.password === "")
                return;

            authCtx.errorText = "";
            authCtx.authenticating = true;
            if (!pam.start()) {
                authCtx.errorText = "Could not start authentication";
                authCtx.authenticating = false;
            }
        }

        function forceClear() {
            authCtx.rotationStack = [];
            authCtx.dialRotation = 0;
            authCtx.password = "";
            authCtx.clearTrigger++;
        }

        function reset() {
            authCtx.errorText = "";
            authCtx.authenticating = false;
            authCtx.forceClear();
        }

    }

    PamContext {
        id: pam

        // Requires a dedicated /etc/pam.d/quickshell-lock file - see the
        // install instructions that come with this. Using a config
        // specifically for this purpose (rather than the generic "login"
        // default) is what Quickshell's own docs recommend.
        config: "quickshell-lock"

        onPamMessage: {
            if (pam.responseRequired)
                pam.respond(authCtx.password);

        }

        onCompleted: (result) => {
            authCtx.authenticating = false;
            if (result === PamResult.Success) {
                sessionLock.locked = false;
            } else {
                authCtx.forceClear();
                authCtx.errorText = result === PamResult.MaxTries ? "Too many attempts" : "Incorrect password";
                authCtx.errorFlash = !authCtx.errorFlash;
            }
        }

        onError: {
            authCtx.authenticating = false;
            authCtx.errorText = "Authentication error";
        }

    }

    IpcHandler {
        target: "lock"
        function lock(): void { sessionLock.locked = true; }
        function unlock(): void { sessionLock.locked = false; }
    }

    WlSessionLock {
        id: sessionLock

        onLockedChanged: {
            if (sessionLock.locked)
                authCtx.reset();

        }

        WlSessionLockSurface {
            id: surface

            property QtObject lockState: authCtx
            property int tick: root._tick

            color: Colors.background

            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: passwordInput.forceActiveFocus()
            }

            Component.onCompleted: {
                surface.lockState.reset();
                passwordInput.forceActiveFocus();
            }

            // Real keystroke capture, kept invisible - the dial below is
            // the actual display. Lives at the surface level (not nested
            // inside the dial) so its geometry stays simple.
            TextInput {
                id: passwordInput

                width: 1
                height: 1
                color: "transparent"
                selectionColor: "transparent"
                echoMode: TextInput.Password
                cursorVisible: false
                focus: true
                onTextChanged: {
                    surface.lockState.setPassword(passwordInput.text);
                    if (passwordInput.text !== "" && surface.lockState.errorText !== "")
                        surface.lockState.errorText = "";

                }
                Keys.onEscapePressed: passwordInput.text = ""
                Keys.onReturnPressed: surface.lockState.attemptUnlock()
                Keys.onEnterPressed: surface.lockState.attemptUnlock()

                Connections {
                    function onClearTriggerChanged() {
                        passwordInput.text = "";
                    }

                    target: surface.lockState
                }

            }

            Column {
                anchors.centerIn: parent
                spacing: 28

                Column {
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: 4

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            surface.tick;
                            return Qt.formatDateTime(new Date(), "hh:mm");
                        }
                        color: Colors.foreground

                        font {
                            pixelSize: 72
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: {
                            surface.tick;
                            return Qt.formatDateTime(new Date(), "dddd, MMMM d");
                        }
                        color: Colors.foreground
                        opacity: 0.7

                        font {
                            pixelSize: 16
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                }

                // Radial "combination lock" password indicator - the ring
                // rotates further with every character typed and smoothly
                // spins back as the buffer is cleared (Behavior on
                // rotation), rather than a separate one-shot animation.
                Item {
                    id: dial

                    readonly property int pipCount: 8
                    readonly property real dialRadius: 70

                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 160
                    height: 160

                    Item {
                        id: ring

                        anchors.centerIn: parent
                        width: 1
                        height: 1
                        rotation: authCtx.dialRotation

                        Behavior on rotation {
                            NumberAnimation {
                                duration: 220
                                easing.type: Easing.OutCubic
                            }

                        }

                        Repeater {
                            model: dial.pipCount

                            delegate: Rectangle {
                                id: pip

                                required property int index

                                readonly property bool isActive: authCtx.password.length > 0 && (index === (authCtx.password.length - 1) % dial.pipCount)
                                readonly property real angle: (2 * Math.PI * index / dial.pipCount) - Math.PI / 2

                                x: dial.dialRadius * Math.cos(angle) - width / 2
                                y: dial.dialRadius * Math.sin(angle) - height / 2
                                width: pip.isActive ? 16 : 12
                                height: width
                                radius: width / 2
                                color: authCtx.errorText !== "" ? Colors.red : (pip.isActive ? Colors.foreground : Colors.backgroundLight)

                                Behavior on width {
                                    NumberAnimation {
                                        duration: 150
                                        easing.type: Easing.OutBack
                                        easing.overshoot: 2
                                    }

                                }

                                Behavior on color {
                                    ColorAnimation {
                                        duration: 150
                                    }

                                }

                            }

                        }

                    }

                    Text {
                        anchors.centerIn: parent
                        text: authCtx.authenticating ? "" : "󰌾"
                        color: Colors.foreground
                        opacity: 0.6

                        font {
                            pixelSize: 22
                            family: "CaskaydiaCove Nerd Font"
                        }

                    }

                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: authCtx.errorText !== "" ? authCtx.errorText : (authCtx.authenticating ? "Checking…" : "")
                    color: authCtx.errorText !== "" ? Colors.red : Colors.foreground
                    opacity: text !== "" ? 1 : 0

                    font {
                        pixelSize: 13
                        family: "CaskaydiaCove Nerd Font"
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 150
                        }

                    }

                }

            }

        }

    }

    property int _tick: 0

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root._tick++
    }

}
