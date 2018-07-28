import QtQuick 2.7

SpoolInfoColumnForm {
    function init() {
        if (initialized) return;

        title.text = index ? "SPOOL B/2" : "SPOOL A/1";
        var name = index ? "spoolB" : "spoolA";

        // TODO: color
        // UPDATE_INT_LIST_PROP(spoolAColorRGB, result["material_color"]);

        var key_string_map = {
            "OriginalAmount": "ORIGINAL AMOUNT",
            "Version": "VERSION",
            "ManufacturingLotCode": "MANUFACTURING LOT CODE",
            "ManufacturingDate": "MANUFACTURING DATE",
            "SupplierCode": "SUPPLIER CODE",
            "Material": "MATERIAL",
            "Checksum": "CHECKSUM"
        }

        for (var key in key_string_map) {
            var keyObj = keyItem.createObject(keys);
            keyObj.text = key_string_map[key];

            var valObj = valItem.createObject(vals);
            valObj.key = name+key;
        }

        // connect tag change signal
        var spoolUIDchangedSignal = "onInfoBay%1TagUIDChanged".arg(index+1);
        bot[spoolUIDchangedSignal].connect(function() {
            bot.getSpoolInfo(index);
        });

        initialized = true;
    }
}
