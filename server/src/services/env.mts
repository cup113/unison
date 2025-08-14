const env = {
    pocketbaseUrl: process.env.POCKETBASE_URL || 'http://localhost:4133',
    production: process.env.NODE_ENV === 'production',
}

export default env;
