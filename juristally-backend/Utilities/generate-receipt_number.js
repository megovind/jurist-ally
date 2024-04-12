exports.generate_reciept_number = () => {
    const date = new Date();
    const rcptnumber = "JSA-" + date.getDay() + date.getDate() + date.getFullYear().toString().substring(2, 4) + "-" + date.getMilliseconds();
    return rcptnumber;
}