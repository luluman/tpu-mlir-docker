# TPU-MLIR Development Docker Image

This project uses Docker technology to build the development environment for the
TPU-MLIR project. The following rules are suggested for use:

1. Principle of Minimalism: Only add necessary components and content to ensure
   the image size is small, facilitating downloads and secondary development.

2. Layering: Differentiate components that change less frequently from those
   that change more often. The less frequently changed components can be used as
   a base layer, and those that change quickly can be the upper layers, allowing
   for incremental updates.
