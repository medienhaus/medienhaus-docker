const WebpackConfig = require('./webpack.config.js');

module.exports = {
    publicRuntimeConfig: {
        name: '${SPACES_APP_PREFIX}/spaces',
        authProviders: {
            matrix: {
                baseUrl: '${HTTP_SCHEMA}://${MATRIX_BASEURL}',
                allowCustomHomeserver: true,
            },
            write: {
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
    eslint: {
        ignoreDuringBuilds: true,
    },
    webpack: WebpackConfig,
};

