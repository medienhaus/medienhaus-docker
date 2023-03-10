const WebpackConfig = require('./webpack.config.js');

module.exports = {
    publicRuntimeConfig: {
        name: '${SPACES_APP_PREFIX}/spaces',
        authProviders: {
            matrix: {
                baseUrl: '${HTTP_SCHEMA}://matrix.${SPACES_HOSTNAME}',
                // api: '${HTTP_SCHEMA}://api.${SPACES_HOSTNAME}',
                allowCustomHomeserver: true,
            },
            // matrixContentStorage: {
            //     baseUrl: '${HTTP_SCHEMA}://matrix.${SPACES_HOSTNAME}',
            // },
            write: {
                baseUrl: '${HTTP_SCHEMA}://write.${SPACES_HOSTNAME}/p',
                api: '${HTTP_SCHEMA}://write.${SPACES_HOSTNAME}/mypads/api'
            },
            sketch: {
                baseUrl: '${HTTP_SCHEMA}://sketch.${SPACES_HOSTNAME}',
            },
        },
        // contextRootSpaceRoomId: '${MATRIX_CONTEXT_ROOT}',
        // account: {
        //     allowAddingNewEmails: true,
        // },
        chat: {
            pathToElement: '${HTTP_SCHEMA}://${SPACES_HOSTNAME}/element',
        },
        // cms: {
        //     path: '${HTTP_SCHEMA}://cms.${SPACES_HOSTNAME}',
        // },
        // activity: {
        //     allowedTemplates: [
        //         'event',
        //         'resource',
        //         'article'
        //     ],
        // },
    },
    eslint: {
        ignoreDuringBuilds: true,
    },
    webpack: WebpackConfig,
};

