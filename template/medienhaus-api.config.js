/* eslint-disable import/no-anonymous-default-export */
export default () => ({
  matrix: {
    homeserver_base_url: 'http://matrix-synapse:8008',
    user_id: '@${MEDIENHAUS_ADMIN_USER_ID}:${MATRIX_SERVERNAME}',
    access_token: '${MEDIENHAUS_ADMIN_ACCESS_TOKEN}',
    root_context_space_id: '${MEDIENHAUS_ROOT_CONTEXT_SPACE_ID}'
  },
  fetch: {
    depth: 500,
    max: 10000,
    interval: 60,
    autoFetch: true,
    dump: true,
    initalyLoad: true,
    noLog: true
  },
  interfaces: {
    rest_v1: true,
    rest_v2: true,
    graphql: true,
    graphql_playground: true,
    post: true
  },
  application: {
    name: 'medienhaus',
    api_name: 'medienhaus-api',
    standards: [
      {
        name: 'dev.medienhaus.meta',
        version: '1.1'
      },
      {
        name: 'dev.medienhaus.allocation',
        version: '0.1'
      },
      {
        name: 'dev.medienhaus.order',
        version: '0.1'
      }
    ]
  },
  attributable: {
    spaceTypes: {
      item: [
        'item',
        'article'
      ],
      context: [
        'context',
	'category'
      ],
      content: [
        'lang',
        'headline',
        'text',
        'ul',
        'ol',
        'quote'
      ]
    }
  }
})
