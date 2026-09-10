public import Cardinal
public import Buffer_Linear_Primitive
public import Memory_Allocator_Protocol
public import Tagged
public import Buffer_Linear
public import Memory_Allocator
public import Storage

public import Index

public import Ordinal
public import Buffer
public import Storage_Memory
public import Memory

extension Tensor.Value where Element: Copyable {

    @inlinable
    public func map<NewElement: Copyable, E: Swift.Error>(
        _ transform: (Element) throws(E) -> NewElement
    ) throws(E) -> Tensor.Value<NewElement, Rank, Tensor.Layout.Order.Row> {
        let count = self._shape.count
        var storage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<NewElement>
        >.Linear(
            minimumCapacity: Tagged<NewElement, Cardinal>(_unchecked: count)
        )

        let n = Int(exactly: count.rawValue)!
        for i in 0..<n {
            let idx = Index<Element>(_unchecked: Ordinal(UInt(i)))
            storage.append(try transform(self._storage[idx]))
        }
        return Tensor.Value<NewElement, Rank, Tensor.Layout.Order.Row>(
            shape: self._shape,
            strides: Tensor.Strides<Rank>(rowMajor: self._shape),
            storage: storage
        )
    }
}
