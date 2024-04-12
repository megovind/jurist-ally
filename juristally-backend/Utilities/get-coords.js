const geoLib = require("geolib");

const findThePreciseDistance = (point, centerPoint, range) => {
    const data = JSON.parse(JSON.stringify(point));
    const result = data.map(fromLatLng => {
        let distance = geoLib.getPreciseDistance(
            { latitude: fromLatLng.location.latitude, longitude: fromLatLng.location.langitude },
            {
                latitude: centerPoint.latitude,
                longitude: centerPoint.langitude
            }
        );
        let conv = distance * 0.001;
        let res = Math.ceil(conv * 1000) / 1000;
        fromLatLng.distance = Math.round(res);

        if (res <= range) {
            return fromLatLng;
        }
    });

    return result;
};

exports.getCoordsInDistance = (points, centerPoint, radius, distance) => {
    const filterData = points.filter(fromLatLng => {
        return geoLib.isPointWithinRadius(
            { latitude: fromLatLng.location.latitude, longitude: fromLatLng.location.langitude },
            {
                latitude: centerPoint.latitude,
                longitude: centerPoint.langitude
            },
            radius
        );
    });
    return findThePreciseDistance(filterData, centerPoint, distance);
};