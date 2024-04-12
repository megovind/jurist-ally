const passport = require("passport");
const express = require("express");
const router = express.Router();

const PaymentController = require("../../Controllers/Payments");

//to upload file on s3 bucket
router.post(
    "/create-order",
    // passport.authenticate("jwt", { session: false }),
    PaymentController.create_order
);

router.get(
    "/fetch-order/:id/:user",
    passport.authenticate("jwt", { session: false }),
    PaymentController.fetch_order
);

router.post(
    "/update-order-payment",
    passport.authenticate("jwt", { session: false }),
    PaymentController.update_payment
);

router.get(
    "/fetch-orders/:user",
    passport.authenticate("jwt", { session: false }),
    PaymentController.fetch_orders
)

router.post(
    "/validate-signature",
    passport.authenticate("jwt", { session: false }),
    PaymentController.validate_signature
);


module.exports = router;