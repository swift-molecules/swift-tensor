public import Cardinal
public import Tensors_Core

extension Tensor.Value
where
    Element: Copyable & BinaryFloatingPoint,
    Layout == Tensor.Layout.Order.Row
{

    @inlinable
    public func mean() -> Element {
        precondition(self.shape.count != .zero, "mean() of an empty tensor is undefined")
        let total: Element = self.sum()

        let count = Element(Int(bitPattern: self.shape.count))
        return total / count
    }
}
