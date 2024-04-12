const mongoose = require("mongoose");
const RazorPay = require("razorpay");
const Crypto = require("crypto-js");
const _ = require("lodash");
const moment = require("moment");

const Orders = require("../../Models/Orders");
const Subscription = require("../../Models/Subscription");
const User = require("../../Models/Auth");
const LegalService = require("../../Models/LegalServices/business_registration");
const { send_sms } = require("../../Utilities/send_sms");
const { send_mails } = require("../../Utilities/send_mail");
const { generate_reciept_number } = require("../../Utilities/generate-receipt_number")
const { save_order, update_order } = require("./update_order")

exports.create_order = async (req, res) => {
    try {
        const reciept_num = generate_reciept_number();
        const options = {
            amount: req.body.amount,  // amount in the smallest currency unit
            currency: "INR",
            receipt: reciept_num
        }
        const instance = new RazorPay({
            key_id: process.env.KEY_SECRET_ID,
            key_secret: process.env.KEY_SECRET,
        });

        if (req.body.is_in_trial) {
            const response = await save_order({ ...req.body, ...options });
            return res.send({ status: "SUCCESS", response });
        }
        return instance.orders.create(options, async (error, order) => {
            if (error != null) {
                return res.send({ status: "ERROR", error });
            }
            const response = await save_order({ ...order, ...req.body })
            return res.send({ status: "SUCCESS", order, response });
        });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}


exports.fetch_order = async (req, res) => {
    try {
        const response = await Orders.findOne({ $and: [{ _id: req.params.id }, { user: req.params.user }] });
        if (_.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.update_payment = async (req, res) => {
    try {
        const data = req.body;
        const order = await update_order(data);
        let response;
        if (data.is_service) {
            response = await update_service(data);
        } else {
            response = await add_subscription(data);
        }
        if (_.isEmpty(order) && _.isEmpty(response)) {
            return res.send({ status: "ERROR", message: "Something went wrong!" });
        }
        return res.send({ status: "SUCCESS", subscription: response, response, order })
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

exports.fetch_orders = async (req, res) => {
    try {
        const response = await Orders.find({ user: req.params.user }).populate("plan").exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: "Orders not found!" });
        }
        return res.send({ status: "SUCCESS", response });
    } catch (error) {
        return res.send({ status: "ERROR", message: error.message });
    }
}

const update_service = async (data) => {
    const updateData = {
        order: data.order_id,
        payment_status: "paid",
    }
    const serviceResponse = await LegalService.findByIdAndUpdate({ _id: data.service_id }, { $set: updateData }).populate("type").populate("handler", "_id full_name email contact_number type");
    if (_.isEmpty(serviceResponse)) {
        return serviceResponse;
    }
    const response = await User.findById({ _id: data.user });
    const { full_name, email, phone } = response;
    const handlerId = process.env.NODE_ENV != 'development' ? '5f951cf65d576e34c096f0a4' : "5fdaec800a606032b56bea0a"
    const handlerResp = serviceResponse.handler.find((usr) => usr._id == handlerId);
    // let sms_text = `Thank you for choosing us, Your subscription will start from ${moment(data.start_date).format("LL")} and end on ${moment(data.end_date).format("LL")}`;
    const mail = service_mail(full_name, serviceResponse.type.category, serviceResponse.type.price, serviceResponse.type.title);
    const handlerMessage = serviceMailHandler(handlerResp.full_name, full_name, serviceResponse.type.category, serviceResponse.type.title)
    const subject = "Thanks for Choosing JuristAlly!";
    const handlerSubject = 'Juristally: Service request';
    await send_mails(email, subject, mail);
    await send_mails(handlerResp.email, handlerSubject, handlerMessage);
    return response;
}


const add_subscription = async (data) => {
    const subscription = new Subscription({
        _id: mongoose.Types.ObjectId(),
        user: data.user,
        active_plan: data.plan,
        type: data.subscription_type,
        start_date: data.start_date,
        end_date: data.end_date
    })
    const resp = await subscription.save();
    if (_.isEmpty(resp)) {
        return resp;
    }
    const response = await User.findByIdAndUpdate({ _id: data.user }, { $set: { subscription: resp._id, is_in_trial: data.is_in_trial } });
    const { full_name, email, phone } = response;
    let sms_text = `Thank you for choosing us, Your subscription will start from ${moment(data.start_date).format("LL")} and end on ${moment(data.end_date).format("LL")}`;
    let mail = subscription_mail(data.start_date, data.end_date);
    let subject = "Thanks for Choosing JuristAlly!";
    if (data.is_in_trial) {
        sms_text = `Thank you for choosing us, Your trial period starts on ${moment(data.start_date).format("LL")} and end on ${moment(data.end_date).format("LL")}`;
        mail = free_trial_mail(data.start_date, data.end_date);
        subject = "Welcome to your JuristAlly free trial.";
    }
    await send_mails(email, subject, mail)
    send_sms(phone, sms_text);
    return resp;
}

exports.validate_signature = async (req, res) => {
    try {
        const orderId = req.body.order_id,
            razorpayPaymentId = req.body.paymentId,
            signature = req.headers['x-razorpay-signature']
        const response = Crypto.HmacSHA256(orderId + "|" + razorpayPaymentId, process.env.KEY_SECRET).toString();
        return res.send({ response: response, signature: signature });
    } catch (error) {
        return res.send({ error });
    }
}

const free_trial_mail = (start_date, end_date) => {
    const message = `<div> <p>Hi There,</p>
    <br />
    <p> Thanks for subscribing to <b>JuristAlly</b>. Your free trial of <b>7 days</b> will start from <b>${moment(start_date).format("LL")}</b> and will end on <b>${moment(end_date).format("LL")}</b>.</p>
    
    <p> If you have any further questions then please reach out to <a href="mailto:info@juristally.com">info@juristally.com</a></p>
    <br />
    <p>--</p>
    <p>Warm Regards,</P>
    <p>JuristAlly Team</p></div>
    `;
    return message;
}


const subscription_mail = (start_date, end_date) => {
    return `<div> <p>Hi There,</p>

    <p>Thanks for subscribing to JuristAlly. We have successfully processed your payment so you can start our services from now onwards.</p>
    
    <p>If you have any further questions then please reach out to <a href="mailto:info@juristally.com">info@juristally.com</a></p>
    
    <p>Your subscription period will start on <b>${moment(start_date).format("LL")}</b> and will end on <b>${moment(end_date).format("LL")}</b>.</p>
    
    <p>--</p>
    <p>Warm Regards,</p>
   <p>JuristAlly Team</p></div>
    `;
}

const service_mail = (username, category, price, title) => {
    return category != 'business_registration' ?
        `<div><p>Dear Mr. ${username},</p>
    <p>Thanks for choosing JuristAlly as your service partner. We have received your payment of <b>Rs.${price}/-</b> for <b>${title}</b>. We make sure to deliver the service within <b>3 to 5 days</b>.</p>
    <p>You can do live tracking of your progress. So just download the app to keep an eye on the progress of your work.</p>

    <p>If you find any queries then don’t stop yourself to reach me @ +91 6299611312</p>

    <p>Warm Regards,</p>
    <p>Team JuristAlly</p>
    <p>Mob : +91 6299611312</p>
    <p><a href="mailto:sales@juristally.com" >sales@juristally.com</a></p>
    <p><a href="www.juristally.com">www.juristally.com</a></p></div>` : `<div><p>Dear Mr. ${username},</p>
    <p>Thanks for choosing JuristAlly as your service partner. We have received your payment of <b>Rs.${price}/-</b> for <b>${title}</b>. We make sure to deliver the service within <b>7 To 10 days</b>.</p> 
    <p>You can do live tracking of your progress. So just download the app to keep eye on the progress of your work.</p>

    <p>If you find any queries then don’t stop yourself to reach me @ +91 6299611312</p>

    <p>Warm Regards,</p>
    <p>Team JuristAlly</p>
    <p>Mob : +91 6299611312</p>
    <p><a href="mailto:sales@juristally.com" >sales@juristally.com</a></p>
    <p><a href="www.juristally.com">www.juristally.com</a></p></div>`;
}

const serviceMailHandler = (handler, client, category, title) => {
    let deadline = "";
    if (category == 'business_registration') {
        deadline = '7 to 10 days';
    } else if (category == 'dsc_registration') {
        deadline = '3 to 5 days';
    }
    return `<div> <p>Dear ${handler},</p>

   <p>Our client <b>${client}</b> has applied for <b>${title}</b>. We have received the payment and you can find the details on the application.</p> 
   <p>Kindly find the documents uploaded by the applicant.</p>
   <p>We have the deadline of <b>${deadline}</b> to complete the process.</p>
    
   <p>Warm Regards,</p>
   <p>Team JuristAlly</p> </div>`;
}