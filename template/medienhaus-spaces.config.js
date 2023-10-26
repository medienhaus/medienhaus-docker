module.exports = {
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
    contextRootSpaceRoomId: process.env.MEDIENHAUS_ROOT_CONTEXT_SPACE_ID,
};
