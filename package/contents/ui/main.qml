import QtCore
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.plasma5support as P5Support
import org.kde.plasma.workspace.components as WorkspaceComponents
import org.kde.taskmanager 0.1 as TaskManager
import QtQuick.Effects

import "components" as Components
import "code/utils.js" as Utils

PlasmoidItem {
    id: main
    preferredRepresentation: fullRepresentation
    property int panelLayoutCount: panelLayout?.children?.length || 0
    property int trayGridViewCount: trayGridView?.count || 0
    property int trayGridViewCountOld: 0
    property var panelPrefixes: ["north","south","west","east"]
    property bool horizontal: Plasmoid.formFactor === PlasmaCore.Types.Horizontal
    property bool fixedSideMarginEnabled: true
    property int fixedSideMarginSize: 4
    property bool isEnabled: true
    property bool panelOriginalBgHidden: true
    property real panelOriginalOpacity: 1
    property var panelWidgets: []
    property int panelWidgetsCount: 0
    property real trayItemThikness: 20
    property var globalWidgetSettings: {
        try {
            return JSON.parse(plasmoid.configuration.globalWidgetSettings)
        } catch (e) {
            console.error(e, e.stack)
            return {}
        }
    }

    property var panelWidgetSettings: {
        try {
            return JSON.parse(plasmoid.configuration.panelWidgetSettings)
        } catch (e) {
            console.error(e, e.stack)
            return {}
        }
    }

    property var trayWidgetSettings: {
        try {
            return JSON.parse(plasmoid.configuration.trayWidgetSettings)
        } catch (e) {
            console.error(e, e.stack)
            return {}
        }
    }

    function getItemCfg(itemType, name) {
        // TODO Create panel settigns
        if (itemType === Enums.ItemType.PanelBgItem) {
            return panelWidgetSettings
        } else if (itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow) {
            return trayWidgetSettings
        } else {
            return globalWidgetSettings
        }
    }

    property Component backgroundComponent: Kirigami.ShadowedRectangle {
        id: rect
        property Item target
        property int itemType
        property bool luisbocanegraPanelColorizerBgManaged: true
        property var cfg: {
            return getItemCfg(itemType, null) //TODO widget name here
        }
        corners {
            topLeftRadius: cfg.radius.topLeft
            topRightRadius: cfg.radius.topRight
            bottomLeftRadius: cfg.radius.bottomLeft
            bottomRightRadius: cfg.radius.bottomRight
        }
        color: cfg.backgroundColor.custom //Utils.getRandomColor() //TODO color logic
        height: itemType === Enums.ItemType.TrayItem ? target.height : parent.height
        width: itemType === Enums.ItemType.TrayItem ? target.width : parent.width
        anchors.centerIn: (itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow) ? parent : undefined
        anchors.fill: (itemType === Enums.ItemType.PanelBgItem||itemType === Enums.ItemType.TrayItem || itemType === Enums.ItemType.TrayArrow) ? parent : undefined

        property bool addMargin: cfg.margins.left || cfg.margins.right || cfg.margins.top || cfg.margins.bottom || itemType === Enums.ItemType.PanelBgItem
        property int marginLeft: cfg.margins.left
        property int marginRight: cfg.margins.right
        property int horizontalWidth: marginLeft + marginRight

        property int marginTop: cfg.margins.top
        property int marginBottom: cfg.margins.bottom
        property int verticalWidth: marginTop + marginBottom

        Binding {
            target: rect
            property: "x"
            value: -marginLeft
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect
            property: "width"
            value: parent.width + horizontalWidth
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect.target
            property: "Layout.leftMargin"
            value: marginLeft
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect.target
            property: "Layout.rightMargin"
            value: marginRight
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect.target
            property: "Layout.topMargin"
            value: marginTop
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        Binding {
            target: rect.target
            property: "Layout.bottomMargin"
            value: marginBottom
            when: addMargin && itemType === Enums.ItemType.WidgetItem
        }

        // Panel background, we actually change the panel margins so everything moves with it

        Binding {
            target: rect.target
            property: "anchors.leftMargin"
            value: marginLeft
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.rightMargin"
            value: marginRight
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.topMargin"
            value: marginTop
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        Binding {
            target: rect.target
            property: "anchors.bottomMargin"
            value: marginBottom
            when: addMargin && itemType === Enums.ItemType.PanelBgItem
        }

        // Tray item / arrow

        Binding {
            target: rect
            property: "anchors.leftMargin"
            value: marginLeft
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        Binding {
            target: rect
            property: "anchors.rightMargin"
            value: marginRight
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        Binding {
            target: rect
            property: "anchors.topMargin"
            value: marginTop
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        Binding {
            target: rect
            property: "anchors.bottomMargin"
            value: marginBottom
            when: addMargin && (itemType === Enums.ItemType.TrayArrow || itemType === Enums.ItemType.TrayItem)
        }

        Rectangle {
            id: borderRec
            anchors.fill: parent
            color: "transparent"

            Rectangle {
                id: customBorderTop
                width: parent.width
                visible: cfg.border.customSides && cfg.border.custom.widths.top
                height: cfg.border.custom.widths.top
                color: cfg.border.color.custom
                anchors.top: parent.top
            }
            Rectangle {
                id: customBorderBottom
                width: parent.width
                visible: cfg.border.customSides && cfg.border.custom.widths.bottom
                height: cfg.border.custom.widths.bottom
                color: cfg.border.color.custom
                anchors.bottom: parent.bottom
            }

            Rectangle {
                id: customBorderLeft
                height: parent.height
                visible: cfg.border.customSides && cfg.border.custom.widths.left
                width: cfg.border.custom.widths.left
                color: cfg.border.color.custom
                anchors.left: parent.left
            }
            Rectangle {
                id: customBorderRight
                height: parent.height
                visible: cfg.border.customSides && cfg.border.custom.widths.right
                width: cfg.border.custom.widths.right
                color: cfg.border.color.custom
                anchors.right: parent.right
            }

            Kirigami.ShadowedRectangle {
                anchors.fill: parent
                color: "transparent"
                visible: !cfg.border.customSides
                border {
                    color: cfg.border.color.custom //TODO color logic
                    width: cfg.border.width
                }
                corners {
                    topLeftRadius: cfg.radius.topLeft
                    topRightRadius: cfg.radius.topRight
                    bottomLeftRadius: cfg.radius.bottomLeft
                    bottomRightRadius: cfg.radius.bottomRight
                }
            }

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSpreadAtMax: 1
                maskSpreadAtMin: 1
                maskThresholdMin: 0.5
                maskSource: ShaderEffectSource {
                    sourceItem: Kirigami.ShadowedRectangle {
                        width: rect.width
                        height: rect.height
                        corners {
                            topLeftRadius: cfg.radius.topLeft
                            topRightRadius: cfg.radius.topRight
                            bottomLeftRadius: cfg.radius.bottomLeft
                            bottomRightRadius: cfg.radius.bottomRight
                        }
                    }
                }
            }
        }

        shadow {
            size: cfg.shadow.size
            color: Qt.rgba(0,0,0,0.3) //Utils.getRandomColor() //TODO color logic
            xOffset: cfg.shadow.xOffset
            yOffset: cfg.shadow.yOffset
        }
    }

    fullRepresentation: RowLayout {
        Label {
            text: panelLayoutCount+","+trayGridViewCount
        }
    }

    // Search the actual gridLayout of the panel
    property GridLayout panelLayout: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate instanceof GridLayout) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    property Item panelLayoutContainer: {
        if (!panelLayout) return null
        return panelLayout.parent
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.leftMargin"
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && horizontal
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.rightMargin"
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && horizontal
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.topMargin"
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && !horizontal
    }

    Binding {
        target: panelLayoutContainer
        property: "anchors.bottomMargin"
        value: fixedSideMarginSize
        when: fixedSideMarginEnabled && !horizontal
    }

    property Item panelBg: {
        if (!panelLayoutContainer) return null
        return panelLayoutContainer.parent
    }

    property GridView trayGridView: {
        if (!panelLayout?.children) return null
        for (let i in panelLayout.children) {
            const child = panelLayout.children[i];
            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue
            const name = child.applet.plasmoid.pluginName
            if (name === "org.kde.plasma.systemtray") {
                return Utils.findTrayGridView(child)
            }
        }
        return null;
    }

    property Item trayExpandArrow: {
        if (trayGridView?.parent) {
            return Utils.findTrayExpandArrow(trayGridView.parent)
        }
        return null
    }

    Connections {
        target: trayGridView
        onWidthChanged: {
            if (horizontal) {
                trayExpandArrow.iconSize = trayGridView.cellWidth
            } else {
                trayExpandArrow.iconSize = trayGridView.cellHeight
            }
        }
        onHeightChanged: {
            if (horizontal) {
                trayExpandArrow.iconSize = trayGridView.cellWidth
            } else {
                trayExpandArrow.iconSize = trayGridView.cellHeight
            }
        }
    }

    // Search for the element containing the panel background
    property var panelElement: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate.hasOwnProperty("floating")) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    property ContainmentItem containmentItem: {
        let candidate = main.parent;
        while (candidate) {
            if (candidate.toString().indexOf("ContainmentItem_QML") > -1 ) {
                return candidate;
            }
            candidate = candidate.parent;
        }
        return null
    }

    onPanelElementChanged: {
        if(!panelElement) return
        Utils.panelOpacity(panelElement, isEnabled, panelOriginalOpacity)
    }

    onContainmentItemChanged: {
        if(!containmentItem) return
        Utils.toggleTransparency(containmentItem, panelOriginalBgHidden)
    }

    onPanelLayoutCountChanged: {
        if (panelLayoutCount === 0) return
        showWidgets(panelLayout)
        updateCurrentWidgets()
        showPanelBg(panelBg)
    }

    onTrayGridViewCountChanged: {
        if (trayGridViewCount === 0) return
        console.error(trayGridViewCount);
        trayInitTimer.restart()
    }

    Timer {
        id: trayInitTimer
        interval: 5
        onTriggered: {
            if (trayGridViewCount === 0) return
            if (!trayGridView) return
            showTrayAreas(trayGridView)
            showTrayAreas(trayGridView.parent)
            updateCurrentWidgets()
        }
    }

    function updateCurrentWidgets() {
        if (!trayGridView) return
        panelWidgets = []
        panelWidgets = Utils.findWidgets(panelLayout, panelWidgets)
        panelWidgets = Utils.findWidgetsTray(trayGridView, panelWidgets)
        panelWidgets = Utils.findWidgetsTray(trayGridView.parent, panelWidgets)
    }

    function showTrayAreas(grid) {
        if (grid instanceof GridView) {
            for (let i = 0; i < grid.count; i++) {
                const item = grid.itemAtIndex(i);
                if (Utils.isBgManaged(item)) continue
                Utils.dumpProps(item)
                backgroundComponent.createObject(item, {"z":-1, "target": item, "itemType": Enums.ItemType.TrayItem })
            }
        }
        // find the expand tray arrow
        if (grid instanceof GridLayout) {
            for (let i in grid.children) {
                const item = grid.children[i]
                if (!(item instanceof GridView)) {
                    if (Utils.isBgManaged(item)) continue
                    item.iconSize = horizontal ? trayGridView.cellWidth : trayGridView.cellHeight
                    backgroundComponent.createObject(item, {"z":-1, "target": item, "itemType": Enums.ItemType.TrayArrow })
                }
            }
        }
    }

    function showWidgets(panelLayout) {
        for (var i in panelLayout.children) {
            const child = panelLayout.children[i];
            // name may not be available while gragging into the panel and
            // other situations
            if (!child.applet?.plasmoid?.pluginName) continue
            if (Utils.isBgManaged(child)) continue
            console.error(child.applet?.plasmoid?.pluginName)
            // Utils.dumpProps(child)
            backgroundComponent.createObject(child, { "z":-1, "target":child, "itemType": Enums.ItemType.WidgetItem });
        }
    }

    function showPanelBg(panelBg) {
        // Utils.dumpProps(panelBg)
        backgroundComponent.createObject(panelBg, {"z":-1, "target": panelBg, "itemType": Enums.ItemType.PanelBgItem });
    }

    onPanelWidgetsCountChanged: {
        console.error( panelWidgetsCount ,JSON.stringify(panelWidgets, null, null))
        plasmoid.configuration.panelWidgets = ""
        plasmoid.configuration.panelWidgets = JSON.stringify(panelWidgets, null, null)
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            let tmp = panelWidgets.length
            if (tmp !== panelWidgetsCount) {
                panelWidgetsCount = tmp
            }
        }
    }
}
