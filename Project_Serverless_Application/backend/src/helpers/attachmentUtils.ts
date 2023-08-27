// @ts-ignore
import * as AWS from 'aws-sdk'
// @ts-ignore
import * as AWSXRay from 'aws-xray-sdk'

const XAWS = AWSXRay.captureAWS(AWS)

export class AttachmentUtils {
    private static s3: AWS.S3 = new XAWS.S3({ signatureVersion: 'v4' }); // @ts-ignore
    private static bucketName: string = process.env.ATTACHMENT_S3_BUCKET; // @ts-ignore
    private static urlExpiration: number = parseInt(process.env.SIGNED_URL_EXPIRATION);

    static async deleteAttachment(todoId: string)  {
        await this.s3.deleteObject({
            Bucket: this.bucketName,
            Key: todoId
        }).promise()
    }
    static getDownloadUrl(imageId: string): string {
        return this.s3.getSignedUrl('getObject', {
            Bucket: this.bucketName,
            Key: imageId
        })
    }

    static getUploadUrl(imageId: string): string {
        return this.s3.getSignedUrl('putObject', {
            Bucket: this.bucketName,
            Key: imageId,
            Expires: this.urlExpiration
        })
    }


}