<h1 align="center">
    <a href="https://dreamfactory.com/"><img src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/vertical-logo-fullcolor.png" alt="DreamFactory" width="250" /></a>
</h1>

<h2 align="center">DreamFactory is a self-hosted platform providing governed API access to any data source for enterprise apps and local LLMs.</h2>

<p align="center">
    <a href="https://docs.dreamfactory.com">Documentation</a> ∙ <a href="https://guide.dreamfactory.com/">Getting Started Guide</a> ∙ <a href="https://github.com/dreamfactorysoftware/dreamfactory/blob/master/CONTRIBUTING.md">Contribute</a> ∙ <a href="http://community.dreamfactory.com/">Community Support</a>
</p>

<p align="center">
    <img alt="GitHub License" src="https://img.shields.io/github/license/dreamfactorysoftware/dreamfactory.svg?style=plastic">
    <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dreamfactorysoftware/df-docker.svg?style=plastic">
    <img alt="GitHub Release Date" src="https://img.shields.io/github/release-date/dreamfactorysoftware/dreamfactory.svg?style=plastic">
</p>

<p align="center">
    <a href="https://twitter.com/dfsoftwareinc?lang=en"><img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/dfsoftwareinc.svg?style=social"></a>
</p>

<p align="center">
<a href="https://docs.dreamfactory.com/getting-started/installing-dreamfactory/windows-installation">
  <img src="https://github.com/dreamfactorysoftware/dreamfactory/blob/master/readme/install-on-windows.svg" alt="Install on Windows">
</a>
&nbsp;&nbsp;
<a href="https://github.com/dreamfactorysoftware/dreamfactory/tree/master/installers">
  <img src="https://github.com/dreamfactorysoftware/dreamfactory/blob/master/readme/install-on-linux.svg" alt="Install on Linux">
</a>
</p>

<p align="center">
<a href="https://github.com/dreamfactorysoftware/df-helm">
  <img src="https://github.com/dreamfactorysoftware/dreamfactory/blob/master/readme/deploy-with-helm.svg" alt="Deploy with Helm">
</a>
&nbsp;&nbsp;
<a href="https://github.com/dreamfactorysoftware/df-docker">
  <img src="https://github.com/dreamfactorysoftware/dreamfactory/blob/master/readme/deploy-with-docker.svg" alt="Deploy with Docker">
</a>
</p>

---

## Table of Contents

