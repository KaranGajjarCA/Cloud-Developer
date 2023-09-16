import { apiEndpoint } from '../config'
import { Wishlist } from '../types/Wishlist';
import Axios from 'axios'

export async function getWishlistItems(idToken: string): Promise<Wishlist[]> {
  const response = await Axios.get(`${apiEndpoint}/wishlist/get`, {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    },
  })
  return response.data.items
}

export async function createWishlist(
  idToken: string,
  newItem: {}
): Promise<Wishlist[]> {
  const response = await Axios.post(`${apiEndpoint}/wishlist/create`,  JSON.stringify(newItem), {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    }
  })
  return response.data.items
}

export async function updateWishlist(
  idToken: string,
  wishlistItem: object
): Promise<void> {
  await Axios.post(`${apiEndpoint}/wishlist/update`, JSON.stringify(wishlistItem), {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    }
  })
}

export async function deleteWishlist(
  idToken: string,
  wishlistId: string
): Promise<void> {
  await Axios.post(`${apiEndpoint}/wishlist/${wishlistId}/remove`,{}, {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    }
  })
}

export async function getUploadUrl(
  idToken: string,
  wishlistId: string
): Promise<string> {
  const response = await Axios.post(`${apiEndpoint}/wishlist/${wishlistId}/attachment`, '', {
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${idToken}`
    }
  })
  return response.data.url
}

export async function uploadFile(uploadUrl: string, file: Buffer): Promise<void> {
  await Axios.put(uploadUrl, file)
}