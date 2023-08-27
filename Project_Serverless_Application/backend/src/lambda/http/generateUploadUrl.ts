import 'source-map-support/register'

// @ts-ignore
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'
// @ts-ignore
import * as middy from 'middy'
// @ts-ignore
import { cors, httpErrorHandler } from 'middy/middlewares'

// @ts-ignore
import { createAttachmentPresignedUrl } from '../../helpers/todos'
import { getUserId } from '../utils'

export const handler = middy(
  async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const todoId = event.pathParameters.todoId
    const userId = getUserId(event)
    const url = await createAttachmentPresignedUrl(userId, todoId)

    return {
      statusCode: 200,
      body: JSON.stringify({
        "uploadUrl": url
      })
    }
  }
)

handler
  .use(httpErrorHandler())
  .use(
    cors({
      credentials: true
    })
  )
