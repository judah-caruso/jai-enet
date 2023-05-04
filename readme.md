# ENet

[ENet](https://github.com/zpl-c/enet) bindings for Jai. Note, this is not a port of ENet like [enet-jai](https://github.com/rytc/enet-jai).

# Building

```sh
git clone --recursive https://github.com/judah-caruso/jai-enet
cd jai-enet && jai generate.jai
```

To compile the library (required to generate bindings):

```sh
jai generate.jai - make-lib

# With debug information
jai generate.jai - make-lib debug
```

# Usage

See: `examples/`
