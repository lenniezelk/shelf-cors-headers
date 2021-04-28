const ACCESS_CONTROL_ALLOW_ORIGIN = 'Access-Control-Allow-Origin';
const ACCESS_CONTROL_EXPOSE_HEADERS = 'Access-Control-Expose-Headers';
const ACCESS_CONTROL_ALLOW_CREDENTIALS = 'Access-Control-Allow-Credentials';
const ACCESS_CONTROL_ALLOW_HEADERS = 'Access-Control-Allow-Headers';
const ACCESS_CONTROL_ALLOW_METHODS = 'Access-Control-Allow-Methods';
const ACCESS_CONTROL_MAX_AGE = 'Access-Control-Max-Age';

const defaultHeadersList = [
  'accept',
  'accept-encoding',
  'authorization',
  'content-type',
  'dnt',
  'origin',
  'user-agent',
];

const defaultMethodsList = ['DELETE', 'GET', 'OPTIONS', 'PATCH', 'POST', 'PUT'];

Map<String, dynamic> defaultHeaders = {
  ACCESS_CONTROL_ALLOW_ORIGIN: '*',
  ACCESS_CONTROL_EXPOSE_HEADERS: '',
  ACCESS_CONTROL_ALLOW_CREDENTIALS: 'true',
  ACCESS_CONTROL_ALLOW_HEADERS: defaultHeadersList.join(','),
  ACCESS_CONTROL_ALLOW_METHODS: defaultMethodsList.join(','),
  ACCESS_CONTROL_MAX_AGE: 86400,
};
