import QtQuick 2.7

SpoolInfoColumnForm {
    function init() {
        if (initialized) return;

        title.text = index ? "SPOOL B/2" : "SPOOL A/1";
        var name = index ? "spoolB" : "spoolA";

        // UID (doesn't follow the 'spoolA/spoolB' naming convention)
        var uidKey = keyItem.createObject(keys);
        uidKey.text = "UID";
        var uidVal = valItem.createObject(vals);
        uidVal.key = "infoBay%1TagUID".arg(index+1);

        var properties = [
            {
                key: "Material",
                displayString: "MATERIAL",
            },
            {
                key: "ColorName",
                displayString: "COLOR NAME",
            },
            {
                key: "ColorRGB",
                displayString: "COLOR",
                type: "color"
            },
            {
                key: "AmountRemaining",
                displayString: "AMOUNT REMAINING",
                unit: "mm"
            },
            {
                key: "OriginalAmount",
                displayString: "ORIGINAL AMOUNT",
                unit: "mm"
            },
            {
                key: "FirstLoadDate",
                displayString: "FIRST LOAD DATE",
                type: "date"
            },
            {
              key: "MaxHumidity",
                displayString: "MAX HUMIDITY",
                unit: "%"
            },
            {
                key: "MaxTemperature",
                displayString: "MAX TEMPERATURE",
                unit: "\u00b0C"
            },
            {
                key: "ManufacturingLotCode",
                displayString: "MANUFACTURING LOT CODE",
            },
            {
                key: "ManufacturingDate",
                displayString: "MANUFACTURING DATE",
                type: "date"
            },
            {
                key: "SupplierCode",
                displayString: "SUPPLIER CODE",
            },
            {
                key: "Checksum",
                displayString: "CHECKSUM"
            },
            {
                key: "Version",
                displayString: "VERSION",
            },
            {
                key: "SchemaVersion",
                displayString: "SCHEMA VERSION",
            },
        ];

        for (var idx in properties) {
            var prop = properties[idx];
            var keyObj = keyItem.createObject(keys);
            keyObj.text = prop.displayString;

            if (prop.type && prop.type === "date") {
                var valObj = dateValItem.createObject(vals);
            } else if (prop.type && prop.type === "color") {
                var valObj = colorItem.createObject(vals);
            } else {
                var valObj = valItem.createObject(vals);
                if (prop.unit) {
                    valObj.unit = prop.unit;
                }
            }
            valObj.key = name+prop.key;
        }

        // connect tag change signal
        // TODO(shirley): I think this ends up getting called before the
        // get_spool_info cache is ready, so it gets a result of
        // { "tag_uid": null } ... For now, there's a refresh button.

        initialized = true;
    }
}
