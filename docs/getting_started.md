# Getting Started with Gloo

### Prerequisites

- Ruby
- MySQL
- Postgres

Gloo requires Ruby to run.

If you don't have Ruby installed, you can download it from here: [http://www.ruby-lang.org/en/downloads/](http://www.ruby-lang.org/en/downloads/)

If you do not have MySQL or Postgres installed, find and follow the online instructions to install them.

### Installation

Once you have Ruby installed, you can install Gloo by running the following command:

```shell
> gem install gloo
```

### Configuration

See [[configuration|Application Configuration]] for details on how to configure Gloo.

### Running Gloo

To start Gloo, run the following command:

```shell
> gloo
```

This will start the Gloo application.

### Hello World

Once Gloo is running you can interact with the gloo interpreter. Type the following command to see the "Hello World" message:

```gloo
> show "Hello World"
```
