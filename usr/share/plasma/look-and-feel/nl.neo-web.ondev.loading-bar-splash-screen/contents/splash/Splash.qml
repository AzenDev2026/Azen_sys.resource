import QtQuick 2.5


Rectangle {
    id: root
    color: "black"

    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }

    Rectangle {
        id: topRect
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height

        radius: 3
        color: "#505050"

        height: 6
        width: height*36

        Rectangle {
            radius: 3
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
            }
            width: parent.width * Math.min(Math.max(stage - 1, 0) / 4, 1)
            color: "#ffffff"
            Behavior on width { 
                PropertyAnimation {
                    duration: 250
                    easing.type: Easing.InOutShine
                }
            }
        }
    }

    SequentialAnimation {
        id: introAnimation
        running: false

        ParallelAnimation {
            PropertyAnimation {
                property: "y"
                target: topRect
                to: root.height - (root.height/3)
                duration: 600
                easing.type: Easing.InOutQuad
            }
            OpacityAnimator {
                target: topRect
                from: 0
                to: 1
                duration: 600
            }
        }
    }
}
