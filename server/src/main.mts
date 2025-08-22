import { createExpressEndpoints, initServer } from '@ts-rest/express';
import express from 'express';
import compression from 'compression';
import bodyParser from 'body-parser';
import timeout from 'connect-timeout';
import 'express-async-errors';
import httpErrors from 'http-errors';
import logger from './services/logging.mjs';
import { contract } from './types/contract.mjs';
import AuthRouteHandler from './routes/auth.mjs';

const app = express();
const PORT = 4132;

app.use(timeout('30s'));
app.use(compression());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
app.use((req, res, next) => {
  next(new httpErrors.NotFound());
});
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
    }
  },
}), app);

app.listen(PORT, () => {
  logger.info(`[server] Running on http://localhost:${PORT}/`);
});
