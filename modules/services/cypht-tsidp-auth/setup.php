<?php

/**
 * tsidp_auth module set.
 *
 * Replaces Cypht's login handler/output with one that offers two ways in:
 *
 *   - OIDC against tsidp (idp.olii.nl), for anyone reachable over Tailscale.
 *     tsidp attests a real, cryptographically-verified `email` claim; this
 *     module only ever creates a session for emails present in
 *     TSIDP_USER_MAP, never for "whoever tsidp lets through".
 *   - A local username/password, for LAN access without Tailscale.
 *
 * Both paths terminate in the same place: Hm_Auth_Tsidp::check_credentials(),
 * so both produce an identically-shaped session regardless of entry point.
 *
 * Pairs with USER_CONFIG_TYPE=custom:Hm_User_Config_Plain (also defined in
 * this module set): neither login path yields a password suitable as a
 * decryption key (tsidp gives none at all; the local one shouldn't double as
 * a key either), so per-user settings are stored unencrypted rather than
 * pretending a key derived from one of these paths would mean anything.
 */

if (!defined('DEBUG_MODE')) { die(); }

handler_source('tsidp_auth');
output_source('tsidp_auth');

replace_module('handler', 'login', 'process_tsidp_login');
replace_module('output', 'login', 'tsidp_login');

return array(
    'allowed_get' => array(
        'oidc_login' => FILTER_VALIDATE_BOOLEAN,
        'code' => FILTER_UNSAFE_RAW,
        'state' => FILTER_UNSAFE_RAW,
        'oidc_error' => FILTER_UNSAFE_RAW,
    ),
);
