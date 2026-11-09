public import Buffer
import Buffer_Linear
public import Buffer_Linear_Primitive
public import Cardinal
public import Difference
public import Index
public import Memory
public import Memory_Allocator
public import Memory_Allocator_Protocol
public import Ordinal
public import Polarity
public import Storage
public import Tagged

extension Tensor.Value where Element: Copyable {

    @inlinable
    public func reshape<let NewRank: Int>(
        to newShape: Tensor.Shape<NewRank>
    ) throws(Tensor.Reshape.Error) -> Tensor.Value<Element, NewRank, Tensor.Layout.Order.Row> {
        let fromCount = self._shape.count
        let toCount = newShape.count
        if fromCount != toCount {
            throw .productNotPreserved(from: fromCount, to: toCount)
        }
        var storage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: toCount)
        )

        guard let n = Int(exactly: toCount.rawValue) else {
            preconditionFailure("Tensor extent exceeds Int.max")
        }
        for i in 0..<n {
            let position = Tensor.Broadcast.position(ofLinearIndex: i, in: self._shape)
            let offset = position.linearize(strides: self._strides)
            precondition(offset.polarity != .negative, "Tensor linear offset must be nonnegative")
            let idx = Index<Element>(_unchecked: Ordinal(offset.magnitude.value.rawValue))
            storage.append(self._storage[idx])
        }
        return Tensor.Value<Element, NewRank, Tensor.Layout.Order.Row>(
            shape: newShape,
            strides: Tensor.Strides<NewRank>(rowMajor: newShape),
            storage: storage
        )
    }
}
