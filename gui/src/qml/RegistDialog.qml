import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Material

import org.streetpea.chiaking

import "controls" as C

DialogView {
    property bool ps5: true
    property alias host: hostField.text
    title: qsTr("Привязать устройство")
    buttonText: qsTr("✓ Привязать")
    buttonEnabled: hostField.text.trim() && pin.acceptableInput && (!accountId.visible || accountId.text.trim())
    StackView.onActivated: {
        if (host == "255.255.255.255")
            broadcast.checked = true;
        if(Chiaki.settings.psnAccountId)
            accountId.text = Chiaki.settings.psnAccountId
    }
    onAccepted: {
        let psnId = onlineId.visible ? onlineId.text.trim() : accountId.text.trim();
        let registerOk = Chiaki.registerHost(hostField.text.trim(), psnId, pin.text.trim(), cpin.text.trim(), broadcast.checked, consoleButtons.checkedButton.target, function(msg, ok, done) {
            if (!done)
                logArea.text += msg + "\n";
            else
                logDialog.standardButtons = Dialog.Close;
            if (ok && done)
                stack.pop();
        });
        if (registerOk) {
            logArea.text = "";
            logDialog.open();
        }
    }

    Item {
        GridLayout {
            anchors {
                top: parent.top
                horizontalCenter: parent.horizontalCenter
                topMargin: 20
            }
            columns: 2
            rowSpacing: 10
            columnSpacing: 20

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("IP адрес:")
            }

            C.TextField {
                id: hostField
                Layout.preferredWidth: 400
                firstInFocusChain: true
            }

           

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Логин PSN:")
                visible: accountId.visible
            }

            C.TextField {
                id: accountId
                visible: !ps4_7.checked
                placeholderText: qsTr("можно посмотреть в боте")
                Layout.preferredWidth: 400
 C.Button {
                    id: lookupButton
                    anchors {
                        left: parent.right
                        verticalCenter: parent.verticalCenter
                        leftMargin: 10
                    }
                    topPadding: 18
                    bottomPadding: 18
                    text: qsTr("Личный аккаунт")
                    onClicked: stack.push(psnLoginDialogComponent, {login: false, callback: (id) => accountId.text = id})
                    visible: !Chiaki.settings.psnAccountId
                    Material.roundedScale: Material.SmallScale
                }


               
            }

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Пин код:")
            }

            C.TextField {
                id: pin
                validator: RegularExpressionValidator { regularExpression: /[0-9]{8}/ }
                Layout.preferredWidth: 400
            }

            

          

            Label {
                Layout.alignment: Qt.AlignRight
                text: qsTr("Тариф:")
            }

            ColumnLayout {
                spacing: 0

                C.RadioButton {
                    id: ps4_8
                    property int target: 1000
                    text: qsTr("PS4 Slim или Pro")
                    checked: !ps5
                }

                C.RadioButton {
                    id: ps5_0
                    property int target: 1000100
                    lastInFocusChain: true
                    text: qsTr("PS5")
                    checked: ps5
                }
            }
        }

        ButtonGroup {
            id: consoleButtons
            buttons: [ps4_8, ps5_0]
        }

        Dialog {
            id: logDialog
            parent: Overlay.overlay
            x: Math.round((root.width - width) / 2)
            y: Math.round((root.height - height) / 2)
            title: qsTr("Авторизация устройства")
            modal: true
            closePolicy: Popup.NoAutoClose
            standardButtons: Dialog.Cancel
            Material.roundedScale: Material.MediumScale
            onOpened: logArea.forceActiveFocus()
            onClosed: hostField.forceActiveFocus(Qt.TabFocus)

            Flickable {
                id: logFlick
                implicitWidth: 600
                implicitHeight: 400
                clip: true
                contentWidth: logArea.contentWidth
                contentHeight: logArea.contentHeight
                flickableDirection: Flickable.AutoFlickIfNeeded
                ScrollIndicator.vertical: ScrollIndicator { }

                Label {
                    id: logArea
                    width: logFlick.width
                    wrapMode: TextEdit.Wrap
                    Keys.onReturnPressed: if (logDialog.standardButtons == Dialog.Close) logDialog.close()
                    Keys.onEscapePressed: logDialog.close()
                }
            }
        }

        Component {
            id: psnLoginDialogComponent
            PSNLoginDialog { }
        }
    }
}
