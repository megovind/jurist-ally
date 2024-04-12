const passport = require("passport");
const express = require("express");
const router = express.Router();

const NewsController = require("../../Controllers/News");

router.post(
    "/create-news/:id",
    // passport.authenticate("jwt", { session: false }),
    NewsController.create_news
);

router.post(
    "/fetch-news",
    passport.authenticate("jwt", { session: false }),
    NewsController.fetch_news
);


module.exports = router;