// @ts-ignore
import * as AWS from 'aws-sdk'
// @ts-ignore
import * as AWSXRay from 'aws-xray-sdk'
// @ts-ignore
import { DocumentClient } from 'aws-sdk/clients/dynamodb'
import { createLogger } from '../utils/logger'
import { TodoItem } from '../models/TodoItem'
import { TodoUpdate } from '../models/TodoUpdate';


const logger = createLogger('TodosAccess')

export class TodosAccess {
    private static docClient: DocumentClient = new AWS.DynamoDB.DocumentClient();
    // @ts-ignore
    private static todosTable = process.env.TODOS_TABLE;
    // @ts-ignore
    private static userIdIndex = process.env.USER_ID_INDEX;

    static async createTodo(newItem: TodoItem): Promise<TodoItem> {
        logger.info('Create todoAccess')
        await this.docClient.put({
          TableName: this.todosTable,
          Item: newItem
        }).promise()

        return newItem
    }

    static async deleteTodo(userId: string, todoId: string) {
        logger.info('delete todoAccess')
        await this.docClient.delete({
          TableName: this.todosTable,
          Key: { userId, todoId }
        }).promise()
    }

    static async getTodo(userId: string, todoId: string): Promise<TodoItem> {
        const result = await this.docClient
          .get({
            TableName: this.todosTable,
            Key: { userId, todoId }
          })
          .promise()

        return result.Item as TodoItem
    }

    static async updateAttachment(userId: string, todoId: string): Promise<void> {
        await this.docClient.update({
          TableName: this.todosTable,
          Key: { userId, todoId },
          UpdateExpression: "set attachmentUrl=:a",
          ExpressionAttributeValues: {
            ":a": todoId
          },
          ReturnValues: "NONE"
        }).promise()
    }
    static async getTodosForUser(userId: string): Promise<object> {

    const result = await this.docClient.query({
      TableName: this.todosTable,
      IndexName: this.userIdIndex,
      KeyConditionExpression: 'userId = :userId',
      ExpressionAttributeValues: {
        ':userId': userId
      },
      ScanIndexForward: false,
    }).promise()

    const items = result.Items as TodoItem[]
    return { todoItems: items }
  }
  static async updateTodo(userId: string, todoId: string, updatedTodo: TodoUpdate): Promise<void> {
    await this.docClient.update({
      TableName: this.todosTable,
      Key: { userId, todoId },
      UpdateExpression: "set #name = :n, dueDate=:dueDate, done=:done",
      ExpressionAttributeValues: {
        ":n": updatedTodo.name,
        ":dueDate": updatedTodo.dueDate,
        ":done": updatedTodo.done
      },
      ExpressionAttributeNames: { '#name': 'name' },
      ReturnValues: "NONE"
    }).promise()
  }
}