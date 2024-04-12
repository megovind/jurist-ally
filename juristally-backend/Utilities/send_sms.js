const _ = require('lodash');
const http = require('https');

exports.send_sms = (phone, message) => {
    const options = {
        method: 'POST',
        hostname: 'api.msg91.com',
        port: null,
        path: '/api/v2/sendsms?country=91',
        headers: {
            authKey: process.env.MSG_AUTHKEY,
            'content-type': 'application/json'
        }
    }

    if (process.env.NODE_ENV === 'production') {
        const req = http.request(options, (res) => {
            let chunks = [];
            res.on('data', (chunk) => {
                chunks.push(chunk);
            });
            res.on('end', () => {
                let body = Buffer.concat(chunks);
            });
        });
        req.write(JSON.stringify({
            sender: process.env.MSG_SENDER,
            rooute: '4',
            country: '91',
            unicode: '1',
            sms: [{ message: `${message}`, to: phone }]
        }));

        req.end();
    }
}