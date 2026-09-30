<?php

if (!defined('DEBUG_MODE')) { die(); }

/* ---------------------------------------------------------------------
 * Small stateless-token helpers.
 *
 * Both the OAuth "state" param and the hand-off from the OIDC callback to
 * Hm_Auth_Tsidp::check_credentials() use the same signed-token shape:
 * base64url(json) + '.' + base64url(hmac_sha256(json, secret . context)).
 * The context string domain-separates the two uses so a state token can
 * never be replayed as an internal-login token or vice versa.
 * ------------------------------------------------------------------- */

if (!hm_exists('tsidp_b64url_encode')) {
function tsidp_b64url_encode($str) {
    return rtrim(strtr(base64_encode($str), '+/', '-_'), '=');
}}

if (!hm_exists('tsidp_b64url_decode')) {
function tsidp_b64url_decode($str) {
    return base64_decode(strtr($str, '-_', '+/').str_repeat('=', (4 - strlen($str) % 4) % 4));
}}

if (!hm_exists('tsidp_auth_secret')) {
function tsidp_auth_secret() {
    static $secret = null;
    if ($secret === null) {
        $path = env('TSIDP_AUTH_SECRET_FILE', '');
        $secret = ($path && is_readable($path)) ? trim(file_get_contents($path)) : '';
    }
    return $secret;
}}

if (!hm_exists('tsidp_sign_token')) {
function tsidp_sign_token($payload, $context) {
    $secret = tsidp_auth_secret();
    if (!$secret) {
        return false;
    }
    $body = tsidp_b64url_encode(json_encode($payload));
    $sig = tsidp_b64url_encode(hash_hmac('sha256', $body, $context.$secret, true));
    return $body.'.'.$sig;
}}

if (!hm_exists('tsidp_verify_token')) {
function tsidp_verify_token($token, $context, $max_age) {
    $secret = tsidp_auth_secret();
    if (!$secret || !is_string($token) || substr_count($token, '.') !== 1) {
        return false;
    }
    list($body, $sig) = explode('.', $token, 2);
    $expected = tsidp_b64url_encode(hash_hmac('sha256', $body, $context.$secret, true));
    if (!hash_equals($expected, $sig)) {
        return false;
    }
    $payload = json_decode(tsidp_b64url_decode($body), true);
    if (!is_array($payload) || !array_key_exists('t', $payload) || (time() - $payload['t']) > $max_age) {
        return false;
    }
    return $payload;
}}

/* ---------------------------------------------------------------------
 * Minimal RS256 JWT verification (id_token only; access/refresh tokens
 * are opaque to this module and never inspected).
 * ------------------------------------------------------------------- */

if (!hm_exists('tsidp_jwk_to_pem')) {
function tsidp_jwk_to_pem($jwk) {
    if (($jwk['kty'] ?? '') !== 'RSA' || empty($jwk['n']) || empty($jwk['e'])) {
        return false;
    }
    $n = tsidp_b64url_decode($jwk['n']);
    $e = tsidp_b64url_decode($jwk['e']);

    $encode_len = function ($len) {
        if ($len <= 0x7f) {
            return chr($len);
        }
        $bytes = ltrim(pack('N', $len), "\x00");
        return chr(0x80 | strlen($bytes)).$bytes;
    };
    $encode_int = function ($bin) use ($encode_len) {
        if (ord($bin[0]) > 0x7f) {
            $bin = "\x00".$bin;
        }
        return "\x02".$encode_len(strlen($bin)).$bin;
    };

    $modulus = $encode_int($n);
    $exponent = $encode_int($e);
    $sequence = $modulus.$exponent;
    $rsa_pub_key = "\x30".$encode_len(strlen($sequence)).$sequence;

    /* RSAPublicKey wrapped in a SubjectPublicKeyInfo (rsaEncryption OID) */
    $rsa_oid = pack('H*', '300d06092a864886f70d0101010500');
    $bit_string = "\x00".$rsa_pub_key;
    $bit_string = "\x03".$encode_len(strlen($bit_string)).$bit_string;
    $spki = $rsa_oid.$bit_string;
    $der = "\x30".$encode_len(strlen($spki)).$spki;

    return "-----BEGIN PUBLIC KEY-----\n".chunk_split(base64_encode($der), 64)."-----END PUBLIC KEY-----\n";
}}

