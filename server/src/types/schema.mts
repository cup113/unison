import z from "zod";

const idSchema = z.string().length(15);
const baseCollectionSchema = z.object({
    id: z.string(),
    created: z.string().optional(),
    updated: z.string().optional(),
});

const userLoginSchema = z.object({
    email: z.string().email(),
    password: z.string().length(64), // sha256 hex string
});
const userCreationSchema = userLoginSchema.extend({
    name: z.string().min(3).max(20),
});
const baseUserSchema = baseCollectionSchema.extend({
    name: z.string(),
    email: z.string(),
});
const userFriendSchema = baseUserSchema
    .omit({ email: true })
    .extend({ accepted: z.boolean() });
const userSchema = baseUserSchema.extend({});
const userFriendRequestSchema = z.object({
    userID: idSchema,
    targetUserID: idSchema,
});
const userFriendRefuseSchema = z.object({
    relation: idSchema,
    reason: z.string().max(256),
})

const appUsageCreationSchema = z.object({
    appName: z.string(),
    duration: z.number().min(1),
    start: z.string().datetime(),
    end: z.string().datetime(),
});
const appUsageSchema = baseCollectionSchema.extend({
    appName: z.string(),
    duration: z.number(),
    start: z.string(),
    end: z.string(),
});

const focusCreationSchema = z.object({
    durationTarget: z.number().min(1),
    durationInterrupted: z.number(),
    start: z.string().datetime(),
    end: z.string().datetime(),
});
const focusSchema = baseCollectionSchema.extend({
    durationTarget: z.number(),
    durationFocus: z.number(),
    durationInterrupted: z.number(),
    start: z.string(),
    end: z.string(),
});

const focusTodoCreationSchema = z.object({
    duration: z.number().min(1),
    progressStart: z.number(),
    progressEnd: z.number(),
    todo: idSchema,
    focus: idSchema,
});
const focusTodoSchema = baseCollectionSchema.extend({
    duration: z.number(),
    progressStart: z.number(),
    progressEnd: z.number(),
    todo: idSchema,
    focus: idSchema,
});

const todoCreationSchema = z.object({
    title: z.string().min(1).max(128),
    category: z.string().max(64),
    estimation: z.number().min(1),
    active: z.boolean(),
    total: z.number().min(1),
});
const todoSchema = baseCollectionSchema.extend({
    title: z.string(),
    category: z.string(),
    estimation: z.number(),
    active: z.boolean(),
    total: z.number(),
    progress: z.number(),
    durationFocus: z.number(),
});


const schemas = {
    auth: {
        login: userLoginSchema,
        result: z.object({
            token: z.string(),
            user: userSchema,
        }),
        refresh: z.object({
            token: z.string(),
        })
    },
    headers: {
        general: z.object({
            authorization: z.string().startsWith("Bearer "),
        }),
    },
    error: {
        main: z.object({
            code: z.string(),
            message: z.string(),
        }),
        unknown: z.object({
            code: z.literal("UNKNOWN"),
            message: z.string(),
        })
    },
    user: {
        creation: userCreationSchema,
        friends: z.array(userFriendSchema),
        friendRequest: userFriendRequestSchema,
        friendRefuse: userFriendRefuseSchema,
    },
    appUsage: {
        creation: appUsageCreationSchema,
        main: appUsageSchema,
    },
    focus: {
        creation: focusCreationSchema,
        main: focusSchema,
    },
    focusTodo: {
        creation: focusTodoCreationSchema,
        main: focusTodoSchema,
    },
    todo: {
        creation: todoCreationSchema,
        main: todoSchema,
    },
};

export type Friend = z.infer<typeof userFriendSchema>;

export default schemas;
