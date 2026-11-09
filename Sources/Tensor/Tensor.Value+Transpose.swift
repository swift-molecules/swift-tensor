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
public import Storage
public import Tagged

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

        let rows: Int
        do throws(Cardinal.Error) {
            rows = try Int(newDims[0])
        } catch {
            preconditionFailure("Tensor extent exceeds Int.max")
        }
        let cols: Int
        do throws(Cardinal.Error) {
            cols = try Int(newDims[1])
        } catch {
            preconditionFailure("Tensor extent exceeds Int.max")
        }
        let stride0: Int
        do {
            stride0 = try _strides.values[0].intValue()
        } catch {
            preconditionFailure("Strides of a constructed tensor are representable as Int: \(error)")
        }
        let stride1: Int
        do {
            stride1 = try _strides.values[1].intValue()
        } catch {
            preconditionFailure("Strides of a constructed tensor are representable as Int: \(error)")
        }
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
