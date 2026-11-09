public import Cardinal
public import Difference
public import Ordinal

extension Tensor {

    public enum Broadcast {}
}

extension Tensor.Broadcast {

    @inlinable
    public static func align<let Rank: Int>(
        _ lhs: Tensor.Shape<Rank>,
        _ rhs: Tensor.Shape<Rank>
    ) throws(Error) -> Tensor.Shape<Rank> {
        var dims = InlineArray<Rank, Cardinal>(repeating: .zero)

        for axis in 0..<Rank {
            let a = lhs.dims[axis]
            let b = rhs.dims[axis]
            if a == b {
                dims[axis] = a
            } else if a == .one {
                dims[axis] = b
            } else if b == .one {
                dims[axis] = a
            } else {

                let axisCardinal: Cardinal
                do throws(Cardinal.Error) {
                    axisCardinal = try Cardinal(axis)
                } catch {
                    preconditionFailure("axis ≥ 0 by construction: \(error)")
                }
                throw .incompatibleShapes(
                    axis: axisCardinal,
                    lhs: a,
                    rhs: b
                )
            }
        }
        return Tensor.Shape<Rank>(dims)
    }
}

extension Tensor.Broadcast {

    @inlinable
    public static func position<let Rank: Int>(
        ofLinearIndex linearIndex: Int,
        in shape: Tensor.Shape<Rank>
    ) -> Tensor.Index.Position<Rank> {
        precondition(linearIndex >= 0)
        var positions = InlineArray<Rank, Ordinal>(repeating: .zero)
        var remaining = linearIndex

        stride(from: Rank - 1, through: 0, by: -1).forEach { axis in
            let dim: Int
            do throws(Cardinal.Error) {
                dim = try Int(shape.dims[axis])
            } catch {
                preconditionFailure("Tensor extent exceeds Int.max")
            }
            positions[axis] = Ordinal(UInt(remaining % dim))
            remaining /= dim
        }
        return Tensor.Index.Position<Rank>(positions)
    }
}

extension Tensor.Broadcast {

    @inlinable
    public static func strides<let Rank: Int>(
        of shape: Tensor.Shape<Rank>,
        aligned: Tensor.Shape<Rank>
    ) -> Tensor.Strides<Rank> {
        var strides = Tensor.Strides<Rank>(rowMajor: shape)

        (0..<Rank).forEach { axis in
            if shape.dims[axis] == .one && aligned.dims[axis] != .one {
                strides.values[axis] = .zero
            }
        }
        return strides
    }
}