if (!hm_exists('tsidp_verify_id_token')) {
function tsidp_verify_id_token($jwt, $jwks, $issuer, $audience) {
    $parts = explode('.', $jwt);
    if (count($parts) !== 3) {
        return false;
    }
    list($b64_header, $b64_payload, $b64_sig) = $parts;
    $header = json_decode(tsidp_b64url_decode($b64_header), true);
    $payload = json_decode(tsidp_b64url_decode($b64_payload), true);
    $sig = tsidp_b64url_decode($b64_sig);
    if (!is_array($header) || !is_array($payload) || ($header['alg'] ?? '') !== 'RS256') {
        return false;
    }
    $key = null;
    foreach (($jwks['keys'] ?? []) as $candidate) {
        if (($candidate['kid'] ?? null) === ($header['kid'] ?? null)) {
            $key = $candidate;
            break;
        }
    }
    if (!$key) {
        return false;
    }
    $pem = tsidp_jwk_to_pem($key);
    if (!$pem) {
        return false;
    }
    $pubkey = openssl_pkey_get_public($pem);
    if (!$pubkey) {
        return false;
    }
    $verified = openssl_verify($b64_header.'.'.$b64_payload, $sig, $pubkey, OPENSSL_ALGO_SHA256);
    if ($verified !== 1) {
        return false;
    }
    if (($payload['iss'] ?? null) !== $issuer) {
        return false;
    }
    $aud = $payload['aud'] ?? null;
    if ($aud !== $audience && !(is_array($aud) && in_array($audience, $aud, true))) {
        return false;
    }
    if (!array_key_exists('exp', $payload) || time() >= $payload['exp']) {
        return false;
    }
    return $payload;
}}

/* ---------------------------------------------------------------------
 * OIDC discovery / JWKS, fetched fresh each login (infrequent, low
 * traffic; not worth a cache for this deployment size).
 * ------------------------------------------------------------------- */

if (!hm_exists('tsidp_fetch_json')) {
function tsidp_fetch_json($url) {
    $api = new Hm_API_Curl();
    $res = $api->command($url, ['Accept: application/json']);
    return is_array($res) ? $res : false;
}}

/**
 * @subpackage tsidp_auth/auth
 */
class Hm_Auth_Tsidp extends Hm_Auth {

    /**
     * @param string $user username
     * @param string $pass either a signed internal-login token minted by
     *   Hm_Handler_process_tsidp_login after a verified OIDC callback, or a
     *   plaintext password for the local (LAN) fallback account.
     * @return bool
     */
    public function check_credentials($user, $pass) {
        $claim = tsidp_verify_token($pass, 'internal-login', 60);
        if ($claim && ($claim['u'] ?? null) === $user) {
            return true;
        }
        return $this->check_local_password($user, $pass);
    }

    private function check_local_password($user, $pass) {
        $path = env('TSIDP_LOCAL_USERS_FILE', '');
        if (!$path || !is_readable($path)) {
            return false;
        }
        $users = json_decode(file_get_contents($path), true);
        if (!is_array($users) || !array_key_exists($user, $users)) {
            sleep(2);
            return false;
        }
        if (password_verify($pass, $users[$user])) {
            return true;
        }
        sleep(2);
        return false;
    }
}

/**
 * @subpackage tsidp_auth/handler
 */
class Hm_Handler_process_tsidp_login extends Hm_Handler_login {

    public function process() {
        if (!empty($this->request->get['oidc_login'])) {
            $this->start_oidc();
            return;
        }
        if (array_key_exists('code', $this->request->get) && array_key_exists('state', $this->request->get)) {
            $this->finish_oidc();
        }
        parent::process();
    }

    private function oidc_redirect_uri() {
        $scheme = (!empty($this->request->server['HTTPS']) && $this->request->server['HTTPS'] !== 'off') ? 'https' : 'http';
        $host = $this->request->server['HTTP_HOST'] ?? '';
        return sprintf('%s://%s/?page=login', $scheme, $host);
    }

    private function start_oidc() {
        $discovery_url = env('TSIDP_DISCOVERY_URL', '');
        $client_id = env('TSIDP_CLIENT_ID', '');
        if (!$discovery_url || !$client_id) {
            Hm_Msgs::add('tsidp login is not configured', 'danger');
            return;
        }
        $discovery = tsidp_fetch_json($discovery_url);
        if (!$discovery || empty($discovery['authorization_endpoint'])) {
            Hm_Msgs::add('Could not reach tsidp', 'danger');
            return;
        }
        $state = tsidp_sign_token(['t' => time()], 'oidc-state');
        $url = $discovery['authorization_endpoint'].'?'.http_build_query([
            'response_type' => 'code',
            'client_id' => $client_id,
            'redirect_uri' => $this->oidc_redirect_uri(),
            'scope' => 'openid email',
            'state' => $state,
        ]);
        $this->out('redirect_url', $url);
    }

