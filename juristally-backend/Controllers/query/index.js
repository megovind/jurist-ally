const _ = require("lodash");

const getCoordInDistance = require("../../utilities/get-coords").getCoordsInDistance;

const queryService = require("../../services/query.service");
const authService = require("../../services/auth.service");


exports.post_query = async (req, res) => {
    try {
        const location = req.body.location;
        const type = req.body.looking_for;
        let users;
        const queryLength = await queryService.QUERY_COUNT({ query_by: req.user._id });
        users = await authService.FIND_USER_BY_TYPE({ type: type });
        console.log(users);
        users = users.filter(usr => usr.location != null && usr.location.latitude != null && usr.location.longitude != null);
        let result = users.length > 0 ? getCoordInDistance(users, location, 40000, 40) : []  // in 20KM any user is found or not
        if (users.lenght > 0 || result.length < 2) {
            result = getCoordInDistance(users, location, 90000, 90);
        }
        const sortResult = _.sortBy(result, res => res.distance);
        const queryTo = sortResult.length > 0 ? sortResult.map(d => d._id).join(",").split(",") : [];
        const queryId = createId("QUERY", queryLength);
        const saveQuery = await queryService.CREATE_QUERY({ ...req.body, ...{ query_id: queryId, queried_to: queryTo, query_by: req.user._id } });
        if (_.isEmpty(saveQuery)) {
            return res.send({ status: 'ERROR', message: 'Something went wrong!' });
        }
        const queryResponse = await queryService.FIND_QUERY_BY_ID({ _id: saveQuery._id })
        return res.send({ status: "SUCCESS", response: queryResponse });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


exports.fetch_queries_by_creater = async (req, res) => {
    try {
        const queriedBy = req.user._id;
        const response = await queryService.FIND_QUERIES({ query_by: queriedBy });
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: 'Query not found' });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_query_by_type = async (req, res) => {
    try {
        const type = req.user.type;
        const queriedTo = req.user._id;
        const response = await queryService.FIND_QUERIES({ $and: [{ looking_for: type }, { queried_to: queriedTo }] });
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Query not found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


const createId = (type, count) => {
    let result = "";
    const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const text = charset.charAt(Math.floor(Math.random() * charset.length));
    if (count < 9) {
        result = type.toUpperCase().substring(0, 3) + text + "0" + (count + 1);
    } else {
        result = type.toUpperCase().substring(0, 3) + text + (count + 1);
    }
    return result;
};