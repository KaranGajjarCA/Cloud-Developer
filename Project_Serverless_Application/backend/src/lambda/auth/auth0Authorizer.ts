// @ts-ignore
import { CustomAuthorizerEvent, CustomAuthorizerResult } from 'aws-lambda'
import 'source-map-support/register'

// @ts-ignore
import { verify, decode } from 'jsonwebtoken'
import { createLogger } from '../../utils/logger'
// @ts-ignore
import Axios from 'axios'
import { Jwt } from '../../auth/Jwt'
import { JwtPayload } from '../../auth/JwtPayload'

const logger = createLogger('auth')

// to verify JWT token signature.
// To get this URL you need to go to an Auth0 page -> Show Advanced Settings -> Endpoints -> JSON Web Key Set
const jwksUrl = 'https://dev-kefaaohazhomyz2b.us.auth0.com/.well-known/jwks.json'

export const handler = async (
  event: CustomAuthorizerEvent
): Promise<CustomAuthorizerResult> => {
  logger.info('Authorizing a user', event.authorizationToken)
  try {
    const jwtToken = await verifyToken(event.authorizationToken)
    logger.info('User was authorized', jwtToken)

    return {
      principalId: jwtToken.sub,
      policyDocument: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'execute-api:Invoke',
            Effect: 'Allow',
            Resource: '*'
          }
        ]
      }
    }
  } catch (e) {
    logger.error('User not authorized', { error: e.message })

    return {
      principalId: 'user',
      policyDocument: {
        Version: '2012-10-17',
        Statement: [
          {
            Action: 'execute-api:Invoke',
            Effect: 'Deny',
            Resource: '*'
          }
        ]
      }
    }
  }
}

function certToPEM(cert) {
  cert = cert.match(/.{1,64}/g).join('\n');
  cert = `-----BEGIN CERTIFICATE-----\n${cert}\n-----END CERTIFICATE-----\n`;
  return cert;
}

function getsigningKey(jwt, jwks):any{
  const signingKey = jwks.filter(key => key.use === 'sig'
    && key.kty === 'RSA'
    && key.kid && key.kid === jwt.header.kid
    && ((key.x5c && key.x5c.length) || (key.n && key.e))
  ).map(key => {
    return certToPEM(key.x5c[0])
  })
  // if (!signingKeys.length) {
  //     throw new Error('The JWKS endpoint did not contain any signature verification keys');
  // }
  // logger.info('User JWT KID', {jwt_kid:jwt.header.kid})
  // const signingKey = signingKeys.find(key => key.kid === jwt.header.kid)
  if (!signingKey) {
    throw new Error('Unable to find a signing key that matches');
  }
  return signingKey
}

// @ts-ignore
async function verifyToken(authHeader: string): Promise<JwtPayload> {
  const token = getToken(authHeader)
  const jwt: Jwt = decode(token, { complete: true }) as Jwt
  logger.info('User Token', {token:token})
  // You should implement it similarly to how it was implemented for the exercise for the lesson 5
  // You can read more about how to do this here: https://auth0.com/blog/navigating-rs256-and-jwks/
  const jwk_response = await Axios.get(jwksUrl)
  var jwks = jwk_response.data['keys'];
  logger.info('User JWKS Keys', {jwks:jwks})
  const signingKey = getsigningKey(jwt, jwks)
  logger.info('User signingKey', {signingKey:signingKey[0]})
  return verify(token, signingKey[0], {
    algorithms: ['RS256']
  }) as JwtPayload
}

function getToken(authHeader: string): string {
  if (!authHeader) throw new Error('No authentication header')

  if (!authHeader.toLowerCase().startsWith('bearer '))
    throw new Error('Invalid authentication header')

  const split = authHeader.split(' ')
  const token = split[1]

  return token
}
