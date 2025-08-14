import { createExpressEndpoints, initServer } from '@ts-rest/express';
import express from 'express';
import compression from 'compression';
import bodyParser from 'body-parser';
import timeout from 'connect-timeout';
import 'express-async-errors';
import httpErrors from 'http-errors';
import logger from './services/logging.mjs';
import { contract } from './types/contract.mjs';

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
  }
}), app);

app.listen(PORT, () => {
  logger.info(`Server is running on http://localhost:${PORT}/`);
});
