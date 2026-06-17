const http = require('http');
const data = JSON.stringify({email:'3389716868@qq.com', password:'boss8888'});
const req = http.request({
  hostname: '127.0.0.1',
  port: 3100,
  path: '/api/auth/login',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(data)
  }
}, res => {
  let body = '';
  res.on('data', c => body += c);
  res.on('end', () => {
    console.log('Status:', res.statusCode);
    console.log('Response:', body);
    const parsed = JSON.parse(body);
    if (parsed.token) {
      console.log('TOKEN_OK');
    } else {
      console.log('LOGIN_FAILED:', parsed.error);
    }
  });
});
req.write(data);
req.end();
