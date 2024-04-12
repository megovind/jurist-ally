const _ = require("lodash");

const services = require("../../../services/legal-services.service");
const { create_updates } = require("../updates");

exports.file_itr_gst = async (req, res) => {
    try {
        const data = { ...req.body, ...{ user: req.user._id } };// data
        const taxResponse = await services.CREATE_ITR_GST_FILLINGS(data); //data.save();
        if (_.isEmpty(taxResponse)) return res.send({ status: "ERROR", message: "Application can not be completed!" });
        await create_updates(req.body.category, taxResponse._id);
        const response = await services.FETCH_ITR_GST_FILLING({ _id: taxResponse._id });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong!" });
    }
}

exports.update_itr_gst = async (req, res) => {
    try {
        const sId = req.params.id;
        const invoice = req.body.invoice;
        const response = invoice != null
            ? await services.UPDATE_ITR_GST_FILLINGS(sId, { $push: { invoices: req.body.invoice } })
            : await services.UPDATE_ITR_GST_FILLINGS(sId, { $set: req.body });
        if (_.isEmpty(response)) return res.send({ status: "ERROR", message: "Something went wrong!" });
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}
