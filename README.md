# Tricount-like Shared Expenses Manager

This project is a full-stack implementation of a shared expenses manager inspired by the mobile application Tricount.  
It includes a PostgreSQL/PostgREST backend enforcing strict business rules and a Flutter frontend providing a complete user interface for managing tricounts, participants, expenses and balances.

The goal of the project is to reproduce the functional and behavioural logic of Tricount while applying strong architectural, security and data integrity constraints.

---

## Features

### Users
- Registration and login with password rules (minimum length, uppercase, digit, special character)
- Unique email and display name
- Optional IBAN with structural validation
- Roles: user or administrator
- Secure password storage (hash + salt)

---

## Tricounts
A tricount is a shared expenses group.

- Title (unique per creator, case-insensitive)
- Optional description
- Auto-generated creation timestamp
- Creator cannot be changed
- Participants automatically include the creator

---

## Participants
- A participant cannot be removed if involved in an expense
- The creator of a tricount can never be removed
- Removal is validated via business rules implemented in the database

---

## Expenses
Each expense includes:
- Title
- Amount (> 0)
- Operation date (cannot be before tricount creation or in the future)
- Creator (must be a participant)
- Weighted repartition on participants

Expenses also store:
- Auto-incremented ID
- Timestamp of creation (immutable)

---

## Weighted Repartition
Each expense distributes its amount across participants through integer weights.

Example:
- Weights 2, 1, 3 correspond to 2/6, 1/6 and 3/6 of the expense

This logic is fully computed at backend level using SQL functions and validated through rules and triggers.

---

## Balance Computation
Balances are computed dynamically by the backend and never stored.

Rules:
- A virtual account per participant starts at zero
- Each participant receives a negative amount equal to their share of each expense
- The payer receives a positive amount equal to the total expense
- Sum of balances for a tricount equals zero (with rounding tolerance)

---

## Access Control

### Visitor (not authenticated)
- Can create a user (signup)
- Cannot read, list, create, update or delete tricounts or expenses

### Authenticated User
- Can read and list users (ID and name for all users, email only for themselves)
- Can list tricounts they participate in
- Can create tricounts
- Can read and update tricounts they have access to
- Can create/update/delete expenses only within accessible tricounts

### Administrator
- Full access on all tricounts, participants and expenses

Access rules are implemented inside the PostgreSQL functions published as PostgREST endpoints.

---

## Backend Architecture (PostgreSQL + PostgREST)

The backend strictly exposes **only SQL functions** via PostgREST.  
All business logic, validations and invariants are implemented in the database.

Functional layers:

- Referential integrity
- Unique constraints (case-insensitive)
- Check constraints
- Triggers enforcing business invariants
- SQL functions for computations (like balance calculation)
- SQL functions for endpoints (create/update/delete/read)

File structure (recommended):
01_init.sql
02_security.sql
03_tables_and_data.sql
04_business_rules.sql
05_computations.sql
06_endpoints.sql


---

## API Documentation

The full API is documented using a Postman Collection (`prbd_2425_xyy_api.postman_collection.json`).  
Endpoints must follow the exact specification to pass automatic tests.

All endpoints include example bodies for testing.

---

## Frontend (Flutter)

The Flutter application reproduces the behaviour of the Tricount user experience:

### Implemented Screens
- Login / Logout
- Signup with asynchronous uniqueness validation for email and display name
- Reset database
- List tricounts (filtered according to access rights)
- View tricount
- Add / edit / delete tricount
- Add / edit / delete operation
- Dynamic balance view
- Theming (optional)
- Auto-refresh using backend queries

### Sorting and Display Rules
- Tricounts sorted by most recent operation date, then by ID
- Operations sorted by operation date then ID
- Balance bars proportional to absolute user balance
- Users sorted alphabetically
- Paid-by combobox sorted alphabetically and preselected for the logged-in user

---

## State Management (Riverpod)

Required providers:
- `AsyncNotifierProvider`: current user
- `AsyncNotifierProvider`: accessible tricount list
- `ChangeNotifierProvider`: current opened tricount
- `FutureProvider`: all system users
- `AsyncNotifierProvider`: balance of current tricount participants

This structure ensures modularity, isolation of concerns and clean refresh mechanisms.

---

## Testing

### Backend
- SQL-level tests via direct queries
- Postman HTTP tests
- Automated Dart unit tests (following template structure)

### Frontend
- Widget tests (optional)
- Integration tests for HTTP failures and edge cases

---

## Known Limitations
(Adapt this section according to your progress.)

- Some frontend features may still be incomplete
- Missing edge-case validations
- Limited test coverage depending on implementation stage

---

## Technologies

Backend:
- PostgreSQL
- PostgREST
- SQL triggers, constraints, functions
- Postman (API testing)

Frontend:
- Flutter
- Riverpod
- Dart HTTP client
- Windows Desktop target

Tools:
- Git / Bitbucket
- IntelliJ / VS Code
- Diagram tools (PlantUML, Draw.io)

---

## Academic Context

This project was developed as part of the PRBD course (2024–2025).  
Compliance with the provided specification and endpoint contract is mandatory.  
Automatic grading and individual oral examination determine the final grade.

