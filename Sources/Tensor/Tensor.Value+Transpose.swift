public import Buffer_Linear_Primitive
public import Memory_Allocator_Protocol
public import Tagged
public import Buffer_Linear
public import Memory_Allocator
public import Storage
public import Difference

public import Index

public import Cardinal
public import Ordinal
public import Buffer
public import Storage_Memory
public import Memory

extension Tensor.Value where Element: Copyable {

    @inlinable
    public func transposed() -> Tensor.Value<Element, Rank, Tensor.Layout.Strided>
    where Rank == 2 {
        var newDims = InlineArray<2, Cardinal>(repeating: .zero)
        newDims[0] = _shape.dims[1]
        newDims[1] = _shape.dims[0]
        let newShape = Tensor.Shape<2>(newDims)
        let count = newShape.count
        var newStorage = Buffer<
            Storage::Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Element>
        >.Linear(
            minimumCapacity: Tagged<Element, Cardinal>(_unchecked: count)
        )

        let rows = Int(exactly: newDims[0].rawValue)!
        let cols = Int(exactly: newDims[1].rawValue)!
        let stride0 = try! _strides.values[0].intValue()
        let stride1 = try! _strides.values[1].intValue()
        (0..<rows).forEach { newI in
            (0..<cols).forEach { newJ in

                let srcOffset = newJ * stride0 + newI * stride1
                precondition(srcOffset >= 0)
                let idx = Index<Element>(_unchecked: Ordinal(UInt(srcOffset)))
                newStorage.append(_storage[idx])
            }
        }
        let newStrides = Tensor.Strides<2>(rowMajor: newShape)
        return Tensor.Value<Element, 2, Tensor.Layout.Strided>(
            shape: newShape,
            strides: newStrides,
            storage: newStorage
        )
    }
}
