const WebpackConfig = require('./webpack.config.js');

module.exports = {
    publicRuntimeConfig: {
        name: '${SPACES_APP_PREFIX}/spaces',
        authProviders: {
            matrix: {
                baseUrl: '${HTTP_SCHEMA}://${MATRIX_BASEURL}',
                allowCustomHomeserver: true,
            },
            etherpad: {
                path: '/write',
                baseUrl: '${HTTP_SCHEMA}://write.${SPACES_HOSTNAME}/p',
                api: '${HTTP_SCHEMA}://write.${SPACES_HOSTNAME}/mypads/api'
            },
            sketch: {
                baseUrl: '${HTTP_SCHEMA}://sketch.${SPACES_HOSTNAME}',
            },
        },
        account: {
            allowAddingNewEmails: false,
        },
        chat: {
            pathToElement: '${HTTP_SCHEMA}://${SPACES_HOSTNAME}/element',
        },
    },
    async rewrites() {
        return [
            {
                source: this.publicRuntimeConfig.authProviders.etherpad.path,
                destination: '/etherpad',
            },
            {
                source: this.publicRuntimeConfig.authProviders.etherpad.path + '/:roomId',
                destination: '/etherpad/:roomId',
            },
        ];
    },
    eslint: {
        ignoreDuringBuilds: true,
    },
    webpack: WebpackConfig,
};

