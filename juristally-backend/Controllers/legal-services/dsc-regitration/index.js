const _ = require("lodash");

const { create_updates } = require("../updates");
const services = require("../../../services/legal-services.service");


exports.dsc_registration = async (req, res) => {
    try {
        const data = { ...req.body, ...{ user: req.user._id } };
        const dscResponse = await services.CREATE_DSC_REGISTRATION(data); //dsc.save();
        if (_.isEmpty(dscResponse)) return res.send({ status: "ERROR", message: "Application can not be completed!" });
        await create_updates(req.body.category, dscResponse._id);
        const response = await services.FETCH_DSC_REGISTRATION({ _id: dscResponse._id });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_dsc_registration = async (req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;
        const response = await services.UPDATE_DSC_REGISTRATION(id, { $set: data });
        if (_.isEmpty(response)) return res.send({ status: "ERROR", message: "Service can not be updated" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}