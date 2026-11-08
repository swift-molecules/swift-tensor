public import Buffer
import Buffer_Linear
public import Buffer_Linear_Primitive
public import Cardinal
import Index
public import Memory
public import Memory_Allocator
public import Memory_Allocator_Protocol
public import Storage
public import Tagged

extension Tensor.Value where Element: Copyable, Layout == Tensor.Layout.Order.Row {

    @inlinable
    public init(
        shape: Tensor.Shape<Rank>,
        elements: [Element]
    ) throws(Tensor.Shape<Rank>.Error) {
        let expected = shape.count
        let actual = Cardinal(UInt(elements.count))
        if expected != actual {
            throw .elementCountMismatch(expected: expected, actual: actual)
        }
        var storage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: expected)
        )
        for element in elements {
            storage.append(element)
        }
        let strides = Tensor.Strides<Rank>(rowMajor: shape)
        self.init(shape: shape, strides: strides, storage: storage)
    }
}
