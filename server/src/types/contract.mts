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

export const friendsContract = c.router({
  list: {
    method: 'GET',
    path: '/friends/list',
    headers: schemas.headers.general,
    responses: {
      200: schemas.user.friends,
      401: schemas.error.main,
    },
  },
  request: {
    method: 'POST',
    path: '/friends/request',
    headers: schemas.headers.general,
    body: schemas.user.friendRequestRaw,
    responses: {
      200: schemas.response.empty,
      401: schemas.error.main,
      404: schemas.error.main,
    },
  },
  approve: {
    method: 'POST',
    path: '/friends/approve',
    headers: schemas.headers.general,
    body: schemas.user.friendApprove,
    responses: {
      200: schemas.user.friend,
      401: schemas.error.main,
      404: schemas.error.main,
    },
  },
  refuse: {
    method: 'POST',
    path: '/friends/refuse',
    headers: schemas.headers.general,
    body: schemas.user.friendRefuse,
    responses: {
      200: schemas.response.empty,
      401: schemas.error.main,
      404: schemas.error.main,
    }
  },
});

export const contract = c.router({
  auth: authContract,
  friend: friendsContract,
});
