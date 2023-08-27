import 'source-map-support/register'

// @ts-ignore
import { APIGatewayProxyEvent, APIGatewayProxyResult } from 'aws-lambda'
// @ts-ignore
import * as middy from 'middy'
// @ts-ignore
import { cors } from 'middy/middlewares'

import { getTodosForUser as getTodosForUser } from '../../helpers/todos'
import { getUserId } from '../utils';

export const handler = middy(
  async (event: APIGatewayProxyEvent): Promise<APIGatewayProxyResult> => {
    // Write your code here
    const userId = getUserId(event)
    const todos = await getTodosForUser(userId);

    return {
        statusCode: 200,
        body: JSON.stringify({ //@ts-ignore
          items: todos.todoItems,
        })
    }
})

handler.use(
  cors({
    credentials: true
  })
)
