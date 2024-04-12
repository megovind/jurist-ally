const mongoose = require("mongoose");
const AWS = require("aws-sdk");
const _ = require("lodash");

const Judgements = require("../../Models/LegalUpdates/judgements");

exports.add_judgement = async (req, res) => {
    try {
        if (_.isEmpty(req.body.title)) {
            return res.send({ status: 'ERROR', message: 'Please provide all the correct details!' });
        }
        const s3Bucket = new AWS.S3({
            accessKeyId: process.env.AMAZONACCESSKEYID,
            secretAccessKey: process.env.AMAZONSECRETACCESSKEY,
            Bucket: process.env.AMAZONS3BUCKETNAME
        });
        const file = req.file;
        const file_link = req.body.file_link;
        if (!_.isEmpty(file_link)) {
            const update = new Judgements({
                _id: mongoose.Types.ObjectId(),
                court_name: req.body.court_name,
                title: req.body.title,
                file: file_link,
                year: req.body.year,
                date_of_judgement: req.body.date_of_judgement,
                lang: req.body.lang,
                reference: req.body.reference,
                reference_link: req.body.reference_link,
            });
            const response = await update.save();
            return res.send({ status: "SUCCESS", response })
        }
        if (!_.isEmpty(file)) {
            const params = {
                Bucket: process.env.AMAZONS3BUCKETNAME,
                Key: new Date().toISOString() + "-" + file.originalname,
                Body: file.buffer,
                ContentType: file.mimetype,
                ACL: "public-read"
            }
            s3Bucket.upload(params, async (error, data) => {
                if (error) {
                    return res.send({ status: 'ERROR', message: error.message });
                }
                const jurisdiction = new Judgements({
                    _id: mongoose.Types.ObjectId(),
                    court_name: req.body.court_name,
                    title: req.body.title,
                    file: data.Location,
                    year: req.body.year,
                    date_of_judgement: req.body.date_of_judgement,
                    lang: req.body.lang,
                    reference: req.body.reference,
                    reference_link: req.body.reference_link,
                });
                const response = await jurisdiction.save();
                if (_.isEmpty(response)) {
                    return res.send({ status: 'ERROR', message: 'Something went wrong!' })
                }
                return res.send({ status: 'SUCCESS', response });
            })
        }
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}

exports.fetch_judgements = async (req, res) => {
    try {
        const PAGE_SIZE = 20;
        const searchString = req.query.q;
        const pageNumber = req.query.page ? parseInt(req.query.page) : 1;

        const lang = req.query.lang ? req.query.lang : "en";
        const skip = (pageNumber - 1) * PAGE_SIZE;
        const data = searchString && searchString.length > 0 ? { $and: [{ $or: [{ court_name: { $regex: new RegExp(searchString) } }, { title: { $regex: new RegExp(searchString) } }] }, { lang: lang }] } : { lang: lang };
        const response = req.query.page ? await Judgements.find(data).sort({ date_of_judgement: -1 }).skip(skip).limit(PAGE_SIZE).exec() : await Judgements.find(data).sort({ date_of_judgement: -1 }).exec();
        if (_.isEmpty(response)) {
            return res.send({ status: "NOT_FOUND", message: 'Jurisdiction & law not found' });
        }
        return res.send({ status: 'SUCCESS', response });
    } catch (error) {
        return res.send({ status: 'ERROR', message: error.message });
    }
}