import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15

Window {
    width: 640
    height: 480
    visible: true
    title: qsTr("AzDevOpsDemo")

    property int counter: 0

    Column {
        spacing: 10
        anchors.centerIn: parent
        Text {
            id: textOpId
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Button {
            text: "Click me!!"
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: {
                counter++;
                textOpId.text = qsTr("%1   Hello from AzDevOpsDemo   %2").arg(counter).arg(counter)
            }
        }
    }
}
