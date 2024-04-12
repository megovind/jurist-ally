const passport = require("passport");
const express = require("express");
const router = express.Router();

const AuthController = require('../../Controllers/Auth');
const UserController = require("../../Controllers/Profile")
const SubscriptionController = require("../../Controllers/Subscriptions");

//signup router
router.post(
    "/sign-up",
    AuthController.sign_up
);

//signin router
router.post(
    "/sign-in",
    AuthController.sign_in
);

//signin with social media
router.post(
    "/sign-in-with-social-media",
    AuthController.signin_with_social_media
);



//verify otp
router.post(
    "/verify-otp",
    AuthController.verify_otp
);

router.post(
    "/resend-otp/:id",
    AuthController.resend_otp
)


//change password
router.post(
    "/reset-password",
    AuthController.reset_password
);
//send link
router.post(
    "/send-link-reset-password",
    AuthController.send_reset_password_link
);

//update user profile ==> deprecated
router.patch(
    "/update-profile/:id",
    passport.authenticate("jwt", { session: false }),
    UserController.update_profile
);

//update use type ==> deprecated
router.patch(
    "/update-user-type/:id",
    passport.authenticate("jwt", { session: false }),
    UserController.update_user_type
);


// update user profile
router.post(
    "/update-user-profile/:id",
    passport.authenticate("jwt", { session: false }),
    UserController.update_user_profile
);


//to get user details by id
router.get(
    "/fetch-user/:id",
    passport.authenticate("jwt", { session: false }),
    UserController.get_user_profile
);

//search usersubService
router.get(
    "/search-user",
    passport.authenticate("jwt", { session: false }),
    UserController.search_user
)

router.get(
    "/fetch-connections/:id",
    passport.authenticate("jwt", { session: false }),
    UserController.fetch_connection
);

router.post(
    "/send-connection-request/:sender_id/:reciever_id",
    passport.authenticate("jwt", { session: false }),
    UserController.send_connection_Request
);

router.post(
    "/accept-connection-request/:requester_id/:user_id",
    passport.authenticate("jwt", { session: false }),
    UserController.accept_request
);

router.post(
    "/reject-connection-request/:requester_id/:user_id",
    passport.authenticate("jwt", { session: false }),
    UserController.reject_request
);

router.post(
    "/create-subscription-card",
    SubscriptionController.create_card
)

router.get(
    "/fetch-subscription-card",
    passport.authenticate("jwt", { session: false }),
    SubscriptionController.fetch_subscription_card,
);

router.get(
    "/fetch-active-plan/:user",
    passport.authenticate("jwt", { session: false }),
    SubscriptionController.fetch_user_subscription
);


module.exports = router;
