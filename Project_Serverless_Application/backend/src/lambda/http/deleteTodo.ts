import 'source-map-support/register'

// @ts-ignore
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'
// @ts-ignore
import * as middy from 'middy'
// @ts-ignore
import { cors, httpErrorHandler } from 'middy/middlewares'
import { createLogger } from '../../utils/logger'

// @ts-ignore
import { deleteTodo } from '../../helpers/todos'
import { getUserId } from '../utils'


const logger = createLogger('auth')

export const handler = middy(
  async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    const todoId = event.pathParameters.todoId
    const userId = getUserId(event)
    await deleteTodo(userId, todoId)
    logger.info('Todo Deleted', {
        userId: userId,
        todoId: todoId
    })
    return {
        statusCode: 200,
        body: 'Todo Deleted'
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
