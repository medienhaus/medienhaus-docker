const WebpackConfig = require('./webpack.config.js');

module.exports = {
    publicRuntimeConfig: {
        name: 'medienhaus/spaces',
        authProviders: {
            matrix: {
                baseUrl: 'https://dev.medienhaus.udk-berlin.de',
                allowCustomHomeserver: true,
            },
            matrixContentStorage: {
                baseUrl: 'https://content.udk-berlin.de',
            },
        },
        contextRootSpaceRoomId: '!gzsKJXOMipzIxsoqYk:dev.medienhaus.udk-berlin.de',
        account: {
            allowAddingNewEmails: true,
        },
    },
    webpack: WebpackConfig,
    eslint: {
        ignoreDuringBuilds: true,
    },
};
