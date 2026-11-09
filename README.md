# swift-tensor

Use this package for dense, fixed-rank numeric arrays whose rank is part of the type. Start from `Tensor.Value<Element, Rank, Layout>` with `Tensor.Layout.Order.Row`, built from a `Tensor.Shape<Rank>` and a flat element list. The `Tensor` product holds the core: shapes, strides, broadcasting, element access, element-wise arithmetic, 2-D matrix multiplication, reshape, transpose and the whole-tensor reductions. Import the `Tensors` product when you also need transcendental functions, the statistics `mean()`, `variance()`, `stdev()` and `norm(p:)`, matrix-vector multiplication, or batched multiplication.

## Laws

- Elements are given and stored in row-major order: the last axis varies fastest.
- Every operation allocates new storage and returns a dense row-major result. Nothing is a view, nothing aliases its input, and nothing is lazy. `reshape(to:)` copies too, keeping the row-major element order.
- `transposed()` copies the elements into transposed order. The result is typed `Tensor.Layout.Strided`, but its strides are row-major over the new storage.
- A `Tensor.Value` is built only from a shape and a flat element list, or as the result of an operation, so its storage always holds exactly the shape's element count, densely, in row-major order. The initializer that takes explicit strides and storage is internal to the package.
- `element(at:)`, 2-D `multiplied(by:)`, `transposed()`, `map` and `reshape(to:)` read elements through the tensor's own `strides`. `scaled(by:)`, the reductions and the broadcasting operations are limited to `Tensor.Layout.Order.Row` and walk storage in row-major order of the shape.
- Broadcasting (`adding`, `subtracting`, `multiplying(elementWise:)`) compares the two shapes one axis at a time. Two sizes are compatible if they are equal or if one of them is 1, and a size-1 axis is stretched to the other size. There is no rank promotion: both operands have the same `Rank`. The first incompatible axis, counting from axis 0, is the one reported.
- Matrix products never broadcast. A 2-D product or a matrix-vector product reports a mismatched inner dimension at axis 1. `multiplied(batchedBy:)` checks the batch axis first and reports it at axis 0, then reports a mismatched inner dimension at axis 2.
- Reductions run over every element, whatever the shape. On an empty tensor, `sum()` is zero, `product()` is one, and `minimum()` and `maximum()` are `nil`. `mean()`, `variance()` and `stdev()` divide by the element count, so on an empty tensor they stop at a precondition.
- `variance()` is the population variance: it divides by the element count, not by count − 1. `stdev()` is its square root. `norm(p:)` is (Σ|x|ᵖ)^(1/p).
- `element(at:)` checks the position against every axis bound before it reads. An element count or linear offset that overflows traps; it is not thrown.
