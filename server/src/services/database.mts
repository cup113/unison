import PocketBase, { type RecordService } from 'pocketbase';
import z from 'zod';
import schemas, { type Friend } from '../types/schema.mjs';
import type { TypedPocketBase, UsersResponse, FriendsResponse } from '../types/pocketbase-types.js';
import logger from './logging.mjs';

type AuthResult = z.infer<typeof schemas.auth.result>;

export abstract class DatabaseService {
    public abstract auth_register(data: z.infer<typeof schemas.user.creation>): Promise<AuthResult>;
    public abstract auth_login(data: z.infer<typeof schemas.auth.login>): Promise<AuthResult>;
    public abstract auth_refresh(data: z.infer<typeof schemas.auth.refresh>): Promise<AuthResult>;

    public abstract friends_list(userID: string): Promise<Friend[]>;
    public abstract friends_request(data: z.infer<typeof schemas.user.friendRequest>): Promise<void>;
    public abstract friends_approve(friendRelationID: string): Promise<Friend>;
    public abstract friends_refuse(data: z.infer<typeof schemas.user.friendRefuse>): Promise<void>;
}

export class PocketBaseService implements DatabaseService {
    private pb: TypedPocketBase
    private users: RecordService<UsersResponse>;
    private friends: RecordService<FriendsResponse>

    constructor() {
        const POCKETBASE_URL = process.env.POCKETBASE_URL ?? "http://localhost:4133/";
        this.pb = new PocketBase(POCKETBASE_URL);
        this.users = this.pb.collection("users");
        this.friends = this.pb.collection("friends");
    }

    static sanitize(str: string) {
        return str.replace(/\"/g, "");
    }

    public async auth_register(data: z.infer<typeof schemas.user.creation>): Promise<AuthResult> {
        await this.users.create({
            email: data.email,
            name: data.name,
            password: data.password,
            passwordConfirm: data.password,
        });
        return await this.auth_login({
            email: data.email,
            password: data.password,
        });
    }

    public async auth_login(data: z.infer<typeof schemas.auth.login>): Promise<AuthResult> {
        const { token, record } = await this.users.authWithPassword(data.email, data.password);
        return {
            token,
            user: record,
        }
    }

    public async auth_refresh(data: z.infer<typeof schemas.auth.refresh>): Promise<AuthResult> {
        this.pb.authStore.save(data.token);
        const { token, record } = await this.users.authRefresh();
        if (!this.pb.authStore.isValid) {
            throw new Error(`Auth Failed (Invalid Token ${token})`);
        }
        logger.info(`[pocketbase] Auth refresh success for user ${record.username}(id=${record.id})`)
        return {
            token,
            user: record,
        }
    }

    public async friends_list(userID: string): Promise<Friend[]> {
        type Expand1 = FriendsResponse<{ user1: UsersResponse }>;
        type Expand2 = FriendsResponse<{ user2: UsersResponse }>;

        const relations1 = await this.friends.getFullList<Expand1>({
            filter: `user1.id=${userID}`,
            expand: "user1",
        });
        const relations2 = await this.friends.getFullList<Expand2>({
            filter: `user2.id=${userID}`,
            expand: "user2",
        });
        const friendsRaw = [
            ...relations1.map(rel => ({ ...rel.expand.user1, accepted: rel.accepted })),
            ...relations2.map(rel => ({ ...rel.expand.user2, accepted: rel.accepted })),
        ]
        return friendsRaw.map(friend => ({
            id: friend.id,
            created: friend.created,
            updated: friend.updated,
            name: friend.name,
            accepted: friend.accepted,
        }));
    }

    public async friends_request(data: z.infer<typeof schemas.user.friendRequest>): Promise<void> {
        await this.friends.create({
            user1: data.userID,
            user2: data.targetUserID,
            accepted: false,
        });
    }

    public async friends_approve(friendRelationID: string): Promise<Friend> {
        const updatedRelation = await this.friends.update(friendRelationID, {
            accepted: true,
        });

        type Expand = FriendsResponse<{ user1: UsersResponse; user2: UsersResponse }>;
        const relationWithExpand = await this.friends.getOne<Expand>(friendRelationID, {
            expand: "user1,user2",
        });

        const friendData = relationWithExpand.expand.user1.id === updatedRelation.user2
            ? relationWithExpand.expand.user1
            : relationWithExpand.expand.user2;

        return {
            id: friendData.id,
            created: friendData.created,
            updated: friendData.updated,
            name: friendData.name,
            accepted: updatedRelation.accepted,
        };
    }

    public async friends_refuse(data: z.infer<typeof schemas.user.friendRefuse>): Promise<void> {
        await this.friends.update(data.relation, {
            accepted: false,
            refuseReason: data.reason,
        });
    }
}
