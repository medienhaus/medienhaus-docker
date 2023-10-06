const WebpackConfig = require('./webpack.config.js');

// eslint-disable-next-line no-undef
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
                baseUrl: '${HTTP_SCHEMA}://etherpad.${SPACES_HOSTNAME}/p',
                myPads: {
                    api: '${HTTP_SCHEMA}://etherpad.${SPACES_HOSTNAME}/mypads/api',
                },
            },
            spacedeck: {
                path: '/sketch',
                baseUrl: '${HTTP_SCHEMA}://spacedeck.${SPACES_HOSTNAME}',
            },
        },
        account: {
            allowAddingNewEmails: false,
        },
        chat: {
            pathToElement: '${HTTP_SCHEMA}://${SPACES_HOSTNAME}/element',
        },
        contextRootSpaceRoomId: "${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}",
    },
    rewrites() {
        const rewriteConfig = [];

        if (this.publicRuntimeConfig.authProviders.etherpad) {
            rewriteConfig.push({
                source: this.publicRuntimeConfig.authProviders.etherpad.path,
                destination: '/etherpad',
            },
            {
                source: this.publicRuntimeConfig.authProviders.etherpad.path + '/:roomId',
                destination: '/etherpad/:roomId',
            });
        }

        if (this.publicRuntimeConfig.authProviders.spacedeck) {
            rewriteConfig.push({
                source: this.publicRuntimeConfig.authProviders.spacedeck.path,
                destination: '/spacedeck',
            },
            {
                source: this.publicRuntimeConfig.authProviders.spacedeck.path + '/:roomId',
                destination: '/spacedeck/:roomId',
            });
        }

        return rewriteConfig;
    },
    output: 'standalone',
    webpack: WebpackConfig,
};
