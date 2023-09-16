import React, {Component} from 'react'
import {Link, Route, Router, Switch} from 'react-router-dom'
import {Button, Form, Grid, Header, Image, Input, Menu, Modal, Segment, TextArea} from 'semantic-ui-react'

import Auth from './auth/Auth'
import {LogIn} from './components/LogIn'
import {NotFound} from './components/NotFound'
import {Wishlists} from './components/Wishlists'
import {createWishlist, getUploadUrl, uploadFile} from "./api/api";

export interface AppProps {
    auth: Auth
    history: any
}

export interface AppState {
}

export default class App extends Component<AppProps, AppState> {

    wishlist_update_state = {
        "name": "",
        "description": "",
        "price": "",
        "category": "",
        "file": undefined
    };

    constructor(props: AppProps) {
        super(props)
        this.handleLogin = this.handleLogin.bind(this)
        this.handleLogout = this.handleLogout.bind(this)
    }

    handleLogin() {
        this.props.auth.login()
    }

    handleLogout() {
        this.props.auth.logout()
    }

    render() {
        return (
            <div>
                <Segment vertical>
                    <Grid container stackable verticalAlign="middle">
                        <Grid.Row>
                            <Grid.Column width={16}>
                                <Header textAlign='center' as="h1">Wishlist Items</Header>
                                <Router history={this.props.history}>
                                    {this.generateMenu()}
                                    {this.generateCurrentPage()}
                                </Router>
                            </Grid.Column>
                        </Grid.Row>
                    </Grid>
                </Segment>
            </div>
        )
    }

    generateMenu() {
        return (
            <>
                {this.props.auth.isAuthenticated() && (
                    <Menu pointing secondary>
                        <Menu.Item name="home">
                            <Link to="/">Home</Link>
                        </Menu.Item>
                        <Menu.Menu position="right">{this.logInLogOutButton()}</Menu.Menu>
                        <Menu.Item name="add_new">
                            {this.generateNewItemModal()}
                        </Menu.Item>
                    </Menu>
                )}
            </>
        )
    }

    logInLogOutButton() {
        if (this.props.auth.isAuthenticated()) {
            return (
                <Menu.Item name="logout" onClick={this.handleLogout}>
                    Log Out
                </Menu.Item>
            )
        }
    }

    generateCurrentPage() {
        if (!this.props.auth.isAuthenticated()) {
            return <LogIn auth={this.props.auth}/>
        }
        return (
            <Switch>
                <Route
                    path="/"
                    exact
                    render={props => {
                        return <Wishlists {...props} auth={this.props.auth}/>
                    }}
                />
                <Route component={NotFound}/>
            </Switch>
        )
    }

    handleInputChange = (event: any) => {
        // @ts-ignore
        this.wishlist_update_state[event.target.name] = event.target.value
    }
    handleSubmit = async () => {
        try {
            let wishlists = await createWishlist(this.props.auth.getIdToken(), this.wishlist_update_state)
            const uploadUrl = await getUploadUrl(this.props.auth.getIdToken(), wishlists[0].wishlist_id)
            // @ts-ignore
            await uploadFile(uploadUrl, this.wishlist_update_state.file)
        } catch {
            alert('Wishlist Create failed')
        }
        window.location.reload()
    }

    imageInputChange = (event:any) => {
        const files = event.target.files
        if (!files) return
        this.wishlist_update_state.file = files[0];
    }

    generateNewItemModal() {
        if (this.props.auth.isAuthenticated()) {
            return (
                <Modal
                    onOpen={() => {
                        this.wishlist_update_state.name = ""
                        this.wishlist_update_state.description = ""
                        this.wishlist_update_state.price = ""
                        this.wishlist_update_state.category = ""
                    }}
                    onClose={() => {
                        this.wishlist_update_state.name = ""
                        this.wishlist_update_state.description = ""
                        this.wishlist_update_state.price = ""
                        this.wishlist_update_state.category = ""
                    }}
                    trigger={<Button basic color='blue'>New Wish</Button>}
                >
                    <Modal.Header>New Wishlist Item</Modal.Header>
                    <Modal.Content>
                        <Modal.Description>
                            <Form onSubmit={this.handleSubmit}>
                                <Form.Field required
                                            control={Input}
                                            label='Name'
                                            placeholder='Name'
                                            name="name"
                                            onChange={this.handleInputChange}
                                />
                                <Form.Group widths='equal'>
                                    <Form.Field required
                                                control={Input}
                                                label='Price'
                                                placeholder='Price'
                                                name="price"
                                                type='number'
                                                onChange={this.handleInputChange}
                                    />
                                    <Form.Field required
                                                control={Input}
                                                label='Category'
                                                placeholder='Category'
                                                name="category"
                                                onChange={this.handleInputChange}
                                    />
                                </Form.Group>
                                <Form.Field name="completed">
                                    <label>Image</label>
                                    <Input accept="image/*" type="file" onChange={this.imageInputChange}/>
                                </Form.Field>
                                <Form.Field required
                                            control={TextArea}
                                            label='description'
                                            placeholder='Tell us more about you...'
                                            name="description"
                                            onChange={this.handleInputChange}
                                />
                                <Form.Field control={Button}>Submit</Form.Field>
                            </Form>
                        </Modal.Description>
                    </Modal.Content>
                </Modal>
            )
        }
    }
}
