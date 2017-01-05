var re = /^[A-Za-z\-\/]+?\:\s?[A-Za-z0-9\-\/\=;,|\s]*$/mg,
    url = require('url'),
    spawn = require('child_process').spawn,
    hArray = [];

var merge = function () {
    "use strict";
    var obj = {},
        i = 0,
        il = arguments.length,
        key;
    for (; i < il; i++) {
        for (key in arguments[i]) {
            if (arguments[i].hasOwnProperty(key)) {
                obj[key] = arguments[i][key];
            }
        }
    }
    return obj;
};

function spawnPerlCGI(script, req, env, callback) {
    var script_name = ''
        , returnStr = ''
        , returnErr = ''
        , scriptArr
        , auth
        , header
        , name
        , cp;

    if (script !== '') {
        scriptArr = process.platform === 'win32' ? script.split("\\") : script.split('/');
        script_name = scriptArr.pop();
    }
    if (!env && req) {
        env = merge(process.env,
            {
                GATEWAY_INTERFACE: "CGI/1.1",
                SCRIPT_NAME: script_name,
                SCRIPT_FILENAME: script,
                PATH_INFO: __dirname + '/cgi-bin/',
                SERVER_NAME: req.headers.host.split(':')[0],
                SERVER_PORT: req.headers.host.split(':')[1] || 80,
                SERVER_PROTOCOL: "HTTP/1.1",
                SERVER_SOFTWARE: "Node/" + process.version,
                REQUEST_METHOD: req.method,
            });

        if (req.method === 'GET') {
            env.QUERY_STRING = req.uri || url.parse(req.url).query;
        }

        if (req.method === 'POST') {

            if ('content-length' in req.headers) {
                env.CONTENT_LENGTH = req.headers['content-length'];
            }
            if ('content-type' in req.headers) {
                env.CONTENT_TYPE = req.headers['content-type'];
            }
        }
        
        if ('authorization' in req.headers) {
            auth = req.headers.authorization.split(' ');
            env.AUTH_TYPE = auth[0];
        }

        for (header in req.headers) {

            name = 'HTTP_' + header.toUpperCase().replace(/[^A-Z0-9_]/g, '_');
            env[name] = req.headers[header];
        }
    }

    cp = spawn('perl', [script], {env: env});

    req.pipe(cp.stdin);
    cp.stdout.on('data', function (data) {

        returnStr += data.toString();

    });

    cp.stderr.on("data", function (data) {
        returnErr += data.toString();
    });
    cp.on('exit', function (code) {

        var parts = returnStr.split('\n\n');
        if (parts.length && re.test(parts[0])) {
            hArray = parts.shift().match(re);
        }
        returnStr = parts.join('\n\n');
        return callback(returnErr, returnStr);
    });
}

spawnPerlCGI.prototype.getHeader = function () {
    var objArray = Object.create(null),
        x,
        header;
    for (x in hArray) {
        if (hArray.hasOwnProperty(x) === false) continue;
        header = hArray[x].split(':');
        objArray[header[0]] = header[1].trim();
    }
    return objArray;
}
exports.spawnPerlCGI = spawnPerlCGI;

