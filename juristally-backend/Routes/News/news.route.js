const passport = require("passport");
const express = require("express");
const router = express.Router();

const NewsController = require("../../controllers/news");

router.post(
    "/create-news",
    passport.authenticate("jwt", { session: false }),
    NewsController.create_news
);

router.post(
    "/fetch-news",
    passport.authenticate("jwt", { session: false }),
    NewsController.fetch_news
);

router.post(
    "/update-news/:id",
    passport.authenticate("jwt", { session: false }),
    NewsController.update_news
);


module.exports = router;