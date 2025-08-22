import { initContract } from '@ts-rest/core';
import schemas from './schema.mjs';

const c = initContract();

export const authContract = c.router({
  register: {
    method: 'POST',
    path: '/auth/register',
    body: schemas.user.creation,
    responses: {
      200: schemas.auth.result,
      409: schemas.error.main,
    },
  },
  login: {
    method: 'POST',
    path: '/auth/login',
    body: schemas.auth.login,
    responses: {
      200: schemas.auth.result,
      401: schemas.error.main,
    },
  },
  refresh: {
    method: 'POST',
    path: '/auth/refresh',
    headers: schemas.headers.general,
    body: schemas.auth.refresh,
    responses: {
      200: schemas.auth.result,
      401: schemas.error.main,
    },
  },
});

export const userContract = c.router({
});

export const contract = c.router({
  auth: authContract,
});
