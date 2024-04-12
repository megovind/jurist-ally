const mongoose = require("mongoose");
const _ = require("lodash");

const Litigation = require("../../Models/Litigations")
const User = require("../../Models/Auth");
const { send_mails } = require("../../Utilities/send_mail")

exports.create_litigation = async (req, res) => {
    try {
        const count = await Litigation.countDocuments({ user_id: req.body.user_id });
        const caseId = generateLmisId(count);
        const litigation = new Litigation({
            _id: mongoose.Types.ObjectId(),
            user_id: req.body.user_id,
            case_id: caseId,
            file_no: req.body.file_no,
            case_number: req.body.case_number,
            case_type: req.body.case_type,
            client: req.body.client,
            client_names: req.body.client_names,
            title: req.body.title,
            brief_case: req.body.brief_case,
            start_date: req.body.start_date
        })
        const response = await litigation.save();
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_litigations_by_user = async (req, res) => {
    try {
        const userId = req.params.user_id;
        const response = await Litigation.find({ user_id: userId }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: 'Litigations not found.' });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

const generateLmisId = (count) => {
    let result = "";
    const date = new Date();
    const charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
    const text1 = charset.charAt(Math.floor(Math.random() * charset.length));
    const text2 = charset.charAt(Math.floor(Math.random() * charset.length));
    const text = text1 + text2;
    if (count < 9) {
        result = text.toUpperCase() + "-0" + (count + 1);
    } else {
        result = text.toUpperCase() + "-" + (count + 1);
    }
    return "LMIS-" + date.toISOString().split("T")[0].replace(/\-/g, "") + "-" + result;
}

exports.update_case_id = async (req, res) => {
    try {
        const users = await User.find();
        console.log(users);
        users.map(async usr => {
            console.log(usr);
            const response = await Litigation.find({ user_id: usr._id });
            response.map(async (d, index) => {
                const caseId = generateLmisId(index - 1);
                await Litigation.findByIdAndUpdate({ _id: d._id }, { $set: { case_id: caseId } });
            });
            return true;
        });

        return res.send({ status: "IDs Updated Successfully" });
    } catch (error) {
        return res.send({ status: "ERROR: Ids can not be updated" });
    }
}

exports.search_litigation_by_case = async (req, res) => {
    try {
        const caseId = req.params.case;
        const response = await Litigation.findOne({ case_id: caseId });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Litigation MIS not found for the provided Case ID!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Litigation MIS not found for the provided Case ID!" });
    }
}

exports.fetch_litigations = async (req, res) => {
    try {
        const response = await Litigation.find().exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Mis Litigations not found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_litigation_by_id = async (req, res) => {
    try {
        const id = req.params.id;
        if (_.isEmpty(id)) {
            return res.send({ status: "ERROR", message: "Id can not be empty" });
        }
        const response = await Litigation.findById({ _id: id }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Case details not found!" })
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

//To update court details of the litigation
exports.update_court = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { court_details: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

//update litigation status
exports.update_litigation_status = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { application_status: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// update litigation client info
exports.update_client_opponent = async (req, res) => {
    try {
        const isOpponent = req.params.isOpponent;
        const id = req.params.id;
        const response = isOpponent === "true"
            ? await Litigation.findByIdAndUpdate({ _id: id }, { $set: { client_oppo: req.body } })
            : await Litigation.findByIdAndUpdate({ _id: id }, { $set: { client: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

//update advocate
exports.update_Advocate = async (req, res) => {
    try {
        const isOpponent = req.params.isOpponent;
        const id = req.params.id;
        const response = isOpponent === "true"
            ? await Litigation.findByIdAndUpdate({ _id: id }, { $set: { oppo_advocate: req.body } })
            : await Litigation.findByIdAndUpdate({ _id: id }, { $set: { advocate: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// update vakalatmana
exports.update_vakalatnama = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { vakalatnama: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// update evidence
exports.update_evidence = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { evidence: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// update written statement
exports.update_written_statement = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { written_statement: req.body, } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

//update written argumanet
exports.update_written_argument = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { written_argument: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

//update drafting
exports.update_drafting = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { drafting: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// annexure update
exports.update_annexure = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { annexure: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

//Update fee
exports.update_professional_fee = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { 'professional_fee.total_amount': req.body.total_fee }, $push: { 'professional_fee.advance': req.body.advance } }, { new: true });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// Update hearing date
exports.update_hearing_date = async (req, res) => {
    try {
        const isNext = req.params.isnext;
        const id = req.params.id;
        const response = isNext === "true"
            ? await Litigation.findByIdAndUpdate({ _id: id }, { $set: { next_hearing_date: req.body } })
            : await Litigation.findByIdAndUpdate({ _id: id }, { $push: { date_of_hearings: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// update judgement
exports.update_final_argument_judgement = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { final_judgement: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// update remark
exports.update_remarks = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $push: { remarks: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

// request assign to litigation
exports.request_to_access_litigation = async (req, res) => {
    try {
        const email = req.body.email;
        const id = req.params.id;
        const response = await User.findOne({ email: email });
        // if (_.isEmpty(response)) {
        //     //register user
        //     const user = new User({
        //         _id: new mongoose.Types.ObjectId(),
        //         full_name: req.body.name,
        //         email: req.body.email,
        //         contact_number: req.body.contact_number,
        //         accept_terms: req.body.accept_terms,
        //         salt_value: salt, //password should be salt encrypted
        //         sign_in_method: "password",
        //         referral_code: ref_code
        //     });
        //     response = user.save();
        // }
        const data = {
            user: response._id,
            permission: req.body.allowed_permission
        };
        const litiResp = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { assign_request: data } }, { new: true });
        const message = "";
        send_mails(email, "", message);
        return res.send({ status: "SUCCESS", response: litiResp });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Something went wrong" });
    }
}


exports.update_available_document = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { available_document: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.add_contact_person = async (req, res) => {
    try {
        const id = req.params.id;
        const response = await Litigation.findByIdAndUpdate({ _id: id }, { $set: { contact_person: req.body } });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.request_update = async (req, res) => {
    try {
        const laywerId = req.body.user_id;
        const caseId = req.params.id;
        return res.send({ status: "ERROR", message: "Can not send an request" });
    } catch (error) {
        return res.send({ status: "ERROR", message: "Request unable to send!" })
    }
}