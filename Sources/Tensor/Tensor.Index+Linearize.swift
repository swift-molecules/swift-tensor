public import Cardinal
public import Difference
public import Ordinal
public import Polarity

extension Tensor.Index.Position {

    @inlinable
    public func linearize(strides: Tensor.Strides<Rank>) -> Difference {
        var total = Difference.zero
        (0..<Rank).forEach { k in
            let stride = strides.values[k]
            let (magnitude, overflow) = positions[k].rawValue.multipliedReportingOverflow(
                by: stride.magnitude.underlying.rawValue
            )
            precondition(!overflow, "Tensor linear offset overflow")
            let component = stride.polarity == .negative
                ? Difference.negative(Difference.Magnitude(Cardinal(magnitude)))
                : Difference.positive(Difference.Magnitude(Cardinal(magnitude)))
            total += component
        }
        return total
    }

    @inlinable
    public func validate(against shape: Tensor.Shape<Rank>) throws(Tensor.Index.Error) {

        for k in 0..<Rank {
            let position = positions[k]
            let bound = shape.dims[k]
            if position >= bound {

                let axisCardinal: Cardinal
                do throws(Cardinal.Error) {
                    axisCardinal = try Cardinal(k)
                } catch {
                    preconditionFailure("k ranges over 0..<Rank, always non-negative: \(error)")
                }
                throw .outOfBounds(
                    axis: axisCardinal,
                    position: position,
                    bound: bound
                )
            }
        }
    }
}
