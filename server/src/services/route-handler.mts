import { DatabaseService, PocketBaseService } from "./database.mjs";
import logger from "./logging.mjs";
import type { AppRoute, HTTPStatusCode, ServerInferRequest } from "@ts-rest/core";
import z from "zod";
import schemas from "../types/schema.mjs";

export type ImpParameter<R extends AppRoute> = ServerInferRequest<R>;
export type ImpReturnOne<R extends AppRoute, K extends keyof R["responses"]> = {
    status: K,
    body: R["responses"][K] extends z.ZodType ? z.infer<R["responses"][K]> : never;
}
export type ImpReturn<R extends AppRoute> = {
    [K in keyof R["responses"]]: ImpReturnOne<R, K>;
}[keyof R["responses"]];

export default abstract class RouteHandler<R extends AppRoute> {
    static logger: typeof logger = logger;

    protected db: DatabaseService;

    constructor() {
        this.db = new PocketBaseService();
    }

    protected terminate<StatusCode extends HTTPStatusCode>(statusCode: StatusCode, code: string, message: string): {
        status: StatusCode,
        body: z.infer<typeof schemas.error.main>,
    } {
        RouteHandler.logger.info(`[route] User request terminated ${statusCode} ${code}: ${message}`);
        return {
            status: statusCode,
            body: {
                code,
                message,
            }
        };
    }

    protected success(body: ImpReturnOne<R, 200>["body"]): ImpReturn<R> {
        return {
            status: 200,
            body,
        };
    }

    protected async authorize(authorization?: string): Promise<false | z.infer<typeof schemas.auth.result>> {
        if (!authorization) {
            logger.warn(`[auth] No authorization included.`);
            return false;
        }
        const token = authorization.slice("Bearer ".length);
        try {
            const { user, token: tokenNew } = await this.db.auth_refresh({
                token,
            });
            logger.info(`[auth] Success for user ${user.id}/${user.name}`)
            return {
                token: tokenNew,
                user,
            };
        } catch (e) {
            logger.warn(`[auth] Invalid token: ${token}`);
            return false;
        }
    }

    public abstract handle(parameter: ImpParameter<R>): Promise<ImpReturn<R>>;
}
