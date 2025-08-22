import RouteHandler, { type ImpParameter } from "../services/route-handler.mjs";
import { authContract } from "../types/contract.mjs";

type RegisterType = typeof authContract.register;
type LoginType = typeof authContract.login;
type RefreshType = typeof authContract.refresh;

class AuthRegisterHandler extends RouteHandler<RegisterType> {
    public async handle({ body }: ImpParameter<RegisterType>) {
        try {
            return this.success(await this.db.auth_register(body));
        } catch (e) {
            return this.terminate(409, "USER_EXISTS", "用户名或邮箱已被使用"); // TODO preciser
        }
    }
}

class AuthLoginHandler extends RouteHandler<LoginType> {
    public async handle({ body }: ImpParameter<LoginType>) {
        try {
            return this.success(await this.db.auth_login(body));
        } catch (e) {
            return this.terminate(401, "INVALID_LOGIN_CREDENTIALS", "用户名或密码错误。");
        }
    }
}

class AuthRefreshHandler extends RouteHandler<RefreshType> {
    public async handle({ body }: ImpParameter<RefreshType>) {
        try {
            return this.success(await this.db.auth_refresh(body));
        } catch (e) {
            return this.terminate(401, 'TOKEN_EXPIRED', "认证已过期，请重新登录");
        }
    }
}

const AuthRouteHandler = {
    AuthRegisterHandler,
    AuthLoginHandler,
    AuthRefreshHandler,
};

export default AuthRouteHandler;
