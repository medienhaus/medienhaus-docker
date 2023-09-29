/**
*  vim:set sw=2 ts=2 sts=2 ft=javascript expandtab:
*
*  # Configuration Module
*
*  ## License
*
*  Licensed to the Apache Software Foundation (ASF) under one
*  or more contributor license agreements.  See the NOTICE file
*  distributed with this work for additional information
*  regarding copyright ownership.  The ASF licenses this file
*  to you under the Apache License, Version 2.0 (the
*  "License"); you may not use this file except in compliance
*  with the License.  You may obtain a copy of the License at
*
*    http://www.apache.org/licenses/LICENSE-2.0
*
*  Unless required by applicable law or agreed to in writing,
*  software distributed under the License is distributed on an
*  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
*  KIND, either express or implied.  See the License for the
*  specific language governing permissions and limitations
*  under the License.
*
*  ## Description
*
*  This is the module for MyPads configuration.
*/

var settings;
try {
  settings = require('ep_etherpad-lite/node/utils/Settings');
}
catch (e) {
  if (process.env.TEST_LDAP) {
    settings = {
      'ep_mypads': {
        'ldap': {
          'url': 'ldap://rroemhild-test-openldap:10389',
          'bindDN': 'cn=admin,dc=planetexpress,dc=com',
          'bindCredentials': 'GoodNewsEveryone',
          'searchBase': 'ou=people,dc=planetexpress,dc=com',
          'searchFilter': '(uid={{username}})',
          'properties': {
            'login': 'uid',
            'email': 'mail',
            'firstname': 'givenName',
            'lastname': 'sn'
          },
          'defaultLang': 'fr'
        }
      }
    };
  } else {
    settings = {};
  }
}
module.exports = (function() {
  'use strict';

  // Dependencies
  var ld      = require('lodash');
  var ldap    = require('ldapjs');
  var storage = require('./storage.js');
  var db      = storage.db;

  var DBPREFIX = storage.DBPREFIX.CONF;

  /**
  * `configuration` object is a closure to interact with the whole
  * config. It will be exported.
  */

  var configuration = {

    /**
    * The object contains a private `DEFAULTS` field, holding defaults
    * settings. Configuration data is taken from the database, applying
    * defaults when necessary, for example at the plugin initialization.
    */

    DEFAULTS: {
      title: 'MyPads',
      rootUrl: '${HTTP_SCHEMA}://etherpad.${SPACES_HOSTNAME}',
      trustProxy: true,
      allowEtherPads: true,
      openRegistration: false,
      hideHelpBlocks: false,
      passwordMin: 8,
      passwordMax: 30,
      languages: { en: 'English', fr: 'Français', de: 'Deutsch', es: 'Español', it: 'Italiano'},
      loginMsg: { en: '', fr: '', de: '', es: '', it: '' },
      defaultLanguage: 'en',
      HTMLExtraHead: `
        <script>
          const searchInterval = window.setInterval(() => {
            if (document.querySelector('main') !== null) {
              window.clearInterval(searchInterval);

              if (document.querySelector('#password-form') !== null) {
                removeAllUnnecessaryObjects()

                restyleCss()

                document.querySelector('#password-form .ok').remove()

                const btn = document.createElement('button')
                btn.innerHTML = "GO"

                btn.addEventListener('click', function (event) {
                  event.preventDefault();
                  checkPasswordInput();
                })

                document.querySelector('#password-form').appendChild(btn)
              }
            }
          }, 100);

          function checkPasswordInput() {
            const padname = window.location.search.split('/').pop()
            const pwd = document.querySelector('#password-form input[type="password"]')
            const pwdB64 = btoa(encodeURIComponent(pwd.value))

            fetch(window.location.protocol + '//' + window.location.host + '/mypads/api/pad/' + padname + '?=&password=' + pwdB64).then(response => {
              if (response.status === 200) {
                window.location.href = window.location.protocol + '//' + window.location.host + '/p/' + padname + '?&mypadspassword=' + pwdB64
              }
            })
          }

          function removeAllUnnecessaryObjects() {
            document.querySelector('header').remove()
            document.querySelector('footer').remove()
            document.querySelector('aside').remove()

            const form = document.querySelector('#password-form')

            form.querySelector('label').remove()
            form.querySelector('input').placeholder = '••••••••••••••••••••••••'
          }

          function restyleCss() {
            const head = document.querySelector('HEAD')

            const styles = head.querySelectorAll('link[rel="stylesheet"]')
            styles.forEach(style => style.remove())

            const link = document.createElement('link')
            link.rel = 'stylesheet'
            link.type = 'text/css'
            link.href = '${HTTP_SCHEMA}://etherpad.${SPACES_HOSTNAME}/static/skins/medienhaus/mypads.css'

            head.appendChild(link);

            const link2 = document.createElement('link')
            link2.rel = 'stylesheet'
            link2.type = 'text/css'
            link2.href = '${HTTP_SCHEMA}://etherpad.${SPACES_HOSTNAME}/static/skins/medienhaus/index.css'

            head.appendChild(link2);
          }
        </script>
      `,
      checkMails: false,
      SMTPPort: undefined,
      SMTPHost: undefined,
      SMTPUser: undefined,
      SMTPPass: undefined,
      SMTPEmailFrom: undefined,
      SMTPSSL: false,
      SMTPTLS: true,
      tokenDuration: 60, // in minutes
      useFirstLastNameInPads: false,
      insensitiveMailMatch: false,
      authMethod: 'ldap',
      availableAuthMethods: [ 'internal', 'ldap', 'cas' ],
      authLdapSettings: {
        url:             '${LDAP_SCHEMA}://${LDAP_HOST}:${LDAP_PORT}',
        bindDN:          '${LDAP_BIND_DN}',
        bindCredentials: '${LDAP_BIND_PASSWORD}',
        searchBase:      '${LDAP_SEARCH_BASE}',
        searchFilter:    '(|(${LDAP_ATTRIBUTE_MAIL}={{mail}})(${LDAP_ATTRIBUTE_UID}={{username}}))',
        tlsOptions: {
          rejectUnauthorized: true
        },
        properties: {
          login:     '${LDAP_ATTRIBUTE_UID}',
          email:     '${LDAP_ATTRIBUTE_MAIL}',
          firstname: '${LDAP_ATTRIBUTE_FIRSTNAME}',
          lastname:  '${LDAP_ATTRIBUTE_LASTNAME}'
        },
        defaultLang: 'en'
      },
      authCasSettings: {
        serverUrl:      'https://cas.example.org/cas',
        protocolVersion: 3.0,
        properties: {
          login:     'login',
          email:     'email',
          firstname: 'firstname',
          lastname:  'lastname'
        },
        defaultLang: 'en'
      },
      allPadsPublicsAuthentifiedOnly: false,
      deleteJobQueue: false
    },

    /**
    * cache object` stored current configuration for faster access than
    * database
    */

    cache: {},

    /**
    * `init` is called when mypads plugin is initialized. It fixes the default
    * data for the configuration into the database and populate the configuration
    * cache.
    * It takes an optional `callback` function used after `db.set` abstraction
    * to return an eventual *error*.
    */

    init: function (callback) {
      callback = callback || function () {};
      if (!ld.isFunction(callback)) {
        throw new TypeError('BACKEND.ERROR.TYPE.CALLBACK_FN');
      }

      var confDefaults = ld.transform(configuration.DEFAULTS,
        function (memo, val, key) { memo[DBPREFIX + key] = val; });

      var initFromDatabase = function () {
        storage.fn.getKeys(ld.keys(confDefaults), function (err, res) {
          if (err) { return callback(err); }

          var pushLdapSettingsToDB = false;
          configuration.cache      = ld.transform(res, function (memo, val, key) {
            key = key.replace(DBPREFIX, '');

            /* get ldap settings from settings.json if exists and database
             * informations are empty */
            if (key === 'authLdapSettings' && ld.isEqual(val, configuration.DEFAULTS.authLdapSettings) &&
                settings.ep_mypads && settings.ep_mypads.ldap) {
              /* json parsing of the settings from settings.json is made by Etherpad,
               * no need to check */
              val                  = settings.ep_mypads.ldap;
              pushLdapSettingsToDB = true;
            }

            if (ld.isUndefined(val)) {
              memo[key] = configuration.DEFAULTS[key];
            } else {
              memo[key] = val;
            }
          });

          if (!pushLdapSettingsToDB) {
            return callback(null);
          }

          /* If DB's LDAP settings are the defaults and settings.json contains
           * LDAP settings, use LDAP auth and put the settings in the database */
          configuration.cache.authMethod = 'ldap';

          var kv   = {
            authLdapSettings: configuration.cache.authLdapSettings,
            authMethod: 'ldap'
          };
          var dbKv = ld.transform(kv,
            function (memo, val, key) { memo[DBPREFIX + key] = val; });

          storage.fn.setKeys(dbKv, callback);
        });
      };

      // Those settings will evolve with MyPads, thus those from MyPads should
      // always be used
      var force   = {
        availableAuthMethods: configuration.DEFAULTS.availableAuthMethods,
        languages: configuration.DEFAULTS.languages
      };
      var dbForce = ld.transform(force,
        function (memo, val, key) { memo[DBPREFIX + key] = val; });

      storage.fn.setKeys(dbForce, function(err) {
        if (err) { return callback(err); }
        // Set the default values in database if they are not already in it
        storage.fn.setKeysIfNotExists(confDefaults, function (err) {
          if (err) { return callback(err); }
          initFromDatabase();
        });
      });
    },

    /**
    * `get` is an synchronous function taking : a mandatory `key` string
    * argument.  It throws *Error* if error, returns *undefined* if key does
    * not exist and the result otherwise.
    */

    get: function (key) {
      if (!ld.isString(key)) {
        throw new TypeError('BACKEND.ERROR.TYPE.KEY_STR');
      }
      return configuration.cache[key];
    },

    /**
    * `set` is an asynchronous function taking two mandatory arguments:
    *
    * - `key` string;
    * - `value`.
    * - `callback` function argument returning *Error* if error, *null*
    *   otherwise
    *
    * `set` sets the `value` for the configuration `key` and takes care of
    * `cache`.
    */

    set: function (key, value, callback) {
      if (!ld.isString(key)) {
        throw new TypeError('BACKEND.ERROR.TYPE.KEY_STR');
      }
      if (ld.isUndefined(value)) {
        throw new TypeError('BACKEND.ERROR.TYPE.VALUE_REQUIRED');
      }
      if (!ld.isFunction(callback)) {
        throw new TypeError('BACKEND.ERROR.TYPE.CALLBACK_FN');
      }
      var dbSet = function(key, value) {
        db.set(DBPREFIX + key, value, function (err) {
          if (err) { return callback(err); }
          configuration.cache[key] = value;
          callback();
        });
      };
      if (key === 'authLdapSettings' || key === 'authCasSettings') {
        delete value.attrs;
      }

      if (key === 'authLdapSettings') {
        /* Test LDAP settings before registering them */
        var ldapErr      = new Error('BACKEND.ERROR.CONFIGURATION.UNABLE_TO_BIND_TO_LDAP');
        var ldapSettings = ld.cloneDeep(value);

        /* Not passed to ldapjs, we don't want to autobind
         * https://github.com/mcavage/node-ldapjs/blob/v1.0.1/lib/client/client.js#L343-L356 */
        delete ldapSettings.bindDN;
        delete ldapSettings.bindCredentials;

        var client = ldap.createClient(ldapSettings);
        client.on('error', function (err) {
          console.error('LDAP settings change: error. See below for details.');
          console.error(err);
          return callback(ldapErr);
        });
        client.bind(value.bindDN, value.bindCredentials, function(err) {
          if (err) {
            console.error(err);
            return callback(ldapErr);
          }
          client.unbind(function(err) {
            client.destroy();
            if (err) {
              console.error(err);
            } else {
              /* Now, we can register new LDAP settings */
              dbSet(key, value);
            }
          });
        });
      } else {
        dbSet(key, value);
      }
    },

    /**
    * `del` is an asynchronous function that removes a configuration option.
    * It takes two mandatory arguments :
    *
    * - a `key` string,
    * - a `callback` function argument returning *Error* if error
    *
    * It takes care of config `cache`.
    */

    del: function (key, callback) {
      if (!ld.isString(key)) {
        throw new TypeError('BACKEND.ERROR.TYPE.KEY_STR');
      }
      if (!ld.isFunction(callback)) {
        throw new TypeError('BACKEND.ERROR.TYPE.CALLBACK_FN');
      }
      db.remove(DBPREFIX + key, function (err) {
        if (err) { return callback(err); }
        delete configuration.cache[key];
        callback();
      });
    },

    /**
    * `all` is a synchronous function that returns the whole configuration
    * from `cache`. Fields / keys are unprefixed.
    */

    all: function () { return configuration.cache; },

    /**
    * `public` is a synchronous function that returns the whole publicly
    * available configuration from `cache`. Fields / keys are unprefixed.
    */

    public: function () {
      var all = configuration.all();
      return ld.pick(all, 'title', 'passwordMin', 'passwordMax', 'languages',
        'HTMLExtraHead', 'openRegistration', 'hideHelpBlocks', 'useFirstLastNameInPads',
        'authMethod', 'authCasSettings', 'allPadsPublicsAuthentifiedOnly', 'defaultLanguage',
        'loginMsg'
      );
    },

    /**
     * `isNotInternalAuth` is a synchronous function that returns true if the
     * authentication method is not `internal`
     */

    isNotInternalAuth: function() {
      return (configuration.get('authMethod') !== 'internal');
    },

    /**
     * `getRootUrl` is a synchronous function that return the real app URL to append to all sub path URI
     * @param {*} req
     */
    getRootUrl: function(req) {
      return configuration.get('trustProxy') ?
        req.protocol + '://' + (req.hostname || req.host) :
        configuration.get('rootUrl');
    }
  };

  return configuration;

}).call(this);
