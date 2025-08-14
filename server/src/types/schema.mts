import * as v from "valibot";

const idSchema = v.pipe(v.string(), v.length(15));
const baseCollectionSchema = v.object({
    id: v.string(),
    created: v.optional(v.string()),
    updated: v.optional(v.string()),
});

const userLoginSchema = v.object({
    email: v.pipe(v.string(), v.email()),
    password: v.pipe(v.string(), v.length(64)), // sha256 hex string
});
const userCreationSchema = v.object({
    ...userLoginSchema.entries,
    name: v.pipe(v.string(), v.minLength(3), v.maxLength(20)),
});
const baseUserSchema = v.object({
    ...baseCollectionSchema.entries,
    name: v.string(),
    email: v.string(),
});
const userFriendSchema = v.omit(baseUserSchema, ["id", "email"]);
const userSchema = v.object({
    ...baseUserSchema.entries,
    friends: v.array(userFriendSchema),
});

const appUsageCreationSchema = v.object({
    appName: v.string(),
    duration: v.pipe(v.number(), v.minValue(1)),
    start: v.pipe(v.string(), v.isoDateTime()),
    end: v.pipe(v.string(), v.isoDateTime()),
});
const appUsageSchema = v.object({
    ...baseCollectionSchema.entries,
    appName: v.string(),
    duration: v.number(),
    start: v.string(),
    end: v.string(),
});

const focusCreationSchema = v.object({
    durationTarget: v.pipe(v.number(), v.minValue(1)),
    durationFocus: v.pipe(v.number(), v.minValue(1)),
    durationInterrupted: v.number(),
    start: v.pipe(v.string(), v.isoDateTime()),
    end: v.pipe(v.string(), v.isoDateTime()),
});
const focusSchema = v.object({
    ...baseCollectionSchema.entries,
    durationTarget: v.number(),
    durationFocus: v.number(),
    durationInterrupted: v.number(),
    start: v.string(),
    end: v.string(),
});

const focusTodoCreationSchema = v.object({
    duration: v.pipe(v.number(), v.minValue(1)),
    progressStart: v.number(),
    progressEnd: v.number(),
    todo: idSchema,
    focus: idSchema,
});
const focusTodoSchema = v.object({
    ...baseCollectionSchema.entries,
    duration: v.number(),
    progressStart: v.number(),
    progressEnd: v.number(),
    todo: idSchema,
    focus: idSchema,
});

const todoCreationSchema = v.object({
    title: v.pipe(v.string(), v.minLength(3), v.maxLength(128)),
    category: v.pipe(v.string(), v.maxLength(64)),
    estimation: v.pipe(v.number(), v.minValue(1)),
    active: v.boolean(),
    total: v.pipe(v.number(), v.minValue(1)),
});
const todoSchema = v.object({
    ...baseCollectionSchema.entries,
    title: v.string(),
    category: v.string(),
    estimation: v.number(),
    active: v.boolean(),
    total: v.number(),
    progress: v.number(),
    durationFocus: v.number(),
});


const schemas = {
    auth: {
        login: userLoginSchema,
        result: v.object({
            token: v.string(),
            user: userSchema,
        }),
        refresh: v.object({
            token: v.string(),
            userID: v.string(),
        })
    },
    error: {
        main: v.object({
            code: v.string(),
            message: v.string(),
        }),
    },
    user: {
        creation: userCreationSchema,
        main: userSchema,
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

export default schemas;
