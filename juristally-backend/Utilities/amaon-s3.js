const _ = require("lodash");
const AWS = require("aws-sdk");

exports.upload_file_to_s3 = (req, res) => {
    const s3bucket = new AWS.S3({
        accessKeyId: process.env.AMAZONACCESSKEYID,
        secretAccessKey: process.env.AMAZONSECRETACCESSKEY,
        Bucket: process.env.AMAZONS3BUCKETNAME
    });
    const file = req.file;
    if (!_.isEmpty(file)) {
        const params = {
            Bucket: process.env.AMAZONS3BUCKETNAME,
            Key: new Date().toISOString() + "-" + file.originalname,
            Body: file.buffer,
            ContentType: file.mimetype,
            ACL: "public-read"
        }
        s3bucket.upload(params, (error, data) => {
            if (error) {
                return res.send({ status: "ERROR", message: error.message });
            }
            res.send({ status: "SUCCESS", response: data });
        })
    } else {
        return res.send({ status: "ERROR", message: "File in empty" })
    }
}

exports.delete_file_from_s3 = (req, res) => {
    const fileUrl = req.body.filename;
    const response = delete_file(fileUrl);
    if (response.status) {
        return res.send({ status: "SUCCESS", message: "File deleted successfully" });
    } else {
        return res.send({ status: "SUCCESS", message: "Check if you have sufficient permissions : " + response.err });
    }
}

const delete_file = (filename) => {
    const s3bucket = new AWS.S3({
        accessKeyId: process.env.AMAZONACCESSKEYID,
        secretAccessKey: process.env.AMAZONSECRETACCESSKEY,
        Bucket: process.env.AMAZONS3BUCKETNAME
    });
    const params = {
        Bucket: process.env.AMAZONS3BUCKETNAME,
        Key: filename
    }
    s3bucket.deleteObject(params, (err, data) => {
        if (data) {
            return json({ status: true });
        } else {
            return json({ status: false, err });
        }
    });
}