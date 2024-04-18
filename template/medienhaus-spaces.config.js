module.exports = {
    name: '${SPACES_APP_PREFIX}/spaces',
    authProviders: {
        matrix: {
            baseUrl: '${HTTP_SCHEMA}://${MATRIX_BASEURL}',
            allowCustomHomeserver: true,
        },
        etherpad: {
            path: '/write',
            baseUrl: '${HTTP_SCHEMA}://${ETHERPAD_HOSTNAME}/p',
            myPads: {
                api: '${HTTP_SCHEMA}://${ETHERPAD_HOSTNAME}/mypads/api',
            },
        },
        spacedeck: {
            path: '/sketch',
            baseUrl: '${HTTP_SCHEMA}://${SPACEDECK_HOSTNAME}',
        },
        tldraw: {
            path: '/draw',
        },
    },
    account: {
        allowAddingNewEmails: false,
    },
    chat: {
        pathToElement: '${HTTP_SCHEMA}://${SPACES_HOSTNAME}/element',
    },
    contextRootSpaceRoomId: process.env.MEDIENHAUS_ROOT_CONTEXT_SPACE_ID,
    /* @NOTE: clear(!) client-side localStorage if value defined in `versionToken` is */
    /* *not_equal* to value stored in or does *not_exist* in client-side localStorage */
    // localStorage: {
    //   clearAfterUpgrade: true,
    //   versionToken: "1",
    // },
    templates: {
        // context: [
        //   "context",
        // ],
        item: [
            'etherpad',
            // 'spacedeck',
            // 'tldraw',
            'link',
        ],
    },
};
