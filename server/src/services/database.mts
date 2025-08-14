import PocketBase from 'pocketbase';
import { InferOutput } from 'valibot';
import schemas from '../types/schema.mjs';

type AuthResult = InferOutput<typeof schemas.auth.result>;

abstract class DatabaseService {
    public abstract auth_register(data: InferOutput<typeof schemas.user.creation>): Promise<AuthResult>;
    public abstract auth_login(data: InferOutput<typeof schemas.auth.login>): Promise<AuthResult>;
    public abstract auth_refresh(data: InferOutput<typeof schemas.auth.refresh>): Promise<AuthResult>;
}
