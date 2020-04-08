#!/usr/bin/env bash
set -e

APP_HOST="${APP_HOST:-localhost}"
APP_PROTOCOL="${APP_PROTOCOL:-http}"
# I think this is fine to do because we're not storing any long term session information.
OIDC_CRYPTO_PASS="${OIDC_CRYPTO_PASS:-$(dd if=/dev/urandom count=1 bs=45 | base32)}"
LISTEN_PORT="${LISTEN_PORT:-80}"
AUTH_ENABLED="${AUTH_ENABLED:-yes}"


if [[ "${AUTH_ENABLED}" == "yes" ]]; then
cat << EOF > /usr/local/apache2/conf/site.conf
Listen ${LISTEN_PORT}

<VirtualHost *:${LISTEN_PORT}>
    ErrorDocument 200 "ok"
    RewriteEngine On
    RewriteRule "/fd888239-5bf8-4e6d-a523-f0ca5a34479c/status" - [R=200]

    OIDCProviderMetadataURL https://cognito-idp.${AWS_REGION}.amazonaws.com/${COGNITO_USER_POOL_ID}/.well-known/openid-configuration
    OIDCClientID ${COGNITO_USER_POOL_CLIENT_ID}
    OIDCClientSecret ${COGNITO_USER_POOL_CLIENT_SECRET}
    OIDCRedirectURI /example/redirect_uri
    OIDCCryptoPassphrase "${OIDC_CRYPTO_PASS}"
    OIDCOAuthVerifyJwksUri https://cognito-idp.${AWS_REGION}.amazonaws.com/${COGNITO_USER_POOL_ID}/.well-known/jwks.json

    <Location />
        AuthType oauth20
        <RequireAll>
            Require claim client_id:${COGNITO_USER_POOL_CLIENT_ID}
            Require valid-user
        </RequireAll>

        ProxyPass  "${APP_PROTOCOL}://${APP_HOST}:${APP_PORT}/"
        ProxyPassReverse  "${APP_PROTOCOL}://${APP_HOST}:${APP_PORT}/"
    </Location>
    
</VirtualHost>
EOF
else
cat << EOF > /usr/local/apache2/conf/site.conf
Listen ${LISTEN_PORT}

<VirtualHost *:${LISTEN_PORT}>
    ErrorDocument 200 "ok"
    RewriteEngine On
    RewriteRule "/fd888239-5bf8-4e6d-a523-f0ca5a34479c/status" - [R=200]
    SSLProxyEngine On
    ProxyPass / "${APP_PROTOCOL}://${APP_HOST}:${APP_PORT}/"
    ProxyPassReverse / "${APP_PROTOCOL}://${APP_HOST}:${APP_PORT}/"
</VirtualHost>
EOF
fi

exec httpd-foreground "$@"