- [What is DreamFactory?](#what-is-dreamfactory)
- [How It Works](#how-it-works)
- [Key Features](#key-features)
- [Supported Data Sources](#supported-data-sources)
- [MCP Server for AI and LLM Integration](#mcp-server-for-ai-and-llm-integration)
- [Installation](#installation)
- [Documentation](#documentation)
- [Community and Support](#community-and-support)
- [Commercial Licenses](#commercial-licenses)
- [FAQ](#faq)
- [Feedback and Contributions](#feedback-and-contributions)

---

## What is DreamFactory?

DreamFactory is a secure, self-hosted enterprise data access platform that provides governed API access to any data source, connecting enterprise applications and on-prem LLMs with role-based access and identity passthrough.

DreamFactory is built on the [Laravel framework](https://laravel.com/) and serves as a governed AI data access layer between your applications and data sources. Whether you're building internal tools, mobile apps, or connecting AI models to enterprise data, DreamFactory provides a single, secure API gateway.

### Use Cases

- **API-first development** — Generate REST APIs for existing databases without writing backend code
- **AI and LLM data access** — Connect ChatGPT, Claude, or local LLMs to enterprise data via MCP or REST APIs with governed access controls
- **Legacy database modernization** — Wrap SQL Server stored procedures, Oracle databases, and mainframe data in modern REST APIs
- **Microservices backend** — Replace hand-coded CRUD APIs with auto-generated, documented endpoints
- **Mobile and web app backend** — Provide secure, role-based data access for frontend applications
- **Data integration** — Combine multiple databases and services behind a single API gateway

---

## How It Works

DreamFactory connects to your database, introspects the schema, and generates a complete REST API with full CRUD operations, relationship handling, stored procedure access, and OpenAPI/Swagger documentation — all in minutes.

<p align="center">
    <img src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/mcp-data-flow.gif" alt="DreamFactory MCP Data Flow" width="800" />
</p>

<p align="center"><em>See how DreamFactory connects AI models, applications, databases, and file storage services through governed MCP and REST API endpoints.</em></p>

**Quick Start:**

1. Install DreamFactory on [Linux](#installation), [Windows](#installation), [Docker](https://github.com/dreamfactorysoftware/df-docker), or [Kubernetes](https://github.com/dreamfactorysoftware/df-helm)
2. Connect a database (MySQL, PostgreSQL, SQL Server, MongoDB, etc.)
3. DreamFactory auto-generates a REST API with full OpenAPI documentation
4. Configure roles, API keys, and access controls
5. Call your APIs from any application, script, or AI model

---

## Key Features

### API Generation
- **Automatic REST API creation** for SQL and NoSQL databases — no code required
- **OpenAPI/Swagger documentation** generated automatically for every endpoint
- **Stored procedure and function support** — expose database logic as API endpoints
- **Related data retrieval** — fetch parent/child records in a single API call
- **Server-side filtering, sorting, and pagination** built into every endpoint
- **Bulk insert, update, and delete** operations for high-throughput data access

### Security and Access Control
- **Role-based access control (RBAC)** — granular permissions per table, endpoint, and HTTP verb
- **API key management** — issue, revoke, and rate-limit API keys per application
- **SSO authentication** — SAML 2.0, OAuth 2.0, OpenID Connect, Azure AD, LDAP/Active Directory
- **API rate limiting** — throttle requests per user, role, or service
- **Audit logging** — track every API call with user, timestamp, and payload
- **Data masking and field-level security** — control which columns are visible per role

### Extensibility
- **Server-side scripting** — customize API behavior with PHP, Python, or Node.js at any endpoint
- **Pre- and post-process event scripts** — transform requests and responses
- **Custom service creation** — build and register your own API services
- **Webhook and event broadcasting** — trigger external workflows on data changes

### MCP Server (Model Context Protocol)
- **Built-in MCP server** for connecting AI models (ChatGPT, Claude, local LLMs) to your databases
- **Governed AI data access** — AI queries go through DreamFactory's RBAC and audit logging
- **Deterministic database queries** — AI uses structured API calls, not raw SQL generation
  - **Tool definitions** — expose database tables and stored procedures as MCP tools

### Administration
- **Web-based admin console** — manage services, roles, users, and API keys from a browser
- **Multi-tenant support** — host multiple isolated API environments on a single instance
- **Database schema management** — create, modify, and manage tables via API or admin UI
- **API usage dashboards** — monitor request volume, errors, and performance

---

## Supported Data Sources

DreamFactory connects to a wide range of databases and services out of the box.

### SQL Databases

| Database | Connector Package | Features |
|---|---|---|
| **MySQL / MariaDB** | [df-mysqldb](https://github.com/dreamfactorysoftware/df-mysqldb) | Full CRUD, stored procedures, views, relationships |
| **PostgreSQL** | [df-sqldb](https://github.com/dreamfactorysoftware/df-sqldb) | Full CRUD, stored procedures, views, relationships |
| **SQL Server** | [df-sqlsrv](https://github.com/dreamfactorysoftware/df-sqlsrv) | Full CRUD, stored procedures, views, relationships |
| **Oracle** | [df-oracledb](https://github.com/dreamfactorysoftware/df-oracledb) | Full CRUD, stored procedures, views, relationships |
| **SQLite** | [df-sqldb](https://github.com/dreamfactorysoftware/df-sqldb) | Full CRUD, views |
| **IBM Db2** | [df-ibmdb2](https://github.com/dreamfactorysoftware/df-ibmdb2) | Full CRUD, stored procedures |
| **SAP SQL Anywhere** | [df-sqlanywhere](https://github.com/dreamfactorysoftware/df-sqlanywhere) | Full CRUD, stored procedures |
| **Firebird** | [df-firebird](https://github.com/dreamfactorysoftware/df-firebird) | Full CRUD, stored procedures |
| **Snowflake** | [df-snowflake](https://github.com/dreamfactorysoftware/df-snowflake) | Full CRUD, views |
| **Apache Spark / Databricks** | [df-spark](https://github.com/dreamfactorysoftware/df-spark) | Full CRUD, Spark SQL |

### NoSQL Databases

| Database | Connector Package |
|---|---|
| **MongoDB** | [df-mongodb](https://github.com/dreamfactorysoftware/df-mongodb) |
| **Apache Cassandra** | [df-cassandra](https://github.com/dreamfactorysoftware/df-cassandra) |
| **Couchbase** | [df-couchbase](https://github.com/dreamfactorysoftware/df-couchbase) |
| **CouchDB** | [df-couchdb](https://github.com/dreamfactorysoftware/df-couchdb) |

### File Storage and Other Services

| Service | Description |
|---|---|
| **Local File Storage** | Manage files and folders via REST API |
| **AWS S3** | Amazon S3 bucket operations |
| **Azure Blob Storage** | Azure blob and container management |
| **SFTP / FTP** | Remote file system access |
| **Email (SMTP)** | Send emails via API |
| **Push Notifications** | Apple and Google push notifications |
| **SOAP Services** | Convert SOAP/WSDL services to REST |

---

## MCP Server for AI and LLM Integration

DreamFactory includes a **built-in MCP (Model Context Protocol) server** that enables AI assistants and large language models to securely query your databases through governed API endpoints.

### Why Use DreamFactory as an MCP Server?

- **No raw SQL generation** — AI models call structured API endpoints instead of generating unpredictable SQL queries
- **Enterprise security** — Every AI query passes through DreamFactory's role-based access control and audit logging
- **Works with any MCP client** — Compatible with Claude Desktop, ChatGPT, Cursor, Windsurf, and other MCP-enabled tools
- **Stored procedure support** — Expose complex business logic as simple tool calls for AI models

### Getting Started with MCP

```bash
# Install DreamFactory with MCP support using NPX
npx @dreamfactory/create-df-mcp
```

Or configure your existing DreamFactory instance as an MCP server. See the [MCP Server documentation](https://docs.dreamfactory.com/AI/mcp-server) for setup instructions.

---

## Installation

DreamFactory can be installed on Linux, Windows, Docker, or Kubernetes.

### Linux (Ubuntu, Debian, CentOS, RHEL, Fedora)

Install DreamFactory and all dependencies in under 5 minutes using our automated installers:

```bash
git clone https://github.com/dreamfactorysoftware/dreamfactory.git
cd dreamfactory/installers
sudo bash dfsetup.run
```

See the [Linux installers directory](https://github.com/dreamfactorysoftware/dreamfactory/tree/master/installers) for supported distributions.

### Windows

Follow our step-by-step guide for installing DreamFactory on Windows with IIS or Apache:

[Windows Installation Guide](https://docs.dreamfactory.com/getting-started/installing-dreamfactory/windows-installation)

### Docker

The fastest way to get started. Spins up DreamFactory, MySQL, Redis, and a sample PostgreSQL database:

```bash
git clone https://github.com/dreamfactorysoftware/df-docker.git
cd df-docker
docker compose up -d
```

See the [df-docker repository](https://github.com/dreamfactorysoftware/df-docker) for full instructions.

### Kubernetes (Helm)

Deploy DreamFactory to your Kubernetes cluster using our official Helm chart:

```bash
helm repo add dreamfactory https://dreamfactorysoftware.github.io/df-helm
helm install dreamfactory dreamfactory/dreamfactory
```

See the [df-helm repository](https://github.com/dreamfactorysoftware/df-helm) for configuration options.

### NPX Quick Install

Our Node-based installer sets up DreamFactory with optional MCP server and a PostgreSQL test database:

```bash
npx @dreamfactory/create-df-mcp
```

See the [NPX installer on npm](https://www.npmjs.com/package/@dreamfactory/create-df-mcp) for details.

---

## Documentation

| Resource | Description |
|---|---|
| [Getting Started Guide](https://guide.dreamfactory.com/) | Step-by-step walkthrough for new users |
| [Platform Documentation](https://docs.dreamfactory.com) | Full reference documentation |
| [API Reference (Wiki)](https://wiki.dreamfactory.com) | API endpoint reference and examples |
| [MCP Server Docs](https://docs.dreamfactory.com/AI/mcp-server) | Setting up DreamFactory as an MCP server for AI |
| [Blog](https://blog.dreamfactory.com/) | Tutorials, use cases, and product updates |

---

## Community and Support

| <a href="https://stackoverflow.com/questions/tagged/dreamfactory"><img src="https://static-00.iconduck.com/assets.00/stack-overflow-icon-2048x2048-7ohycn5z.png" height="50px" alt="Stack Overflow"/></a> | <a href="https://community.dreamfactory.com"><img src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/vertical-logo-fullcolor.png" height="60px" alt="DreamFactory Community"/></a> | <a href="https://twitter.com/dfsoftwareinc"><img src="https://upload.wikimedia.org/wikipedia/commons/thumb/b/b7/X_logo.jpg/768px-X_logo.jpg" height="40px" alt="X (Twitter)"/></a> |
| --- | --- | --- |
| Ask and answer questions with the [`dreamfactory` tag](https://stackoverflow.com/questions/tagged/dreamfactory) on Stack Overflow | Visit [Docs](https://docs.dreamfactory.com), [Wiki](https://wiki.dreamfactory.com), and [Guide](https://guide.dreamfactory.com) for tutorials and examples | Follow [`@dfsoftwareinc`](https://twitter.com/dfsoftwareinc) for updates |

---

## Commercial Licenses

Need official technical support? Looking for advanced connectors for SQL Server, Oracle, Snowflake, or SOAP? Require API rate limiting, audit logging, or multi-tenant support? [Schedule a demo](https://www.dreamfactory.com/demo/) with our team.

---

## FAQ

### What databases does DreamFactory support?

DreamFactory supports MySQL, MariaDB, PostgreSQL, SQL Server, Oracle, SQLite, MongoDB, Cassandra, Couchbase, CouchDB, IBM Db2, Firebird, SAP SQL Anywhere, Snowflake, and Apache Spark/Databricks. It also supports file storage (local, S3, Azure Blob, SFTP), email, and SOAP-to-REST conversion.

### How does DreamFactory generate REST APIs?

DreamFactory connects to your database, introspects the schema (tables, views, stored procedures, relationships), and automatically generates a full set of REST endpoints with CRUD operations. Each endpoint is documented with an OpenAPI/Swagger specification. No code generation or compilation step is required — APIs are available immediately.

### Is DreamFactory open source?

Yes. DreamFactory's core platform is open source under the Apache 2.0 license. A commercial edition is available with additional connectors (SQL Server, Oracle, Snowflake), enterprise security features (LDAP, SAML, audit logging), and official support.

### How does DreamFactory work with AI and LLMs?

DreamFactory includes a built-in MCP (Model Context Protocol) server that enables AI assistants like Claude and ChatGPT to query your databases through governed API endpoints. Instead of generating raw SQL, AI models call DreamFactory's structured REST API — with full role-based access control and audit logging applied to every request.

### Can DreamFactory replace a custom backend API?

For standard CRUD operations, yes. DreamFactory generates feature-complete REST APIs with filtering, sorting, pagination, bulk operations, relationship handling, and stored procedure support. Custom business logic can be added via server-side scripting in PHP, Python, or Node.js.

### How does DreamFactory handle authentication?

DreamFactory supports API key authentication, session-based authentication, and SSO via SAML 2.0, OAuth 2.0, OpenID Connect, Azure AD, and LDAP/Active Directory. Each authentication method integrates with DreamFactory's role-based access control system.

### Can I use DreamFactory as an AI data gateway?

Yes. DreamFactory acts as a centralized AI data gateway that unifies access to multiple databases and services. You can connect several databases, apply consistent security policies, and expose them through a single API endpoint or MCP endpoint with unified documentation.

---

## Feedback and Contributions

Feedback is welcome on our [community forum](http://community.dreamfactory.com/) or in the form of pull requests and/or issues. Contributions should follow the strategy outlined in ["Contributing to a project"](http://help.github.com/articles/fork-a-repo#contributing-to-a-project).

---

<p align="center">
    <sub>Built with Laravel. Secured by design. Governed for enterprise.</sub>
</p>
