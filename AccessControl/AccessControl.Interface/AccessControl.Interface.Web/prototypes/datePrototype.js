Date.prototype.isValid = function () {
    return this.getTime() === this.getTime();
};

String.prototype.getWcfJsonDate = function () {
    return new Date(parseInt(this.match(/\/Date\(([0-9]+)(?:.*)\)\//)[1]));
};

Date.prototype.setWcfJsonDate = function () {
    var date = null;
    if (this.isValid()) {
        date = "/Date(" + this.getTime() + ")/";
    }
    return date;
};

Date.prototype.setWcfJsonDateOffset = function () {
    var dateOffset = null;
    var date = this.setWcfJsonDate();
    if (date != null) {
        dateOffset = {
            DateTime: date,
            OffsetMinutes: -this.getTimezoneOffset()
        };
    }
    return dateOffset;
};
