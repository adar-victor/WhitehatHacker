# WhitehatHacker

WhitehatHacker is an address reputation system smart contract for ethical hacker contribution and impact scoring on the Stacks blockchain. This contract manages reputation scores for ethical hackers based on their contributions, bug reports, and overall impact in the security community.

## Features

- **Hacker Registration**: Ethical hackers can register their profiles on the blockchain
- **Contribution Tracking**: Submit and track various types of security contributions
- **Reputation Scoring**: Dynamic reputation system based on verified contributions
- **Verification System**: Authorized verifiers can validate contributions
- **Impact Assessment**: Score contributions based on their security impact (1-1000 points)
- **Reputation Tiers**: Automatic tier classification from Novice to Elite
- **Profile Verification**: Contract owner can verify hacker profiles
- **Activity Tracking**: Monitor hacker activity and contribution history

## Technical Specifications

- **Blockchain**: Stacks
- **Language**: Clarity
- **Version**: 1.0.0
- **Clarity Version**: 2
- **Epoch**: 2.5
- **Maximum Reputation Score**: 10,000 points
- **Contribution Score Range**: 1-1,000 points per contribution

## Installation

### Prerequisites

- [Clarinet CLI](https://github.com/hirosystems/clarinet) installed
- Node.js (for testing)
- Git

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd WhitehatHacker
```

2. Navigate to the contract directory:
```bash
cd WhitehatHacker_contract
```

3. Install dependencies:
```bash
npm install
```

4. Initialize Clarinet (if needed):
```bash
clarinet check
```

## Usage Examples

### Register as an Ethical Hacker

```clarity
(contract-call? .WhitehatHacker register-hacker)
```

### Submit a Contribution

```clarity
(contract-call? .WhitehatHacker submit-contribution "bug-report" u150)
```

### Verify a Contribution (Authorized Verifiers Only)

```clarity
(contract-call? .WhitehatHacker verify-contribution u1)
```

### Get Hacker Profile

```clarity
(contract-call? .WhitehatHacker get-hacker-profile 'SP1ABC123...)
```

### Check Reputation Score

```clarity
(contract-call? .WhitehatHacker get-reputation-score 'SP1ABC123...)
```

## Contract Functions Documentation

### Public Functions

#### `register-hacker()`
- **Description**: Register a new ethical hacker profile
- **Parameters**: None (uses tx-sender)
- **Returns**: `(ok true)` on success
- **Access**: Public

#### `submit-contribution(contribution-type, impact-score)`
- **Description**: Submit a new security contribution
- **Parameters**:
  - `contribution-type`: String description (max 50 chars)
  - `impact-score`: Impact score (1-1000)
- **Returns**: Contribution ID on success
- **Access**: Registered hackers only

#### `verify-contribution(contribution-id)`
- **Description**: Verify a submitted contribution
- **Parameters**: `contribution-id`: ID of contribution to verify
- **Returns**: `(ok true)` on success
- **Access**: Authorized verifiers only

#### `add-verifier(verifier)`
- **Description**: Add an authorized verifier
- **Parameters**: `verifier`: Principal address
- **Returns**: `(ok true)` on success
- **Access**: Contract owner only

#### `remove-verifier(verifier)`
- **Description**: Remove an authorized verifier
- **Parameters**: `verifier`: Principal address
- **Returns**: `(ok true)` on success
- **Access**: Contract owner only

#### `verify-hacker(hacker)`
- **Description**: Verify a hacker's profile
- **Parameters**: `hacker`: Principal address
- **Returns**: `(ok true)` on success
- **Access**: Contract owner only

### Read-Only Functions

#### `get-hacker-profile(hacker)`
- **Description**: Retrieve complete hacker profile
- **Parameters**: `hacker`: Principal address
- **Returns**: Profile object or none

#### `get-contribution(contribution-id)`
- **Description**: Get details of a specific contribution
- **Parameters**: `contribution-id`: Contribution ID
- **Returns**: Contribution object or none

#### `get-hacker-contribution(hacker, contribution-index)`
- **Description**: Get a hacker's contribution by index
- **Parameters**:
  - `hacker`: Principal address
  - `contribution-index`: Index of contribution
- **Returns**: Contribution object or none

#### `get-total-hackers()`
- **Description**: Get total number of registered hackers
- **Returns**: Number of registered hackers

#### `get-total-contributions()`
- **Description**: Get total number of contributions
- **Returns**: Total contribution count

#### `is-authorized-verifier(verifier)`
- **Description**: Check if address is authorized verifier
- **Parameters**: `verifier`: Principal address
- **Returns**: Boolean

#### `get-reputation-score(hacker)`
- **Description**: Get hacker's current reputation score
- **Parameters**: `hacker`: Principal address
- **Returns**: Reputation score or none

#### `is-hacker-verified(hacker)`
- **Description**: Check if hacker profile is verified
- **Parameters**: `hacker`: Principal address
- **Returns**: Boolean

#### `get-reputation-tier(reputation-score)`
- **Description**: Calculate reputation tier based on score
- **Parameters**: `reputation-score`: Score to evaluate
- **Returns**: Tier string (Novice, Intermediate, Advanced, Expert, Elite)

## Reputation Tiers

The system automatically categorizes hackers into tiers based on their reputation scores:

- **Novice**: 0-100 points
- **Intermediate**: 101-500 points
- **Advanced**: 501-1,500 points
- **Expert**: 1,501-5,000 points
- **Elite**: 5,001+ points

## Testing

Run the test suite:

```bash
npm test
```

Run tests with coverage and cost analysis:

```bash
npm run test:report
```

Watch mode for continuous testing:

```bash
npm run test:watch
```

## Deployment Guide

### Local Development

1. Start Clarinet console:
```bash
clarinet console
```

2. Deploy contract:
```clarity
::deploy_contract contracts/WhitehatHacker.clar
```

### Testnet Deployment

1. Configure your testnet settings in `settings/Testnet.toml`

2. Deploy using Clarinet:
```bash
clarinet deploy --testnet
```

### Mainnet Deployment

1. Configure your mainnet settings in `settings/Mainnet.toml`

2. Deploy using Clarinet:
```bash
clarinet deploy --mainnet
```

## Security Notes

### Access Controls

- **Contract Owner**: Can add/remove verifiers and verify hacker profiles
- **Authorized Verifiers**: Can verify contributions submitted by hackers
- **Registered Hackers**: Can submit contributions and manage their profiles
- **Public**: Can read all public data

### Security Considerations

1. **Contribution Verification**: All contributions must be verified by authorized verifiers before reputation scores are updated
2. **Score Limits**: Reputation scores are capped at 10,000 points to prevent overflow
3. **Input Validation**: All inputs are validated for proper ranges and formats
4. **Access Control**: Strict role-based access control for sensitive functions
5. **Data Integrity**: Immutable contribution history once verified

### Error Codes

- `u100`: Owner-only function called by non-owner
- `u101`: Unauthorized access attempt
- `u102`: Invalid score provided
- `u103`: Hacker profile not found
- `u104`: Already verified (duplicate verification attempt)
- `u105`: Invalid contribution parameters

## Data Structures

### Hacker Profile
```clarity
{
  reputation-score: uint,
  total-contributions: uint,
  verified: bool,
  registration-block: uint,
  last-activity-block: uint
}
```

### Contribution
```clarity
{
  hacker: principal,
  contribution-type: (string-ascii 50),
  impact-score: uint,
  verified: bool,
  submission-block: uint,
  verifier: (optional principal)
}
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## License

This project is licensed under the ISC License.

## Contact

For questions, issues, or contributions, please open an issue on the project repository.