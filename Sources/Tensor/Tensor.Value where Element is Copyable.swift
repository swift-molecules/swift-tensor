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
    public func map<NewElement: Copyable, E: Swift::Error>(
        _ transform: (Element) throws(E) -> NewElement
    ) throws(E) -> Tensor.Value<NewElement, Rank, Tensor.Layout.Order.Row> {
        let count = self._shape.count
        var storage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<NewElement>
        >.Linear(
            minimumCapacity: Tagged<NewElement, Cardinal>(_unchecked: count)
        )

        guard let n = Int(exactly: count.rawValue) else {
            preconditionFailure("Tensor extent exceeds Int.max")
        }
        for i in 0..<n {
            let position = Tensor.Broadcast.position(ofLinearIndex: i, in: self._shape)
            let offset = position.linearize(strides: self._strides)
            precondition(offset.polarity != .negative, "Tensor linear offset must be nonnegative")
            let idx = Index<Element>(_unchecked: Ordinal(offset.magnitude.value.rawValue))
            storage.append(try transform(self._storage[idx]))
        }
        return Tensor.Value<NewElement, Rank, Tensor.Layout.Order.Row>(
            shape: self._shape,
            strides: Tensor.Strides<Rank>(rowMajor: self._shape),
            storage: storage
        )
    }
}
