import logger from "../services/logging.mjs";
import RouteHandler, { type ImpParameter } from "../services/route-handler.mjs";
import { friendsContract } from "../types/contract.mjs";

type ListType = typeof friendsContract.list;
type RequestType = typeof friendsContract.request;
type ApproveType = typeof friendsContract.approve;
type RefuseType = typeof friendsContract.refuse;

class FriendsListHandler extends RouteHandler<ListType> {
    public async handle({ headers }: ImpParameter<ListType>) {
        if (!await this.authorize(headers.authorization)) {
            return this.terminate(401, "UNAUTHORIZED", "认证失败");
        }

        try {
            const token = headers.authorization.slice("Bearer ".length);
            const { user } = await this.db.auth_refresh({ token });
            const friends = await this.db.friends_list(user.id);
            return this.success(friends);
        } catch (e) {
            logger.warn(e);
            return this.terminate(401, "UNAUTHORIZED", "认证失败");
        }
    }
}

class FriendsRequestHandler extends RouteHandler<RequestType> {
    public async handle({ headers, body }: ImpParameter<RequestType>) {
        const result = await this.authorize(headers.authorization);
        if (!result) {
            return this.terminate(401, "UNAUTHORIZED", "认证失败");
        }

        try {
            await this.db.friends_request({
                ...body,
                userID: result.user.id,
            });
            return this.success({});
        } catch (e) {
            return this.terminate(404, "USER_NOT_FOUND", "用户不存在");
        }
    }
}

class FriendsApproveHandler extends RouteHandler<ApproveType> {
    public async handle({ headers, body }: ImpParameter<ApproveType>) {
        const result = await this.authorize(headers.authorization);
        if (!result) {
            return this.terminate(401, "UNAUTHORIZED", "认证失败");
        }

        try {
            const friend = await this.db.friends_approve(body.id, result.user.id);
            return this.success(friend);
        } catch (e) {
            return this.terminate(404, "RELATION_NOT_FOUND", "好友关系不存在");
        }
    }
}

class FriendsRefuseHandler extends RouteHandler<RefuseType> {
    public async handle({ headers, body }: ImpParameter<RefuseType>) {
        const result = await this.authorize(headers.authorization);
        if (!result) {
            return this.terminate(401, "UNAUTHORIZED", "认证失败");
        }

        try {
            await this.db.friends_refuse(body, result.user.id);
            return this.success({});
        } catch (e) {
            return this.terminate(404, "RELATION_NOT_FOUND", "好友关系不存在");
        }
    }
}

const FriendsRouteHandler = {
    FriendsListHandler,
    FriendsRequestHandler,
    FriendsApproveHandler,
    FriendsRefuseHandler,
};

export default FriendsRouteHandler;
