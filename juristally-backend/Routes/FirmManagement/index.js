const passport = require("passport");
const express = require("express");
const router = express.Router();

const FirmController = require("../../Controllers/FirmManagement");

// Register firm
router.post(
    "/create-firm-page/:user_id",
    passport.authenticate("jwt", { session: false }),
    FirmController.create_firm_page
);

// check the firm if its reistered or not
router.get(
    "/check-firm",
    passport.authenticate("jwt", { session: false }),
    FirmController.check_firm
);

//get firm
router.post(
    "/fetch-firm-details/:id",
    passport.authenticate("jwt", { session: false }),
    FirmController.fetch_firm
);

//get firm eployees and clients
router.post(
    "/fetch-firm-eployees-clients/:id",
    passport.authenticate("jwt", { session: false }),
    FirmController.fetch_firms_employees_clients
);


module.exports = router