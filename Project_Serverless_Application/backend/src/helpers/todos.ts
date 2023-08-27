import { TodosAccess } from './todosAcess'
import { AttachmentUtils } from './attachmentUtils';
import { TodoItem } from '../models/TodoItem'
import { CreateTodoRequest } from '../requests/CreateTodoRequest'
import { UpdateTodoRequest } from '../requests/UpdateTodoRequest'
import { createLogger } from '../utils/logger'
// @ts-ignore
import * as uuid from 'uuid'
// @ts-ignore
import * as createError from 'http-errors'

const logger = createLogger('todos')
export async function createTodo(
    newTodo: CreateTodoRequest,
    userId: string
): Promise<TodoItem> {
    const todoId = uuid.v4()
    logger.info('Create todo: ', userId)
    try {
        return await TodosAccess.createTodo({
            userId,
            todoId,
            createdAt: new Date().toISOString(),
            ...newTodo
        } as TodoItem)
    }
    catch (e) {
        throw createError("Create Error")
    }
}

export async function deleteTodo(userId: string, todoId: string): Promise<void> {
    logger.info('Delete todo: ', userId)
    await AttachmentUtils.deleteAttachment(todoId)
    await TodosAccess.deleteTodo(userId, todoId)
}


export async function createAttachmentPresignedUrl(userId:string, todoId: string): Promise<string> {
    const validTodo = await TodosAccess.getTodo(userId, todoId)

    if (!validTodo) {
        throw new Error('404')
    }

    const url = AttachmentUtils.getUploadUrl(todoId)
    await TodosAccess.updateAttachment(userId, todoId)
    return url
}

export async function getTodosForUser(userId: string): Promise<object> {
    const items = await TodosAccess.getTodosForUser(userId)
    logger.info('Get all todo for User: ', userId)
    // @ts-ignore
    for (let item of items.todoItems) {
        if (!!item['attachmentUrl'])
            item['attachmentUrl'] = AttachmentUtils.getDownloadUrl(item['attachmentUrl'])
    }

    return items
}

export async function updateTodo(userId: string, todoId: string, updatedTodo: UpdateTodoRequest): Promise<void> {
    const validTodo = await TodosAccess.getTodo(userId, todoId)

    if (!validTodo) {
        throw new Error('404')
    }
    return await TodosAccess.updateTodo(userId, todoId, updatedTodo)
}