<h1 align="center">
    <a href="https://dreamfactory.com/"><img src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/vertical-logo-fullcolor.png" alt="DreamFactory" width="250" /></a>
</h1>

<p align="center">
    <strong>Instant APIs without code</strong>
</p>

<p align="center">
    <a href="https://wiki.dreamfactory.com">Docs</a> ∙ <a href="https://genie.dreamfactory.com">Try Online</a> ∙ <a href="https://github.com/dreamfactorysoftware/dreamfactory/blob/master/CONTRIBUTING.md">Contribute</a> ∙ <a href="http://community.dreamfactory.com/">Community Support</a> ∙ <a href="http://guide.dreamfactory.com/">Get Started Guide</a>
</p>

<p align="center">
    <img alt="GitHub" src="https://img.shields.io/github/license/dreamfactorysoftware/dreamfactory.svg?style=plastic">
    <img alt="Docker Pulls" src="https://img.shields.io/docker/pulls/dreamfactorysoftware/df-docker.svg?style=plastic">
    <img alt="GitHub Release Date" src="https://img.shields.io/github/release-date/dreamfactorysoftware/dreamfactory.svg?style=plastic">
</p>

<p align="center">
    <a href="https://twitter.com/dfsoftwareinc?lang=en"><img alt="Twitter Follow" src="https://img.shields.io/twitter/follow/dfsoftwareinc.svg?style=social"></a>
</p>

<p align="center">
<a href="https://heroku.com/deploy?template=https://github.com/dreamfactorysoftware/dreamfactory">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
</a>
</p>

## Table of Contents

* <a href="#overview">Platform Overview</a>
* <a href="#installation">Installation Options</a>
* <a href="#heroku">Installing on Heroku</a>
* <a href="#hosted">DreamFactory's Cloud Environment</a>
* <a href="#documentation">Documentation</a>
* <a href="#community">Support Options</a>
* <a href="#commercial">Commercial Licenses</a>
* <a href="#feedback">Feedback</a>

<a name="overview"></a>
## Overview

DreamFactory is an API management solution best known for its ability to automatically generate secure and documented APIs for databases like Microsoft SQL Server, MySQL, Snowflake, PostgreSQL, Oracle, and MongoDB. It is built on top of the [Laravel framework](https://laravel.com/), and includes a convenient web-based administration client. So what can you do with DreamFactory?

* [Generate](http://guide.dreamfactory.com/docs/chapter03.html#generating-a-mysql-backed-api) powerful, reusable, documented APIs for SQL and NoSQL databases, files, email, push notifications and more in seconds.
* [Use the PHP, Python, and NodeJS scripting languages](http://wiki.dreamfactory.com/DreamFactory/Tutorials/Server_Side_Scripting) to easily customize API behavior at any endpoint, for both API requests and API responses.
* [Secure every API endpoint](http://guide.dreamfactory.com/docs/chapter03.html#creating-a-role) with user management, SSO authentication, role-based access control, OAuth and Active Directory integration.

<p align="center">
    <img alt="GitHub stars" src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/ScreenRecording20190524at1.gif">
</p>

<a name="installation"></a>
## Installation

* Install DreamFactory and all of the required dependencies in less than 5 minutes using our [installers](https://github.com/dreamfactorysoftware/dreamfactory/tree/master/installers) for CentOS/RHEL, Debian, Fedora, and Ubuntu.
* [Docker](http://wiki.dreamfactory.com/DreamFactory/Installation#Docker_Image) provides a DockerHub image or you can build your own.
* Our [Helm chart](https://github.com/dreamfactorysoftware/df-helm) provides a convenient way to install DreamFactory within your Kubernetes cluster.
* [Raspberry Pi](http://guide.dreamfactory.com/docs/raspberry-pi.html) allows you to configure DreamFactory on everybody's favorite tiny computer.


<a name="heroku"></a>

## Installing on Heroku

Heroku users can easily install DreamFactory by clicking on the below button. Keep in mind like many Heroku add-ons DreamFactory comes with some limitations such as the inability to deploy a local file system-based REST API due to Heroku's file system write limitations. Additionally, DreamFactory lacks support for multiple dynos. Regardless of these limitations, it's a breeze to get started using DreamFactory on Heroku so give it a whirl!

<p align="center">
<a href="https://heroku.com/deploy?template=https://github.com/dreamfactorysoftware/dreamfactory">
  <img src="https://www.herokucdn.com/deploy/button.svg" alt="Deploy">
</a>
</p>

<a href="#commercial">Contact us</a> for more information if you're interested in a feature complete version (whether hosted in our cloud environment or on-premise). Or just <a href="https://genie.dreamfactory.com/">spin up a hosted instance</a> right now! 

<a name="hosted"></a>
## DreamFactory's Cloud Environment

Start a free 14-day hosted trial now by creating a DreamFactory instance at <a href="https://genie.dreamfactory.com/">https://genie.dreamfactory.com/</a>.

<a name="documentation"></a>
## Documentation

Learn more about DreamFactory's many features by reading our [Getting Started Guide](http://guide.dreamfactory.com/).
Additional platform documentation can be found on the [DreamFactory wiki](http://wiki.dreamfactory.com).

<a name="community"></a>
## Community 

| <a href="https://stackoverflow.com/questions/tagged/dreamfactory"><img src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/stackoverflow.png" height="50px"/></a> | <a href="https://community.dreamfactory.com"><img src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/mark-gold.png" height="60px"/></a> | <a href="https://twitter.com/dfsoftwareinc"><img src="https://raw.githubusercontent.com/dreamfactorysoftware/dreamfactory/master/readme/twitter.png" height="40px"/></a> |
| --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Ask and answer StackOverflow questions with the [`dreamfactory` tag](https://stackoverflow.com/questions/tagged/dreamfactory)                                                                               | Check out our [community forum](https://community.dreamfactory.com), ask questions, and discuss project direction                                                                                           | Tweet to [`@dfsoftwareinc`](https://twitter.com/dfsoftwareinc) or with the [`#dreamfactory` hashtag](https://twitter.com/search?q=%23dreamfactory&f=live)  

<a name="commercial"></a>
## Commercial Licenses

In need of official technical support? Desire access to REST API generators for SQL Server, Oracle, SOAP, or mobile
push notifications? Require API limiting and/or auditing? Schedule a demo [with our team](https://www.dreamfactory.com/demo/)!

<a name="feedback"></a>
## Feedback and Contributions

Feedback is welcome on our [forum](http://community.dreamfactory.com/) or in the form of pull requests and/or issues. Contributions should follow the strategy outlined in ["Contributing to a project"](http://help.github.com/articles/fork-a-repo#contributing-to-a-project).
