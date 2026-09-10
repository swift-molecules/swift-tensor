public import Cardinal

public import Difference

extension Tensor.Strides {

    @inlinable
    public init(rowMajor shape: Tensor.Shape<Rank>) {
        var values = InlineArray<Rank, Difference>(repeating: .zero)
        if Rank == 0 {
            self.init(values)
            return
        }
        var running: UInt = 1

        stride(from: Rank - 1, through: 0, by: -1).forEach { k in
            values[k] = .positive(Difference.Magnitude(Cardinal(running)))

            running = running &* shape.dims[k].rawValue
        }
        self.init(values)
    }

    @inlinable
    public init(columnMajor shape: Tensor.Shape<Rank>) {
        var values = InlineArray<Rank, Difference>(repeating: .zero)
        if Rank == 0 {
            self.init(values)
            return
        }
        var running: UInt = 1
        (0..<Rank).forEach { k in
            values[k] = .positive(Difference.Magnitude(Cardinal(running)))

            running = running &* shape.dims[k].rawValue
        }
        self.init(values)
    }
}
