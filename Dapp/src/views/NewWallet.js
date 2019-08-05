import React from "react";
import {
  Container,
  Row,
  Col,
  Form,
  FormInput,
  FormSelect,
  FormGroup,
  FormCheckbox,
  Button,
  Card,
  CardBody,
  CardHeader,
  InputGroup,
  InputGroupAddon,
  InputGroupText
} from "shards-react";
import PageTitle from "./../components/common/PageTitle";
import getWeb3 from "../Dependencies/getWeb3";

export class NewWallet extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            web3: null,
            userAddress: null
        }
    }

    async componentWillMount() {
        // Get network provider and web3 instance.
        // See utils/getWeb3 for more info.
        await getWeb3
        .then(results => {
            this.setState({
                web3: results.web3
            })
        })
        .catch(() => {
            console.log('Error finding web3.')        
        })
    }

    render() {
        return(
            <Container fluid className="main-content-container px-4">
                    {/* Page Header */}
                <Row noGutters className="page-header py-4">
                    <PageTitle title="New Wallet" subtitle="" className="text-sm-left mb-3" />
                </Row>
                <Row>
                    <Col>
                        <Form>
                            <Row form>
                                <Col md="6" className="form-group">
                                    <label>Name</label>
                                    <FormInput
                                    id="walletName"
                                    />
                                </Col>
                            </Row>
                            <Row form>
                                <Col md="6" className="form-group">
                                    <label>Required Confirmations</label>
                                    <FormInput
                                    id="requiredConfirmations"
                                    type="number"
                                    value="1"    
                                    />
                                </Col>
                            </Row>
                            <Row form>
                                <Col md="6" className="form-group">
                                    <label>Daily Limit</label>
                                    <FormInput
                                    id="dailyLimit"
                                    type="number"
                                    value="0"    
                                    />
                                </Col>
                            </Row>
                            <Row>
                                <Col className="form-group">
                                    <Card small className="mb-4">
                                    <CardHeader className="border-bottom">
                                        <h6 className="m-0">Owners</h6>
                                    </CardHeader>
                                    <CardBody className="p-0 pb-3">
                                        <table className="table mb-0" style={{borderCollapse:'collapse'}}>
                                        <thead className="bg-light">
                                            <tr>
                                            <th scope="col" className="border-0">
                                                Name
                                            </th>
                                            <th scope="col" className="border-0">
                                                Address
                                            </th>
                                            <th scope="col" className="border-0">
                                                Action
                                            </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <tr>
                                            <td>
                                                <FormInput
                                                id="ownerName"
                                                />
                                            </td>
                                            <td>
                                            <FormInput
                                                id="ownerAddress"
                                                />
                                            </td>
                                            <td><Button>Add</Button></td>
                                            </tr>
                                        </tbody>
                                        </table>
                                    </CardBody>
                                    </Card>
                                </Col>
                            </Row>
                            <Button type="submit">Create New Wallet</Button>
                        </Form>
                    </Col>
                </Row>

        </Container>
        );
    }
}

export default NewWallet;
