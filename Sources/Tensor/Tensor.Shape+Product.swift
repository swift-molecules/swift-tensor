public import Cardinal

extension Tensor.Shape {

    @inlinable
    public var count: Cardinal {
        var total: UInt = 1

        (0..<Rank).forEach { axis in
            let (product, overflow) = total.multipliedReportingOverflow(
                by: dims[axis].rawValue
            )
            precondition(!overflow, "Tensor shape element count overflow")
            total = product
        }
        return Cardinal(total)
    }
}
