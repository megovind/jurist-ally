const passport = require("passport");
const express = require("express");
const router = express.Router();

const ContactUsController = require("../../Controllers/ContactUs");

router.post(
    "/register-issue/:id",
    passport.authenticate("jwt", { session: false }),
    ContactUsController.contact_us
);

router.post(
    "/send-request",
    ContactUsController.get_request
);

module.exports = router;