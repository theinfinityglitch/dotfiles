import QtQuick
import QtQuick.Layouts

Rectangle {
    id: root

    property string icon: "?"
    property string label: ""
    property color accent: Colors.foreground
    property real percent: 0
    property string valueText: ""
    property var history: []
    property real maxHistoryValue: 100

    implicitWidth: 260
    implicitHeight: 220
    radius: 12
    color: Colors.background
    border.width: 1
    border.color: Colors.backgroundLight
    onHistoryChanged: chart.requestPaint()

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 18
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: root.icon
                color: root.accent

                font {
                    pixelSize: 19
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Text {
                Layout.fillWidth: true
                text: root.label
                color: Colors.foreground
                elide: Text.ElideRight

                font {
                    pixelSize: 15
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

            Text {
                text: Math.round(root.percent) + "%"
                color: root.accent

                font {
                    pixelSize: 17
                    bold: true
                    family: "CaskaydiaCove Nerd Font"
                }

            }

        }

        Text {
            Layout.fillWidth: true
            text: root.valueText
            visible: root.valueText !== ""
            color: Colors.foreground
            opacity: 0.6
            elide: Text.ElideRight

            font {
                pixelSize: 12
                family: "CaskaydiaCove Nerd Font"
            }

        }

        Canvas {
            id: chart

            function yFor(v) {
                const clamped = Math.max(0, Math.min(root.maxHistoryValue, v));
                return height - (clamped / root.maxHistoryValue) * height;
            }

            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: 6
            onPaint: {
                const ctx = getContext("2d");
                ctx.reset();
                const hist = root.history;
                if (hist.length < 2)
                    return ;

                const w = width;
                const h = height;
                const stepX = hist.length > 1 ? w / (hist.length - 1) : w;
                ctx.beginPath();
                ctx.moveTo(0, yFor(hist[0]));
                for (let i = 1; i < hist.length; i++) ctx.lineTo(i * stepX, yFor(hist[i]))
                ctx.lineTo(w, h);
                ctx.lineTo(0, h);
                ctx.closePath();
                ctx.fillStyle = Qt.rgba(root.accent.r, root.accent.g, root.accent.b, 0.18);
                ctx.fill();
                ctx.beginPath();
                ctx.moveTo(0, yFor(hist[0]));
                for (let i = 1; i < hist.length; i++) ctx.lineTo(i * stepX, yFor(hist[i]))
                ctx.strokeStyle = root.accent;
                ctx.lineWidth = 2;
                ctx.stroke();
            }
        }

    }

}
