const _ = require("lodash");

const { create_updates } = require("../updates");
const services = require("../../../services/legal-services.service");

exports.create_business_registeration = async (req, res) => {
    try {
        const data = { ...req.body, ...{ user: req.user._id } };
        const saved = await services.CREATE_BUSINESS_REGISTRATION(data);
        if (_.isEmpty(saved)) return res.send({ status: "ERROR", message: "Something went wrong" });
        await create_updates(req.body.category, saved._id);
        const response = await services.FETCH_BUSINESS_REGISTRATION({ _id: saved._id });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_business_registration = async (req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;
        const response = await services.UPDATE_BUSINESS_REGISTRATION(id, { $set: data });
        if (_.isEmpty(response)) return res.send({ status: "ERROR", message: "Service can not be updated" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.register_director = async (req, res) => {
    try {
        const id = req.params.id;
        const data = req.body;
        const applicant = await services.CREATE_DIRECTOR(data);
        if (_.isEmpty(applicant)) return res.send({ status: "ERROR", message: "Something went wrong" });
        await services.UPDATE_BUSINESS_REGISTRATION(id, { $push: { applicant_details: applicant._id } });
        return res.send({ status: "SUCCESS", response: applicant });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_director_details = async (req, res) => {
    try {
        const dId = req.params.d_id;
        const sId = req.params.s_id;
        const data = req.body;
        const director = await services.UPDATE_DIRECTOR(dId, data);  // Directors.findByIdAndUpdate({ _id: dId }, { $set: data });
        if (_.isEmpty(director)) return res.send({ status: "ERROR", message: "Applicant details can not be updated" });
        return res.send({ status: "SUCCESS", response: director });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.delete_director = async (req, res) => {
    try {
        const dId = req.params.d_id;
        const sId = req.params.s_id;
        const removed = await services.DELETE_DIRECTOR(dId); //Directors.findByIdAndRemove({ _id: dId });
        const response = await services.UPDATE_BUSINESS_REGISTRATION(sId, { $pull: { applicant_details: dId } });
        if (_.isEmpty(removed)) return res.send({ status: "ERROR", message: "Applicant can't be removed" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_Services_by_user = async (req, res) => {
    try {
        const usr = req.user._id;
        const category = req.query.category;
        const data = { user: usr };
        let response;
        if (category === 'business_registration') {
            response = await services.FETCH_ALL_BUSINESS_REGISTRATION(data);
        } else if (category === 'dsc_registration') {
            response = await services.FETCH_ALL_DSC_REGISTRATION(data);
        } else {
            response = await services.FETCH_ALL_ITR_GST_FILLINGS(data);
        }
        if (_.isEmpty(response)) return res.send({ status: "ERROR", message: "Services not found" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


exports.fetch_service = async (req, res) => {
    try {
        const id = req.params.id;
        const category = req.query.category;
        const data = { _id: id };
        let response;
        if (category === 'business_registration') {
            response = await services.FETCH_BUSINESS_REGISTRATION(data);
        } else if (category === 'dsc_registration') {
            response = await services.FETCH_DSC_REGISTRATION(data);
        } else {
            response = await services.FETCH_ITR_GST_FILLING(data);
        }
        if (_.isEmpty(response)) return res.send({ status: "ERROR", message: "Service not found" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_incomplete_service = async (req, res) => {
    try {
        const userId = req.user._id;
        const category = req.query.category;
        const data = { $and: [{ user: userId }, { status: "incomplete" }] };
        let response;
        if (category === 'business_registration') {
            response = await services.FETCH_BUSINESS_REGISTRATION(data);
        } else if (category === 'dsc_registration') {
            response = await services.FETCH_DSC_REGISTRATION(data);
        } else {
            response = await services.FETCH_ITR_GST_FILLING(data);
        } if (_.isEmpty(response)) return res.send({ status: "NOT_FOUND", message: "Data not found!" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_Services_by_handler = async (req, res) => {
    try {
        const id = req.user._id;
        const category = req.query.category;
        const data = { handler: id };
        let response;
        if (category === 'business_registration') {
            response = await services.FETCH_BUSINESS_REGISTRATION(data);
        } else if (category === 'dsc_registration') {
            response = await services.FETCH_DSC_REGISTRATION(data);
        } else {
            response = await services.FETCH_ITR_GST_FILLING(data);
        }
        if (_.isEmpty(response)) return res.send({ status: "ERROR", message: "There is no services found" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_legal_service_updates = async (req, res) => {
    try {
        const id = req.params.id;
        const file = req.body.file;
        const data = { ...req.body, ...{ updated_at: Date.now() } };
        if (!_.isNull(file)) {
            await services.UPDATE_SERVICE_UPDATES(id, { $push: { files: file } });
        }
        const update = await services.UPDATE_SERVICE_UPDATES(id, { $set: data });
        if (_.isEmpty(update)) return res.send({ status: "ERROR", message: "Can not update" });
        return res.send({ status: "SUCCESS", update });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}
