var exec = require("cordova/exec");

exports.sayHello = function (arg0, success, error) {
  exec(success, error, "CordovaHelloWorld", "sayHello", [arg0]);
};

exports.enable = function (success, error) {
  exec(success, error, "CordovaHelloWorld", "enable");
};

exports.disable = function (success, error) {
  exec(success, error, "CordovaHelloWorld", "disable");
};