    private function finish_oidc() {
        $state = tsidp_verify_token($this->request->get['state'], 'oidc-state', 300);
        if (!$state) {
            Hm_Msgs::add('Login link expired, please try again', 'warning');
            return;
        }

        $discovery_url = env('TSIDP_DISCOVERY_URL', '');
        $client_id = env('TSIDP_CLIENT_ID', '');
        $client_secret_path = env('TSIDP_CLIENT_SECRET_FILE', '');
        $client_secret = ($client_secret_path && is_readable($client_secret_path)) ? trim(file_get_contents($client_secret_path)) : '';
        $discovery = $discovery_url ? tsidp_fetch_json($discovery_url) : false;
        if (!$discovery || !$client_id || !$client_secret) {
            Hm_Msgs::add('tsidp login is not configured', 'danger');
            return;
        }

        $oauth = new Hm_Oauth2($client_id, $client_secret, $this->oidc_redirect_uri());
        $token_res = $oauth->request_token($discovery['token_endpoint'], $this->request->get['code']);
        if (empty($token_res['id_token'])) {
            Hm_Msgs::add('tsidp login failed', 'danger');
            return;
        }

        $jwks = tsidp_fetch_json($discovery['jwks_uri']);
        $claims = $jwks ? tsidp_verify_id_token($token_res['id_token'], $jwks, $discovery['issuer'], $client_id) : false;
        if (!$claims || empty($claims['email'])) {
            Hm_Msgs::add('tsidp login failed', 'danger');
            return;
        }

        $user_map = json_decode(env('TSIDP_USER_MAP', '{}'), true);
        $username = is_array($user_map) ? ($user_map[$claims['email']] ?? false) : false;
        if (!$username) {
            Hm_Debug::add(sprintf('tsidp login: %s is not a mapped user', $claims['email']));
            Hm_Msgs::add('That tsidp identity is not authorized for this mailbox', 'danger');
            return;
        }

        /* Hand off to the normal login path: inject synthetic form fields so
         * every other handler in the pipeline (notably load_user_data, which
         * re-reads username/password off the request independently) sees a
         * consistent, successful login on this same request. */
        $internal_token = tsidp_sign_token(['u' => $username, 't' => time()], 'internal-login');
        $this->request->post['username'] = $username;
        $this->request->post['password'] = $internal_token;
    }
}

/**
 * @subpackage tsidp_auth/output
 */
class Hm_Output_tsidp_login extends Hm_Output_Module {
    protected function output() {
        if ($this->get('is_logged')) {
            return '';
        }
        $error = $this->get('oidc_error', '');
        $res = '<div class="tsidp_login_outer" style="max-width:340px;margin:10vh auto 0;font-family:sans-serif;">';
        if ($error) {
            $res .= '<p style="color:#b00;">'.$this->html_safe($error).'</p>';
        }
        $res .= '<a href="?page=login&oidc_login=1" style="display:block;text-align:center;padding:0.6em;'.
            'margin-bottom:1em;background:#6eb549;color:#fff;text-decoration:none;border-radius:4px;">'.
            $this->trans('Login with olii.nl').'</a>'.
            '<p style="text-align:center;color:#888;">'.$this->trans('or').'</p>'.
            '<form method="POST">'.
                '<input type="hidden" name="hm_page_key" value="'.Hm_Request_Key::generate().'" />'.
                '<div style="margin-bottom:0.5em;">'.
                    '<label for="username">'.$this->trans('Username').'</label><br />'.
                    '<input autofocus required type="text" id="username" name="username" style="width:100%;">'.
                '</div>'.
                '<div style="margin-bottom:0.5em;">'.
                    '<label for="password">'.$this->trans('Password').'</label><br />'.
                    '<input required type="password" id="password" name="password" style="width:100%;">'.
                '</div>'.
                '<input type="submit" id="login" value="'.$this->trans('Login').'" style="width:100%;padding:0.5em;">'.
            '</form>'.
        '</div>';
        return $res;
    }
}

/* ---------------------------------------------------------------------
 * Unencrypted per-user settings storage. Neither login path above yields
 * a password suitable as a decryption key, so this stores plain JSON
 * instead of pretending otherwise. Structurally identical to
 * Hm_User_Config_File, minus the crypto.
 * ------------------------------------------------------------------- */

class Hm_User_Config_Plain extends Hm_Config {

    private $site_config;
    private $username;

    public function __construct($config) {
        $this->site_config = $config;
        $this->config = array_merge($this->config, $config->user_defaults);
    }

    public function get_path($username) {
        $path = $this->site_config->get('user_settings_dir', false);
        return sprintf('%s/%s.txt', $path, $username);
    }

    public function load($username, $key) {
        $this->username = $username;
        $source = $this->get_path($username);
        if (is_readable($source)) {
            $str_data = file_get_contents($source);
            if ($str_data) {
                $data = $this->decode($str_data);
                if (is_array($data)) {
                    $this->config = array_merge($this->config, $data);
                    $this->set_tz();
                }
            }
        }
    }

    public function reload($data, $username = false) {
        $this->username = $username;
        $this->config = $data;
        $this->set_tz();
    }

    public function save($username, $key) {
        $this->shuffle();
        $destination = $this->get_path($username);
        $folder = dirname($destination);
        if (!is_dir($folder)) {
            throw new Exception('"Users" folder doesn\'t exist, please contact your site administrator.');
        }
        $this->filter_servers();
        $result = file_put_contents($destination, json_encode($this->config));
        if ($result === false) {
            throw new Exception('Unable to write user config data - please check Cypht setup.');
        }
    }

    public function set($name, $value) {
        $this->config[$name] = $value;
        $this->save($this->username, false);
    }
}
