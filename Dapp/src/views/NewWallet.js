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
            userAddress: null,
            numberOfUsers: 1,
            ownerData: [],
            rows: [{}]
        }

        this.addRow = this.addRow.bind(this);
        this.removeRow = this.removeRow.bind(this);
        this.handleChange = this.handleChange.bind(this);
    }

    async componentWillMount() {
        // Get network provider and web3 instance.
        // See utils/getWeb3 for more info.
        await getWeb3
        .then(results => {
            this.setState({
                web3: results.web3
            })
            results.web3.eth.getAccounts((error, accounts) => {
                this.setState({userAddress: accounts[0]})
            })
    
        })
        .catch(() => {
            console.log('Error finding web3.')        
        })
    }


    handleChange = idx => e => {
        const name = e.target.name;
        const value = e.target.value;
        // console.log("Name: ",name,"  VAlue:",value)
        const rows = [...this.state.rows];
        const j = rows[idx]
        if(name == "walletMember")
            rows[idx].walletMember = value
        else if(name == "address")     
            rows[idx].address = value
        this.setState({
          rows
        });
    };
    
    
    addRow = () => {
        const item = {
          walletMember: "",
          address: ""
        };
        this.setState({
          rows: [...this.state.rows, item]
        });
        console.log("Rows:",this.state.rows)
    };
  
    
    removeRow = (idx) => () => {
    const rows = [...this.state.rows]
    rows.splice(idx, 1)
    console.log("After deletion: ", rows)
    this.setState({ rows })
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
                                    required={true}
                                    />
                                </Col>
                            </Row>
                            <Row form>
                                <Col md="6" className="form-group">
                                    <label>Required Confirmations</label>
                                    <FormInput
                                    id="requiredConfirmations"
                                    type="number"
                                    min="1"
                                    defaultValue="1"
                                    required={true}    
                                    />
                                </Col>
                            </Row>
                            <Row form>
                                <Col md="6" className="form-group">
                                    <label>Daily Limit</label>
                                    <FormInput
                                    id="dailyLimit"
                                    type="number"
                                    defaultValue="0"
                                    min="0"
                                    required={true}    
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
                                                Address(42 characters)
                                            </th>
                                            <th scope="col" className="border-0">
                                                Action
                                            </th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            {this.state.rows.map((item, idx) => (
                                                <tr id="addr" key={idx}>
                                                    <td>
                                                        <FormInput
                                                            name = "walletMember"
                                                            required={true}
                                                            value={this.state.rows[idx].walletMember || ''}
                                                            onChange={this.handleChange(idx)}
                                                        />
                                                    </td>
                                                    <td>
                                                        <FormInput
                                                            name = "address"
                                                            value={this.state.rows[idx].address || ''}
                                                            required={true}
                                                            pattern=".{42,42}"
                                                            onChange={this.handleChange(idx)}
                                                        />
                                                    </td>
                                                    <td>
                                                        <Button 
                                                            theme="danger"
                                                        onClick={this.removeRow(idx)}>
                                                                Remove
                                                        </Button>
                                                    </td>
                                                </tr>
                                            ))}
                                        <tr>
                                            <td>
                                            <Button onClick={this.addRow}>
                                                                Add ( + )
                                                    </Button>

                                            </td>
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
