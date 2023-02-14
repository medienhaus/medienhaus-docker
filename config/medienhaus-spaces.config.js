const WebpackConfig = require('./webpack.config.js');

module.exports = {
    publicRuntimeConfig: {
        name: 'medienhaus/spaces',
        authProviders: {
            matrix: {
                // baseUrl: 'https://matrix.spaces.develop.medienhaus.dev',
                baseUrl: 'https://dev.medienhaus.udk-berlin.de',
                // api: 'https://api.spaces.develop.medienhaus.dev',
                api: 'https://api.dev.medienhaus.udk-berlin.de',
                allowCustomHomeserver: true,
            },
            matrixContentStorage: {
                // baseUrl: 'https://matrix.spaces.develop.medienhaus.dev',
                baseUrl: 'https://content.udk-berlin.de',
            },
            write: {
                baseUrl: 'https://write.spaces.develop.medienhaus.dev/p',
                // baseUrl: 'https://write.udk-berlin.de/p',
                api: 'https://write.spaces.develop.medienhaus.dev/mypads/api'
                // api: 'https://write.udk-berlin.de/mypads/api'
            },
            sketch: {
                baseUrl: 'https://sketch.spaces.develop.medienhaus.dev',
                // baseUrl: 'https://sketch.udk-berlin.de',
            },
        },
        // contextRootSpaceRoomId: '!gzsKJXOMipzIxsoqYk:dev.medienhaus.udk-berlin.de',
        contextRootSpaceRoomId: '!QaqHnSiFKQjzWtdvaV:dev.medienhaus.udk-berlin.de',
        account: {
            allowAddingNewEmails: true,
        },
        chat: {
            pathToElement: '//spaces.develop.medienhaus.dev/element',
        },
        cms: {
            path: 'https://spaces.udk-berlin.de/rundgang/',
        },
        activity: {
            allowedTemplates: [
                'event',
                'resource',
                'article'
            ],
        },
    },
    eslint: {
        ignoreDuringBuilds: true,
    },
    webpack: WebpackConfig,
};

