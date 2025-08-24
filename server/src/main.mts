import { createExpressEndpoints, initServer } from '@ts-rest/express';
import express from 'express';
import compression from 'compression';
import bodyParser from 'body-parser';
import timeout from 'connect-timeout';
import cors from 'cors';
import 'express-async-errors';
import logger from './services/logging.mjs';
import { contract } from './types/contract.mjs';
import AuthRouteHandler from './routes/auth.mjs';
import FriendsRouteHandler from './routes/friends.mjs';

const app = express();
const PORT = 4132;

app.use(timeout('30s'));
app.use(compression());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use(cors());
app.use((req, res, next) => {
  logger.info(`[server] Receive request from ${req.headers['x-forwarded-for'] ?? req.socket.remoteAddress ?? req.ip}: ${req.method} ${req.path}`);
  logger.debug(JSON.stringify(req.body));
  next();
})

const s = initServer();
createExpressEndpoints(contract, s.router(contract, {
  auth: {
    async register(para) {
      return await new AuthRouteHandler.AuthRegisterHandler().handle(para);
    },
    async login(para) {
      return new AuthRouteHandler.AuthLoginHandler().handle(para);
    },
    async refresh(para) {
      return new AuthRouteHandler.AuthRefreshHandler().handle(para);
    },
  },
  friend: {
    async list(para) {
      return new FriendsRouteHandler.FriendsListHandler().handle(para);
    },
    async request(para) {
      return new FriendsRouteHandler.FriendsRequestHandler().handle(para);
    },
    async approve(para) {
      return new FriendsRouteHandler.FriendsApproveHandler().handle(para);
    },
    async refuse(para) {
      return new FriendsRouteHandler.FriendsRefuseHandler().handle(para);
    },
  },
}), app);
app.listen(PORT, () => {
  logger.info(`[server] Running on http://localhost:${PORT}/`);
});

