import {History} from 'history'
import * as React from 'react'
import {Button, Card, Confirm, Form, Grid, Header, Image, Input, Loader, Modal, TextArea, Checkbox} from 'semantic-ui-react'

import {deleteWishlist, getWishlistItems, updateWishlist, uploadFile, getUploadUrl} from '../api/api'
import Auth from '../auth/Auth'
import {Wishlist} from '../types/Wishlist'

interface WishlistsProps {
    auth: Auth
    history: History
}

interface WishlistsState {
    wishlists: Wishlist[]
    loading: boolean
    delete_confirm_open: boolean
    wishlist_id: string,
    file: any
}

export class Wishlists extends React.PureComponent<WishlistsProps, WishlistsState> {
    state: WishlistsState = {
        wishlists: [],
        loading: true,
        delete_confirm_open: false,
        wishlist_id: "",
        file: undefined
    }
    wishlist_update_state = {
        "wishlist_id": "",
        "description": "",
        "price": "",
        "category": "",
        "completed": false
    }


    async componentDidMount() {
        try {
            const wishlists = await getWishlistItems(this.props.auth.getIdToken())

            this.setState({
                wishlists: wishlists,
                loading: false
            })
        } catch (e) {
        }
    }

    render() {
        return (
            <div>
                {this.renderWishlists()}
            </div>
        )
    }

    renderWishlists() {
        if (this.state.loading) {
            return this.renderLoading()
        }

        return this.renderWishList();
    }

    renderLoading() {
        return (
            <Grid.Row>
                <Loader indeterminate active inline="centered">
                    Loading..
                </Loader>
            </Grid.Row>
        )
    }

    showDeleteConfirm = (wishlist_id: string) => this.setState({delete_confirm_open: true, wishlist_id: wishlist_id})
    handleConfirm = async () => {
        try {
            await deleteWishlist(this.props.auth.getIdToken(), this.state.wishlist_id)
            this.setState({
                wishlists: this.state.wishlists.filter(wishlist => wishlist.wishlist_id !== this.state.wishlist_id)
            })
        } catch {
            alert('Wishlist deletion failed')
        }
        this.setState({delete_confirm_open: false, wishlist_id: ""})
    }
    handleCancel = () => this.setState({delete_confirm_open: false, wishlist_id: ""})

    handleInputChange= (event: any) => {
        // @ts-ignore
        this.wishlist_update_state[event.target.name] = event.target.value
    }

    handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
        const files = event.target.files
        if (!files) return

        this.setState({
          file: files[0]
        })
      }

    handleSubmit = async () => {
        try {
            if (!this.state.file) {
                alert('File should be selected')
                return
              }
            await updateWishlist(this.props.auth.getIdToken(), this.wishlist_update_state)
            const uploadUrl = await getUploadUrl(this.props.auth.getIdToken(), this.wishlist_update_state.wishlist_id)
            await uploadFile(uploadUrl, this.state.file)
            const wishlists = await getWishlistItems(this.props.auth.getIdToken())
            window.location.reload()
        } catch {
            alert('wishlist Update failed')
        }
    }

    renderWishList() {
        return (
            <Card.Group>
                {this.state.wishlists.map((wishlist, pos) => {
                    return (
                        <Card key={wishlist.wishlist_id}>
                            <Card.Content>
                                <Image
                                    floated='right'
                                    size='mini'
                                    src={wishlist.attachment_url}
                                />
                                <Card.Header>{wishlist.name}</Card.Header>
                                <Card.Meta>Category - {wishlist.category}</Card.Meta>
                                <Card.Meta><strong>$ {wishlist.price}</strong></Card.Meta>
                                <Card.Description>
                                    {wishlist.description}
                                </Card.Description>
                            </Card.Content>
                            <Card.Content extra>
                                <div className='ui two buttons'>
                                    <Modal
                                        onOpen={() => {
                                            this.wishlist_update_state.wishlist_id = wishlist.wishlist_id
                                            this.wishlist_update_state.description = wishlist.description
                                            this.wishlist_update_state.price = wishlist.price
                                            this.wishlist_update_state.category = wishlist.category
                                            this.wishlist_update_state.completed = wishlist.completed
                                        }}
                                        onClose={() => {
                                            this.wishlist_update_state.wishlist_id = ""
                                            this.wishlist_update_state.description = ""
                                            this.wishlist_update_state.price = ""
                                            this.wishlist_update_state.category = ""
                                            this.wishlist_update_state.completed = false
                                        }}
                                        trigger={<Button basic color='green'>Edit</Button>}
                                    >
                                        <Modal.Header>Edit Wishlist Item</Modal.Header>
                                        <Modal.Content image>
                                            <Image size='medium' src='/images/avatar/large/rachel.png' wrapped/>
                                            <Modal.Description>
                                                <Header>{wishlist.name}</Header>
                                                <Form onSubmit={this.handleSubmit}>
                                                    <Form.Group widths='equal'>
                                                        <Form.Field required
                                                                    control={Input}
                                                                    label='Price'
                                                                    placeholder='Price'
                                                                    defaultValue={wishlist.price}
                                                                    name="price"
                                                                    type='number'
                                                                    onChange={this.handleInputChange}
                                                        />
                                                        <Form.Field required
                                                                    control={Input}
                                                                    label='Category'
                                                                    placeholder='Category'
                                                                    defaultValue={wishlist.category}
                                                                    name="category"
                                                                    onChange={this.handleInputChange}
                                                        />
                                                    </Form.Group>
                                                    <Form.Field  name="completed">
                                                      <Checkbox label='Mark as Complete' />
                                                    </Form.Field>
                                                    <Form.Field  name="completed">
                                                        <label>Image</label>
                                                        <Input type="file" onChange={this.handleFileChange}/>
                                                    </Form.Field>
                                                    <Form.Field required
                                                                control={TextArea}
                                                                label='description'
                                                                placeholder='Tell us more about you...'
                                                                defaultValue={wishlist.description}
                                                                name="description"
                                                                onChange={this.handleInputChange}
                                                    />
                                                    <Form.Field control={Button}>Submit</Form.Field>
                                                </Form>
                                            </Modal.Description>
                                        </Modal.Content>
                                    </Modal>
                                    <Button basic color='red'
                                            onClick={() => this.showDeleteConfirm(wishlist.wishlist_id)}>
                                        Delete
                                    </Button>
                                    <Confirm key={wishlist.wishlist_id}
                                             open={this.state.delete_confirm_open}
                                             onCancel={this.handleCancel}
                                             onConfirm={this.handleConfirm}
                                    ></Confirm>
                                </div>
                            </Card.Content>
                        </Card>
                    )
                })}
            </Card.Group>
        )
    }
}
